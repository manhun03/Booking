package com.doan.hotelparking.controller;

import com.doan.hotelparking.common.ApiResponse;
import com.doan.hotelparking.common.ApiPagedResponse;
import com.doan.hotelparking.domain.entity.*;
import com.doan.hotelparking.domain.enums.BookingStatus;
import com.doan.hotelparking.domain.enums.NotificationType;
import com.doan.hotelparking.domain.enums.PaymentStatus;
import com.doan.hotelparking.domain.enums.RoomStatus;
import com.doan.hotelparking.dto.booking.BookingActionRequests.ChangeBookingRequest;
import com.doan.hotelparking.dto.booking.BookingActionRequests.RejectBookingRequest;
import com.doan.hotelparking.dto.booking.BookingDto;
import com.doan.hotelparking.dto.booking.CancelBookingRequest;
import com.doan.hotelparking.dto.booking.CustomerCreateBookingRequest;
import com.doan.hotelparking.dto.common.SimpleDtos.PaymentDto;
import com.doan.hotelparking.dto.common.SimpleDtos.ReviewDto;
import com.doan.hotelparking.dto.common.SimpleDtos.RoomTypeDto;
import com.doan.hotelparking.dto.common.SimpleDtos.TimeSlotDto;
import com.doan.hotelparking.dto.hotel.RoomDto;
import com.doan.hotelparking.dto.payment.PaymentDtos.InitiatePaymentRequest;
import com.doan.hotelparking.dto.payment.PaymentDtos.PaymentResult;
import com.doan.hotelparking.dto.payment.PaymentDtos.PaymentWebhookRequest;
import com.doan.hotelparking.dto.payment.PaymentDtos.RefundRequest;
import com.doan.hotelparking.dto.review.ReviewDtos.CreateReviewRequest;
import com.doan.hotelparking.dto.review.ReviewDtos.ModerateReviewRequest;
import com.doan.hotelparking.dto.review.ReviewDtos.OwnerReplyRequest;
import com.doan.hotelparking.dto.review.ReviewDtos.ReportReviewRequest;
import com.doan.hotelparking.repository.*;
import com.doan.hotelparking.security.HasPermission;
import com.doan.hotelparking.service.CurrentUserService;
import com.doan.hotelparking.service.DtoMapper;
import com.doan.hotelparking.service.NotificationService;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.*;
import org.springframework.data.domain.PageRequest;
import org.springframework.security.core.context.SecurityContextHolder;

import java.math.BigDecimal;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.time.ZoneId;
import java.time.ZoneOffset;
import java.time.format.DateTimeFormatter;
import java.time.Duration;
import java.time.Instant;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.TreeMap;
import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;

final class BookingControllers {
    private BookingControllers() {
    }
}

@RestController
@RequestMapping("/api/bookings")
class BookingController {
    private final BookingRepository bookings;
    private final RoomRepository rooms;
    private final TimeSlotRepository timeSlots;
    private final PaymentRepository payments;
    private final OwnerSettingRepository ownerSettings;
    private final CurrentUserService currentUser;
    private final DtoMapper mapper;
    private final NotificationService notificationService;

    BookingController(BookingRepository repository,
                      RoomRepository rooms,
                      TimeSlotRepository timeSlots,
                      PaymentRepository payments,
                      OwnerSettingRepository ownerSettings,
                      CurrentUserService currentUser,
                      DtoMapper mapper,
                      NotificationService notificationService) {
        this.bookings = repository;
        this.rooms = rooms;
        this.timeSlots = timeSlots;
        this.payments = payments;
        this.ownerSettings = ownerSettings;
        this.currentUser = currentUser;
        this.mapper = mapper;
        this.notificationService = notificationService;
    }

    @GetMapping
    @PreAuthorize("hasAnyRole('Admin','Owner')")
    @HasPermission("booking.read")
    ApiPagedResponse<BookingDto> getAll(@RequestParam(defaultValue = "1") int pageIndex,
                                        @RequestParam(defaultValue = "20") int pageSize) {
        var items = isAdmin() ? bookings.findAllDetailed() : bookings.findForOwner(currentUser.requireUserId());
        var size = Math.min(Math.max(pageSize, 1), 100);
        var from = Math.min((Math.max(pageIndex, 1) - 1) * size, items.size());
        var to = Math.min(from + size, items.size());
        return ApiPagedResponse.ok(items.subList(from, to).stream().map(mapper::toBookingDto).toList(),
                pageIndex, size, items.size());
    }

    @GetMapping("/{id}")
    @PreAuthorize("hasAnyRole('Admin','Owner')")
    @HasPermission("booking.read")
    ApiResponse<BookingDto> getById(@PathVariable Integer id) {
        return ApiResponse.ok(bookings.findDetailedById(id).map(mapper::toBookingDto)
                .orElseThrow(() -> new IllegalArgumentException("Booking not found")));
    }

    @PostMapping
    @PreAuthorize("hasAnyRole('Admin','Owner')")
    @HasPermission("booking.manage")
    ApiResponse<BookingDto> create(@RequestBody Booking booking) {
        booking.setCreatedAt(booking.getCreatedAt() == null ? Instant.now() : booking.getCreatedAt());
        booking.setUpdatedAt(Instant.now());
        return ApiResponse.ok("Created", mapper.toBookingDto(bookings.save(booking)));
    }

    @PutMapping("/{id}")
    @PreAuthorize("hasAnyRole('Admin','Owner')")
    @HasPermission("booking.manage")
    ApiResponse<BookingDto> update(@PathVariable Integer id, @RequestBody Booking request) {
        var booking = bookings.findById(id).orElseThrow(() -> new IllegalArgumentException("Booking not found"));
        if (!request.getCheckOutDate().isAfter(request.getCheckInDate())) {
            throw new IllegalArgumentException("Check-out date must be after check-in date");
        }
        if (bookings.hasOverlappingBooking(request.getRoom().getId(), request.getCheckInDate(), request.getCheckOutDate(), id)) {
            throw new IllegalArgumentException("Room has already been booked for the selected dates");
        }
        booking.setRoom(request.getRoom());
        booking.setCustomer(request.getCustomer());
        booking.setCheckInDate(request.getCheckInDate());
        booking.setCheckOutDate(request.getCheckOutDate());
        booking.setNightCount(request.getNightCount());
        booking.setGuestCount(request.getGuestCount());
        booking.setRoomUnitPrice(request.getRoomUnitPrice());
        booking.setTotalAmount(request.getTotalAmount());
        booking.setPaidAmount(request.getPaidAmount());
        booking.setNote(request.getNote());
        booking.setStatus(request.getStatus());
        booking.setUpdatedAt(Instant.now());
        return ApiResponse.ok("Updated", mapper.toBookingDto(bookings.save(booking)));
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasAnyRole('Admin','Owner')")
    @HasPermission("booking.manage")
    ApiResponse<Void> delete(@PathVariable Integer id) {
        bookings.deleteById(id);
        return ApiResponse.ok("Deleted", null);
    }

    @GetMapping("/my-bookings")
    @PreAuthorize("hasRole('Customer')")
    ApiPagedResponse<BookingDto> myBookings(@RequestParam(required = false) Integer userId,
                                            @RequestParam(defaultValue = "1") int pageIndex,
                                            @RequestParam(defaultValue = "20") int pageSize) {
        var resolvedUserId = userId == null ? currentUser.requireUserId() : userId;
        var items = bookings.findDetailedByCustomerId(resolvedUserId).stream().map(mapper::toBookingDto).toList();
        var from = Math.min((Math.max(pageIndex, 1) - 1) * pageSize, items.size());
        var to = Math.min(from + pageSize, items.size());
        return ApiPagedResponse.ok(items.subList(from, to), pageIndex, pageSize, items.size());
    }

    @PostMapping("/request")
    @PreAuthorize("hasRole('Customer')")
    @Transactional
    ApiResponse<BookingDto> request(@Valid @RequestBody CustomerCreateBookingRequest request) {
        var room = rooms.findDetailedById(request.roomId())
                .orElseThrow(() -> new IllegalArgumentException("Room not found"));
        if (room.isDeleted() || room.getStatus() != RoomStatus.AVAILABLE) {
            throw new IllegalArgumentException("Room is not available for booking");
        }
        if (!request.checkOutDate().isAfter(request.checkInDate())) {
            throw new IllegalArgumentException("Check-out date must be after check-in date");
        }
        if (bookings.hasOverlappingBooking(room.getId(), request.checkInDate(), request.checkOutDate(), null)) {
            throw new IllegalArgumentException("Room has already been booked for the selected dates");
        }
        var paidAmount = request.paidAmount() == null ? BigDecimal.ZERO : request.paidAmount();
        var customer = new User();
        customer.setId(currentUser.requireUserId());
        var nightCount = Math.max(1, (int) Duration.between(request.checkInDate(), request.checkOutDate()).toDays());
        var unitPrice = timeSlots.findFirstByRoomIdAndActiveTrueAndStartDateLessThanEqualAndEndDateGreaterThanEqualOrderByCreatedAtDesc(
                        room.getId(), request.checkInDate(), request.checkOutDate())
                .map(TimeSlot::getPrice)
                .orElse(room.getPrice());
        var totalAmount = unitPrice.multiply(BigDecimal.valueOf(nightCount));
        if (paidAmount.compareTo(BigDecimal.ZERO) < 0) {
            throw new IllegalArgumentException("Paid amount cannot be negative");
        }
        if (paidAmount.compareTo(totalAmount) > 0) {
            throw new IllegalArgumentException("Paid amount cannot exceed total amount");
        }
        if (paidAmount.compareTo(BigDecimal.ZERO) > 0) {
            var validBankInfo = ownerSettings.findByOwnerId(room.getHotel().getOwner().getId())
                    .map(setting -> setting.getBankName() != null && !setting.getBankName().isBlank()
                            && setting.getBankAccountNumber() != null && !setting.getBankAccountNumber().isBlank()
                            && setting.getBankAccountName() != null && !setting.getBankAccountName().isBlank())
                    .orElse(false);
            if (!validBankInfo) {
                throw new IllegalArgumentException("Hotel owner has not completed bank information for receiving payments");
            }
        }
        var booking = new Booking();
        booking.setRoom(room);
        booking.setCustomer(customer);
        booking.setCheckInDate(request.checkInDate());
        booking.setCheckOutDate(request.checkOutDate());
        booking.setNightCount(nightCount);
        booking.setGuestCount(request.guestCount());
        booking.setRoomUnitPrice(unitPrice);
        booking.setTotalAmount(totalAmount);
        booking.setPaidAmount(paidAmount);
        booking.setCustomerAddress(request.customerAddress());
        booking.setNote(request.note());
        booking.setStatus(paidAmount.compareTo(totalAmount) >= 0 ? BookingStatus.CONFIRMED : BookingStatus.PENDING);
        booking.setCreatedAt(Instant.now());
        booking.setUpdatedAt(Instant.now());
        var saved = bookings.save(booking);
        var ownerId = room.getHotel().getOwner().getId();
        notificationService.create(ownerId, "New booking request",
                "A customer requested booking #" + saved.getId(), NotificationType.BOOKING, "Booking", saved.getId());
        if (paidAmount.compareTo(BigDecimal.ZERO) > 0) {
            var payment = new Payment();
            payment.setBooking(saved);
            payment.setAmount(paidAmount);
            payment.setMethod(request.paymentMethod());
            payment.setStatus(PaymentStatus.COMPLETED);
            payment.setTransactionCode(request.transactionCode());
            payment.setNote(request.paymentNote());
            payment.setPaidAt(Instant.now());
            payment.setCreatedAt(Instant.now());
            payments.save(payment);
            notificationService.create(currentUser.requireUserId(), "Payment recorded",
                    "Payment was recorded for booking #" + saved.getId(), NotificationType.PAYMENT, "Payment", payment.getId());
        }
        return ApiResponse.ok("Booking request created", mapper.toBookingDto(saved));
    }

    @PostMapping("/{id}/cancel")
    @PreAuthorize("hasRole('Customer')")
    @Transactional
    ApiResponse<BookingDto> cancel(@PathVariable Integer id, @RequestBody(required = false) CancelBookingRequest request) {
        var booking = bookings.findDetailedById(id)
                .orElseThrow(() -> new IllegalArgumentException("Booking not found"));
        if (!booking.getCustomer().getId().equals(currentUser.requireUserId())) {
            throw new IllegalArgumentException("Booking not found");
        }
        if (booking.getStatus() == BookingStatus.CANCELLED || booking.getStatus() == BookingStatus.COMPLETED) {
            throw new IllegalArgumentException("Booking cannot be cancelled");
        }
        booking.setStatus(BookingStatus.CANCELLED);
        booking.setCancelledBy(booking.getCustomer().getId());
        booking.setCancelReason(request == null ? null : request.reason());
        booking.setCancellationFee(calculateCancellationFee(booking));
        booking.setCancelledAt(Instant.now());
        booking.setUpdatedAt(Instant.now());
        var saved = bookings.save(booking);
        notificationService.create(booking.getRoom().getHotel().getOwner().getId(), "Booking cancelled",
                "Booking #" + booking.getId() + " was cancelled.", NotificationType.BOOKING, "Booking", booking.getId());
        return ApiResponse.ok("Booking cancelled", mapper.toBookingDto(saved));
    }

    @PostMapping("/{id}/confirm")
    @PreAuthorize("hasRole('Owner')")
    @Transactional
    ApiResponse<BookingDto> confirm(@PathVariable Integer id) {
        var booking = requireOwnerBooking(id);
        if (booking.getStatus() != BookingStatus.PENDING) {
            throw new IllegalArgumentException("Only pending bookings can be confirmed");
        }
        booking.setStatus(BookingStatus.CONFIRMED);
        booking.setUpdatedAt(Instant.now());
        var saved = bookings.save(booking);
        notificationService.create(booking.getCustomer().getId(), "Booking confirmed",
                "Your booking #" + booking.getId() + " has been confirmed.", NotificationType.BOOKING, "Booking", booking.getId());
        return ApiResponse.ok("Booking confirmed", mapper.toBookingDto(saved));
    }

    @PostMapping("/{id}/reject")
    @PreAuthorize("hasRole('Owner')")
    @Transactional
    ApiResponse<BookingDto> reject(@PathVariable Integer id, @RequestBody(required = false) RejectBookingRequest request) {
        var booking = requireOwnerBooking(id);
        if (booking.getStatus() != BookingStatus.PENDING) {
            throw new IllegalArgumentException("Only pending bookings can be rejected");
        }
        booking.setStatus(BookingStatus.REJECTED);
        booking.setRejectedReason(request == null ? null : request.reason());
        booking.setRejectedAt(Instant.now());
        booking.setUpdatedAt(Instant.now());
        var saved = bookings.save(booking);
        notificationService.create(booking.getCustomer().getId(), "Booking rejected",
                "Your booking #" + booking.getId() + " has been rejected.", NotificationType.BOOKING, "Booking", booking.getId());
        return ApiResponse.ok("Booking rejected", mapper.toBookingDto(saved));
    }

    @PutMapping("/{id}/change")
    @PreAuthorize("hasRole('Customer')")
    @Transactional
    ApiResponse<BookingDto> change(@PathVariable Integer id, @RequestBody ChangeBookingRequest request) {
        var booking = bookings.findDetailedById(id).orElseThrow(() -> new IllegalArgumentException("Booking not found"));
        if (!booking.getCustomer().getId().equals(currentUser.requireUserId())) {
            throw new IllegalArgumentException("Booking not found");
        }
        if (booking.getStatus() == BookingStatus.CANCELLED || booking.getStatus() == BookingStatus.COMPLETED || booking.getStatus() == BookingStatus.CHECKED_OUT) {
            throw new IllegalArgumentException("Booking cannot be changed");
        }
        var room = request.roomId() == null ? booking.getRoom() : rooms.findDetailedById(request.roomId())
                .orElseThrow(() -> new IllegalArgumentException("Room not found"));
        var checkIn = request.checkInDate() == null ? booking.getCheckInDate() : request.checkInDate();
        var checkOut = request.checkOutDate() == null ? booking.getCheckOutDate() : request.checkOutDate();
        if (!checkOut.isAfter(checkIn)) {
            throw new IllegalArgumentException("Check-out date must be after check-in date");
        }
        if (bookings.hasOverlappingBooking(room.getId(), checkIn, checkOut, booking.getId())) {
            throw new IllegalArgumentException("Room has already been booked for the selected dates");
        }
        booking.setRoom(room);
        booking.setCheckInDate(checkIn);
        booking.setCheckOutDate(checkOut);
        booking.setGuestCount(request.guestCount() == null ? booking.getGuestCount() : request.guestCount());
        booking.setNightCount(Math.max(1, (int) Duration.between(checkIn, checkOut).toDays()));
        booking.setRoomUnitPrice(resolveRoomPrice(room, checkIn, checkOut));
        booking.setTotalAmount(booking.getRoomUnitPrice().multiply(BigDecimal.valueOf(booking.getNightCount())));
        booking.setNote(request.note() == null ? booking.getNote() : request.note());
        booking.setStatus(BookingStatus.PENDING);
        booking.setUpdatedAt(Instant.now());
        var saved = bookings.save(booking);
        notificationService.create(room.getHotel().getOwner().getId(), "Booking changed",
                "Booking #" + booking.getId() + " was changed and needs review.", NotificationType.BOOKING, "Booking", booking.getId());
        return ApiResponse.ok("Booking changed", mapper.toBookingDto(saved));
    }

    @PostMapping("/{id}/check-in")
    @PreAuthorize("hasRole('Owner')")
    @Transactional
    ApiResponse<BookingDto> checkIn(@PathVariable Integer id) {
        var booking = requireOwnerBooking(id);
        if (booking.getStatus() != BookingStatus.CONFIRMED) {
            throw new IllegalArgumentException("Only confirmed bookings can check in");
        }
        booking.setStatus(BookingStatus.CHECKED_IN);
        booking.setCheckedInAt(Instant.now());
        booking.getRoom().setStatus(RoomStatus.OCCUPIED);
        booking.setUpdatedAt(Instant.now());
        return ApiResponse.ok("Checked in", mapper.toBookingDto(bookings.save(booking)));
    }

    @PostMapping("/{id}/check-out")
    @PreAuthorize("hasRole('Owner')")
    @Transactional
    ApiResponse<BookingDto> checkOut(@PathVariable Integer id) {
        var booking = requireOwnerBooking(id);
        if (booking.getStatus() != BookingStatus.CHECKED_IN) {
            throw new IllegalArgumentException("Only checked-in bookings can check out");
        }
        booking.setStatus(BookingStatus.COMPLETED);
        booking.setCheckedOutAt(Instant.now());
        booking.setPaidAmount(booking.getTotalAmount());
        booking.getRoom().setStatus(RoomStatus.AVAILABLE);
        booking.setUpdatedAt(Instant.now());
        var saved = bookings.save(booking);
        notificationService.create(booking.getCustomer().getId(), "Booking completed",
                "Your booking #" + booking.getId() + " has been completed.", NotificationType.BOOKING, "Booking", booking.getId());
        return ApiResponse.ok("Checked out", mapper.toBookingDto(saved));
    }

    @PatchMapping("/{id}/force-complete")
    @PreAuthorize("hasRole('Admin')")
    @HasPermission("booking.force_complete")
    @Transactional
    ApiResponse<BookingDto> forceComplete(@PathVariable Integer id) {
        var booking = bookings.findDetailedById(id)
                .orElseThrow(() -> new IllegalArgumentException("Booking not found"));
        if (booking.getStatus() == BookingStatus.CANCELLED) {
            throw new IllegalArgumentException("Cancelled booking cannot be force-completed");
        }
        booking.setStatus(BookingStatus.COMPLETED);
        booking.setPaidAmount(booking.getTotalAmount());
        booking.setUpdatedAt(Instant.now());
        return ApiResponse.ok("Booking force completed", mapper.toBookingDto(bookings.save(booking)));
    }

    private Booking requireOwnerBooking(Integer id) {
        var booking = bookings.findDetailedById(id).orElseThrow(() -> new IllegalArgumentException("Booking not found"));
        if (!booking.getRoom().getHotel().getOwner().getId().equals(currentUser.requireUserId())) {
            throw new IllegalArgumentException("Booking not found");
        }
        return booking;
    }

    private BigDecimal calculateCancellationFee(Booking booking) {
        var hoursBeforeCheckIn = Duration.between(Instant.now(), booking.getCheckInDate()).toHours();
        if (hoursBeforeCheckIn >= 24) {
            return BigDecimal.ZERO;
        }
        return booking.getTotalAmount().multiply(BigDecimal.valueOf(0.1));
    }

    private boolean isAdmin() {
        var authentication = SecurityContextHolder.getContext().getAuthentication();
        return authentication != null && authentication.getAuthorities().stream()
                .anyMatch(authority -> "ROLE_Admin".equals(authority.getAuthority()));
    }

    private BigDecimal resolveRoomPrice(Room room, Instant checkIn, Instant checkOut) {
        return timeSlots.findFirstByRoomIdAndActiveTrueAndStartDateLessThanEqualAndEndDateGreaterThanEqualOrderByCreatedAtDesc(
                        room.getId(), checkIn, checkOut)
                .map(TimeSlot::getPrice)
                .orElse(room.getPromotionPrice() != null ? room.getPromotionPrice() :
                        room.getSeasonalPrice() != null ? room.getSeasonalPrice() : room.getPrice());
    }
}

@RestController
@RequestMapping("/api/payments")
class PaymentController {
    private final PaymentRepository payments;
    private final BookingRepository bookings;
    private final CurrentUserService currentUser;
    private final NotificationService notificationService;
    private final DtoMapper mapper;
    private final String vnpayPayUrl;
    private final String vnpayReturnUrl;
    private final String vnpayTmnCode;
    private final String vnpayHashSecret;

    PaymentController(PaymentRepository repository,
                      BookingRepository bookings,
                      CurrentUserService currentUser,
                      NotificationService notificationService,
                      DtoMapper mapper,
                      @Value("${app.payment.vnpay.pay-url:}") String vnpayPayUrl,
                      @Value("${app.payment.vnpay.return-url:}") String vnpayReturnUrl,
                      @Value("${app.payment.vnpay.tmn-code:}") String vnpayTmnCode,
                      @Value("${app.payment.vnpay.hash-secret:}") String vnpayHashSecret) {
        this.payments = repository;
        this.bookings = bookings;
        this.currentUser = currentUser;
        this.notificationService = notificationService;
        this.mapper = mapper;
        this.vnpayPayUrl = vnpayPayUrl;
        this.vnpayReturnUrl = vnpayReturnUrl;
        this.vnpayTmnCode = vnpayTmnCode;
        this.vnpayHashSecret = vnpayHashSecret;
    }

    @GetMapping
    @PreAuthorize("hasAnyRole('Admin','Owner')")
    @Transactional(readOnly = true)
    ApiResponse<List<PaymentDto>> getAll() {
        return ApiResponse.ok(payments.findAll().stream().map(mapper::toPaymentDto).toList());
    }

    @GetMapping("/by-booking/{bookingId}")
    @PreAuthorize("hasAnyRole('Customer','Owner','Admin')")
    @Transactional(readOnly = true)
    ApiResponse<List<PaymentDto>> byBooking(@PathVariable Integer bookingId) {
        requireAccessibleBooking(bookingId);
        return ApiResponse.ok(payments.findByBookingId(bookingId).stream()
                .map(mapper::toPaymentDto)
                .toList());
    }

    @PostMapping("/initiate")
    @PreAuthorize("hasRole('Customer')")
    @Transactional
    ApiResponse<PaymentResult> initiate(@RequestBody InitiatePaymentRequest request) {
        var booking = bookings.findDetailedById(request.bookingId())
                .orElseThrow(() -> new IllegalArgumentException("Booking not found"));
        if (!booking.getCustomer().getId().equals(currentUser.requireUserId())) {
            throw new IllegalArgumentException("Booking not found");
        }
        var amount = request.amount() == null ? booking.getTotalAmount().subtract(booking.getPaidAmount()) : request.amount();
        if (amount.compareTo(BigDecimal.ZERO) <= 0) {
            throw new IllegalArgumentException("Payment amount must be greater than zero");
        }
        if (booking.getPaidAmount().add(amount).compareTo(booking.getTotalAmount()) > 0) {
            throw new IllegalArgumentException("Payment amount exceeds remaining balance");
        }
        var tx = "PAY-" + booking.getId() + "-" + Instant.now().toEpochMilli();
        var provider = request.provider() == null || request.provider().isBlank()
                ? "VNPAY"
                : request.provider().trim().toUpperCase();
        var payment = new Payment();
        payment.setBooking(booking);
        payment.setAmount(amount);
        payment.setProvider(provider);
        payment.setMethod(request.method() == null ? "ONLINE" : request.method());
        payment.setStatus(PaymentStatus.PENDING);
        payment.setTransactionCode(tx);
        payment.setCheckoutUrl(buildCheckoutUrl(provider, payment, booking));
        payment = payments.save(payment);
        return ApiResponse.ok("Payment initiated",
                new PaymentResult(payment.getId(), payment.getTransactionCode(), payment.getProvider(), payment.getStatus().name(), payment.getCheckoutUrl()));
    }

    @GetMapping("/vnpay-return")
    @Transactional
    ApiResponse<PaymentDto> vnpayReturn(@RequestParam Map<String, String> params) {
        if (!verifyVnpaySignature(params)) {
            throw new IllegalArgumentException("Invalid VNPay signature");
        }
        var transactionCode = params.get("vnp_TxnRef");
        var responseCode = params.get("vnp_ResponseCode");
        var gatewayTransactionId = params.get("vnp_TransactionNo");
        return applyPaymentResult(transactionCode, gatewayTransactionId,
                "00".equals(responseCode) ? "COMPLETED" : "FAILED",
                "00".equals(responseCode) ? null : "VNPay response code: " + responseCode);
    }

    @PostMapping("/webhook")
    @Transactional
    ApiResponse<PaymentDto> webhook(@RequestBody PaymentWebhookRequest request) {
        return applyPaymentResult(request.transactionCode(), request.gatewayTransactionId(), request.status(), request.failureReason());
    }

    private ApiResponse<PaymentDto> applyPaymentResult(String transactionCode,
                                                       String gatewayTransactionId,
                                                       String requestedStatus,
                                                       String failureReason) {
        var payment = payments.findByTransactionCode(transactionCode)
                .or(() -> gatewayTransactionId == null ? java.util.Optional.empty() : payments.findByGatewayTransactionId(gatewayTransactionId))
                .orElseThrow(() -> new IllegalArgumentException("Payment not found"));
        var status = requestedStatus == null ? "" : requestedStatus.trim().toUpperCase();
        if ("COMPLETED".equals(status) || "SUCCESS".equals(status) || "PAID".equals(status)) {
            payment.setStatus(PaymentStatus.COMPLETED);
            payment.setPaidAt(Instant.now());
            payment.setGatewayTransactionId(gatewayTransactionId);
            var booking = payment.getBooking();
            booking.setPaidAmount(booking.getPaidAmount().add(payment.getAmount()));
            if (booking.getPaidAmount().compareTo(booking.getTotalAmount()) >= 0) {
                booking.setStatus(BookingStatus.CONFIRMED);
            }
            booking.setUpdatedAt(Instant.now());
            notificationService.create(booking.getCustomer().getId(), "Payment completed",
                    "Payment completed for booking #" + booking.getId(), NotificationType.PAYMENT, "Payment", payment.getId());
        } else {
            payment.setStatus(PaymentStatus.FAILED);
            payment.setFailureReason(failureReason);
        }
        return ApiResponse.ok("Webhook processed", mapper.toPaymentDto(payments.save(payment)));
    }

    private String buildCheckoutUrl(String provider, Payment payment, Booking booking) {
        if (!"VNPAY".equalsIgnoreCase(provider)) {
            throw new IllegalArgumentException("Unsupported payment provider: " + provider);
        }
        if (isBlank(vnpayPayUrl) || isBlank(vnpayReturnUrl) || isBlank(vnpayTmnCode) || isBlank(vnpayHashSecret)) {
            throw new IllegalArgumentException("VNPay is not configured. Set VNPAY_PAY_URL, VNPAY_RETURN_URL, VNPAY_TMN_CODE and VNPAY_HASH_SECRET.");
        }
        var now = Instant.now().atZone(ZoneId.of("Asia/Ho_Chi_Minh"));
        var formatter = DateTimeFormatter.ofPattern("yyyyMMddHHmmss");
        var params = new TreeMap<String, String>();
        params.put("vnp_Version", "2.1.0");
        params.put("vnp_Command", "pay");
        params.put("vnp_TmnCode", vnpayTmnCode);
        params.put("vnp_Amount", payment.getAmount().multiply(BigDecimal.valueOf(100)).toBigInteger().toString());
        params.put("vnp_CurrCode", "VND");
        params.put("vnp_TxnRef", payment.getTransactionCode());
        params.put("vnp_OrderInfo", "Hotel booking " + booking.getId());
        params.put("vnp_OrderType", "billpayment");
        params.put("vnp_Locale", "vn");
        params.put("vnp_ReturnUrl", vnpayReturnUrl);
        params.put("vnp_IpAddr", "127.0.0.1");
        params.put("vnp_CreateDate", formatter.format(now));
        params.put("vnp_ExpireDate", formatter.format(now.plusMinutes(15)));
        var hashData = buildQuery(params, true);
        params.put("vnp_SecureHash", hmacSha512(vnpayHashSecret, hashData));
        return vnpayPayUrl + "?" + buildQuery(params, true);
    }

    private boolean verifyVnpaySignature(Map<String, String> params) {
        if (isBlank(vnpayHashSecret)) {
            throw new IllegalArgumentException("VNPay hash secret is not configured.");
        }
        var receivedHash = params.get("vnp_SecureHash");
        if (isBlank(receivedHash)) {
            return false;
        }
        var signed = new TreeMap<String, String>();
        for (var entry : params.entrySet()) {
            if (entry.getKey().startsWith("vnp_")
                    && !"vnp_SecureHash".equals(entry.getKey())
                    && !"vnp_SecureHashType".equals(entry.getKey())) {
                signed.put(entry.getKey(), entry.getValue());
            }
        }
        return receivedHash.equalsIgnoreCase(hmacSha512(vnpayHashSecret, buildQuery(signed, true)));
    }

    private String buildQuery(Map<String, String> params, boolean encodeValues) {
        return params.entrySet().stream()
                .filter(entry -> entry.getValue() != null && !entry.getValue().isBlank())
                .map(entry -> urlEncode(entry.getKey()) + "=" + (encodeValues ? urlEncode(entry.getValue()) : entry.getValue()))
                .reduce((left, right) -> left + "&" + right)
                .orElse("");
    }

    private String urlEncode(String value) {
        return URLEncoder.encode(value, StandardCharsets.UTF_8).replace("+", "%20");
    }

    private String hmacSha512(String key, String data) {
        try {
            var hmac = Mac.getInstance("HmacSHA512");
            hmac.init(new SecretKeySpec(key.getBytes(StandardCharsets.UTF_8), "HmacSHA512"));
            var bytes = hmac.doFinal(data.getBytes(StandardCharsets.UTF_8));
            var result = new StringBuilder(bytes.length * 2);
            for (byte b : bytes) {
                result.append(String.format("%02x", b));
            }
            return result.toString();
        } catch (Exception ex) {
            throw new IllegalStateException("Unable to sign VNPay request", ex);
        }
    }

    private boolean isBlank(String value) {
        return value == null || value.isBlank();
    }

    private Booking requireAccessibleBooking(Integer bookingId) {
        var booking = bookings.findDetailedById(bookingId)
                .orElseThrow(() -> new IllegalArgumentException("Booking not found"));
        var userId = currentUser.requireUserId();
        var isCustomer = booking.getCustomer() != null && booking.getCustomer().getId().equals(userId);
        var isOwner = booking.getRoom() != null
                && booking.getRoom().getHotel() != null
                && booking.getRoom().getHotel().getOwner() != null
                && booking.getRoom().getHotel().getOwner().getId().equals(userId);
        if (!isCustomer && !isOwner && !isAdmin()) {
            throw new IllegalArgumentException("Booking not found");
        }
        return booking;
    }

    @PostMapping("/{id}/refund")
    @PreAuthorize("hasAnyRole('Admin','Owner')")
    @Transactional
    ApiResponse<PaymentDto> refund(@PathVariable Integer id, @RequestBody RefundRequest request) {
        var payment = payments.findById(id).orElseThrow(() -> new IllegalArgumentException("Payment not found"));
        var booking = payment.getBooking();
        var isOwner = booking.getRoom().getHotel().getOwner().getId().equals(currentUser.requireUserId());
        if (!isOwner && !isAdmin()) {
            throw new IllegalArgumentException("Payment not found");
        }
        if (payment.getStatus() != PaymentStatus.COMPLETED && payment.getStatus() != PaymentStatus.PARTIALLY_REFUNDED) {
            throw new IllegalArgumentException("Only completed payments can be refunded");
        }
        var amount = request.amount() == null ? payment.getAmount().subtract(payment.getRefundedAmount()) : request.amount();
        if (amount.compareTo(BigDecimal.ZERO) <= 0 || payment.getRefundedAmount().add(amount).compareTo(payment.getAmount()) > 0) {
            throw new IllegalArgumentException("Invalid refund amount");
        }
        payment.setRefundedAmount(payment.getRefundedAmount().add(amount));
        payment.setRefundedAt(Instant.now());
        payment.setNote(request.reason());
        payment.setStatus(payment.getRefundedAmount().compareTo(payment.getAmount()) >= 0 ? PaymentStatus.REFUNDED : PaymentStatus.PARTIALLY_REFUNDED);
        booking.setPaidAmount(booking.getPaidAmount().subtract(amount).max(BigDecimal.ZERO));
        booking.setUpdatedAt(Instant.now());
        notificationService.create(booking.getCustomer().getId(), "Payment refunded",
                "A refund was processed for booking #" + booking.getId(), NotificationType.PAYMENT, "Payment", payment.getId());
        return ApiResponse.ok("Refund processed", mapper.toPaymentDto(payments.save(payment)));
    }

    private boolean isAdmin() {
        var authentication = SecurityContextHolder.getContext().getAuthentication();
        return authentication != null && authentication.getAuthorities().stream()
                .anyMatch(authority -> "ROLE_Admin".equals(authority.getAuthority()));
    }
}

@RestController
@RequestMapping("/api/reviews")
class ReviewController {
    private final ReviewRepository reviews;
    private final BookingRepository bookings;
    private final CurrentUserService currentUser;
    private final NotificationService notificationService;
    private final DtoMapper mapper;

    ReviewController(ReviewRepository repository, BookingRepository bookings, CurrentUserService currentUser, NotificationService notificationService, DtoMapper mapper) {
        this.reviews = repository;
        this.bookings = bookings;
        this.currentUser = currentUser;
        this.notificationService = notificationService;
        this.mapper = mapper;
    }

    @GetMapping("/by-hotel/{hotelId}")
    @Transactional(readOnly = true)
    ApiResponse<List<ReviewDto>> byHotel(@PathVariable Integer hotelId) {
        return ApiResponse.ok(reviews.findByRoomHotelId(hotelId).stream()
                .filter(Review::isVisible)
                .map(mapper::toReviewDto)
                .toList());
    }

    @PostMapping
    @PreAuthorize("hasRole('Customer')")
    @Transactional
    ApiResponse<ReviewDto> create(@RequestBody CreateReviewRequest request) {
        var booking = bookings.findDetailedById(request.bookingId())
                .orElseThrow(() -> new IllegalArgumentException("Booking not found"));
        var userId = currentUser.requireUserId();
        if (!booking.getCustomer().getId().equals(userId)) {
            throw new IllegalArgumentException("Booking not found");
        }
        if (booking.getStatus() != BookingStatus.COMPLETED && booking.getStatus() != BookingStatus.CHECKED_OUT) {
            throw new IllegalArgumentException("Only completed bookings can be reviewed");
        }
        if (reviews.existsByBookingIdAndCustomerId(booking.getId(), userId)) {
            throw new IllegalArgumentException("Booking has already been reviewed");
        }
        if (reviews.existsByCustomerIdAndHotelId(userId, booking.getRoom().getHotel().getId())) {
            throw new IllegalArgumentException("Hotel has already been reviewed by this customer");
        }
        if (request.rating() < 1 || request.rating() > 5) {
            throw new IllegalArgumentException("Rating must be between 1 and 5");
        }
        var customer = new User();
        customer.setId(userId);
        var review = new Review();
        review.setBooking(booking);
        review.setCustomer(customer);
        review.setRoom(booking.getRoom());
        review.setRating(request.rating());
        review.setComment(request.comment());
        review.setVisible(true);
        review.setCreatedAt(Instant.now());
        var saved = reviews.save(review);
        notificationService.create(booking.getRoom().getHotel().getOwner().getId(), "New review",
                "A customer reviewed booking #" + booking.getId(), NotificationType.REVIEW, "Review", saved.getId());
        return ApiResponse.ok("Review created", mapper.toReviewDto(saved));
    }

    @PostMapping("/{id}/reply")
    @PreAuthorize("hasRole('Owner')")
    @Transactional
    ApiResponse<ReviewDto> ownerReply(@PathVariable Integer id, @RequestBody OwnerReplyRequest request) {
        var review = reviews.findById(id).orElseThrow(() -> new IllegalArgumentException("Review not found"));
        if (!review.getRoom().getHotel().getOwner().getId().equals(currentUser.requireUserId())) {
            throw new IllegalArgumentException("Review not found");
        }
        review.setOwnerReply(request.reply());
        review.setOwnerRepliedAt(Instant.now());
        notificationService.create(review.getCustomer().getId(), "Owner replied to your review",
                "The hotel owner replied to your review.", NotificationType.REVIEW, "Review", id);
        return ApiResponse.ok("Reply saved", mapper.toReviewDto(reviews.save(review)));
    }

    @PostMapping("/{id}/report")
    @PreAuthorize("hasAnyRole('Customer','Owner')")
    @Transactional
    ApiResponse<ReviewDto> report(@PathVariable Integer id, @RequestBody ReportReviewRequest request) {
        var review = reviews.findById(id).orElseThrow(() -> new IllegalArgumentException("Review not found"));
        review.setReported(true);
        review.setReportReason(request.reason());
        return ApiResponse.ok("Review reported", mapper.toReviewDto(reviews.save(review)));
    }

    @PostMapping("/{id}/moderate")
    @PreAuthorize("hasRole('Admin')")
    @Transactional
    ApiResponse<ReviewDto> moderate(@PathVariable Integer id, @RequestBody ModerateReviewRequest request) {
        var review = reviews.findById(id).orElseThrow(() -> new IllegalArgumentException("Review not found"));
        review.setVisible(request.visible());
        review.setModeratedAt(Instant.now());
        return ApiResponse.ok("Review moderated", mapper.toReviewDto(reviews.save(review)));
    }
}

@RestController
@RequestMapping("/api/rooms")
class RoomController extends CrudController<Room> {
    private final RoomRepository rooms;
    private final HotelRepository hotels;
    private final DtoMapper mapper;
    private final CurrentUserService currentUser;

    RoomController(RoomRepository repository, HotelRepository hotels, DtoMapper mapper, CurrentUserService currentUser) {
        super(repository);
        this.rooms = repository;
        this.hotels = hotels;
        this.mapper = mapper;
        this.currentUser = currentUser;
    }

    @Override
    @GetMapping
    @Transactional(readOnly = true)
    public ApiResponse<List<RoomDto>> getAll() {
        return ApiResponse.ok(rooms.findAll().stream().map(mapper::toRoomDto).toList());
    }

    @GetMapping("/by-hotel")
    ApiResponse<List<RoomDto>> byHotel(@RequestParam Integer hotelId) {
        return ApiResponse.ok(rooms.findByHotelId(hotelId).stream().map(mapper::toRoomDto).toList());
    }

    @GetMapping("/by-room-type")
    ApiResponse<List<RoomDto>> byRoomType(@RequestParam Integer roomTypeId) {
        return ApiResponse.ok(rooms.findByRoomTypeId(roomTypeId).stream().map(mapper::toRoomDto).toList());
    }

    @GetMapping("/owner")
    @PreAuthorize("hasRole('Owner')")
    ApiResponse<List<RoomDto>> ownerRooms() {
        return ApiResponse.ok(rooms.findByHotelOwnerId(currentUser.requireUserId()).stream().map(mapper::toRoomDto).toList());
    }

    @PostMapping("/owner")
    @PreAuthorize("hasRole('Owner')")
    ApiResponse<RoomDto> createOwnerRoom(@RequestBody Room room) {
        requireOwnedHotel(room.getHotel().getId());
        room.setCreatedAt(Instant.now());
        return ApiResponse.ok("Created", mapper.toRoomDto(rooms.save(room)));
    }

    @PutMapping("/owner/{id}")
    @PreAuthorize("hasRole('Owner')")
    ApiResponse<RoomDto> updateOwnerRoom(@PathVariable Integer id, @RequestBody Room request) {
        var room = rooms.findDetailedById(id).orElseThrow(() -> new IllegalArgumentException("Room not found"));
        if (!room.getHotel().getOwner().getId().equals(currentUser.requireUserId())) {
            throw new IllegalArgumentException("Room not found");
        }
        room.setRoomType(request.getRoomType());
        room.setRoomNumber(request.getRoomNumber());
        room.setCapacity(request.getCapacity());
        room.setPrice(request.getPrice());
        room.setSeasonalPrice(request.getSeasonalPrice());
        room.setPromotionPrice(request.getPromotionPrice());
        room.setAmenities(request.getAmenities());
        room.setStatus(request.getStatus());
        return ApiResponse.ok("Updated", mapper.toRoomDto(rooms.save(room)));
    }

    @DeleteMapping("/owner/{id}")
    @PreAuthorize("hasRole('Owner')")
    ApiResponse<Void> deleteOwnerRoom(@PathVariable Integer id) {
        var room = rooms.findDetailedById(id).orElseThrow(() -> new IllegalArgumentException("Room not found"));
        if (!room.getHotel().getOwner().getId().equals(currentUser.requireUserId())) {
            throw new IllegalArgumentException("Room not found");
        }
        room.setDeleted(true);
        room.setStatus(RoomStatus.UNAVAILABLE);
        rooms.save(room);
        return ApiResponse.ok("Deleted", null);
    }

    private void requireOwnedHotel(Integer hotelId) {
        var hotel = hotels.findById(hotelId).orElseThrow(() -> new IllegalArgumentException("Hotel not found"));
        if (hotel.getOwner() == null || !hotel.getOwner().getId().equals(currentUser.requireUserId())) {
            throw new IllegalArgumentException("Hotel not found");
        }
    }
}

@RestController
@RequestMapping("/api/room-types")
class RoomTypeController extends CrudController<RoomType> {
    private final RoomTypeRepository roomTypes;
    private final DtoMapper mapper;

    RoomTypeController(RoomTypeRepository repository, DtoMapper mapper) {
        super(repository);
        this.roomTypes = repository;
        this.mapper = mapper;
    }

    @GetMapping("/by-hotel")
    ApiResponse<List<RoomTypeDto>> byHotel(@RequestParam Integer hotelId) {
        return ApiResponse.ok(roomTypes.findByHotelId(hotelId).stream().map(mapper::toRoomTypeDto).toList());
    }
}

@RestController
@RequestMapping("/api/time-slots")
class TimeSlotController extends CrudController<TimeSlot> {
    private final TimeSlotRepository timeSlots;
    private final RoomRepository rooms;
    private final BookingRepository bookings;
    private final DtoMapper mapper;

    TimeSlotController(TimeSlotRepository repository, RoomRepository rooms, BookingRepository bookings, DtoMapper mapper) {
        super(repository);
        this.timeSlots = repository;
        this.rooms = rooms;
        this.bookings = bookings;
        this.mapper = mapper;
    }

    @GetMapping("/hotel/{hotelId}")
    @Transactional(readOnly = true)
    ApiResponse<List<TimeSlotDto>> byHotel(@PathVariable Integer hotelId) {
        return ApiResponse.ok(timeSlots.findByRoomHotelId(hotelId).stream().map(mapper::toTimeSlotDto).toList());
    }

    @GetMapping("/room/{roomId}")
    @Transactional(readOnly = true)
    ApiResponse<List<TimeSlotDto>> byRoom(@PathVariable Integer roomId) {
        return ApiResponse.ok(timeSlots.findByRoomId(roomId).stream().map(mapper::toTimeSlotDto).toList());
    }

    @GetMapping("/room/{roomId}/availability")
    @Transactional(readOnly = true)
    ApiResponse<List<RoomAvailabilityDto>> availability(@PathVariable Integer roomId,
                                                        @RequestParam LocalDate from,
                                                        @RequestParam LocalDate to,
                                                        @RequestParam(required = false) Integer excludedBookingId) {
        if (to.isBefore(from)) {
            throw new IllegalArgumentException("End date must be after start date");
        }
        if (Duration.between(from.atStartOfDay(), to.plusDays(1).atStartOfDay()).toDays() > 370) {
            throw new IllegalArgumentException("Availability range is too large");
        }

        var room = rooms.findById(roomId).orElseThrow(() -> new IllegalArgumentException("Room not found"));
        var roomBookable = !room.isDeleted() && room.getStatus() == RoomStatus.AVAILABLE;
        var items = new ArrayList<RoomAvailabilityDto>();
        for (var day = from; !day.isAfter(to); day = day.plusDays(1)) {
            var start = day.atStartOfDay(ZoneOffset.UTC).toInstant();
            var end = day.plusDays(1).atStartOfDay(ZoneOffset.UTC).toInstant();
            var available = roomBookable && !bookings.hasOverlappingBooking(roomId, start, end, excludedBookingId);
            items.add(new RoomAvailabilityDto(day.toString(), available));
        }
        return ApiResponse.ok(items);
    }

    record RoomAvailabilityDto(String date, boolean available) {
    }
}
