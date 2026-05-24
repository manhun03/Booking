package com.doan.hotelparking.controller;

import com.doan.hotelparking.common.ApiResponse;
import com.doan.hotelparking.common.ApiPagedResponse;
import com.doan.hotelparking.domain.entity.*;
import com.doan.hotelparking.domain.enums.BookingStatus;
import com.doan.hotelparking.domain.enums.PaymentStatus;
import com.doan.hotelparking.domain.enums.RoomStatus;
import com.doan.hotelparking.dto.booking.BookingDto;
import com.doan.hotelparking.dto.booking.CancelBookingRequest;
import com.doan.hotelparking.dto.booking.CustomerCreateBookingRequest;
import com.doan.hotelparking.dto.hotel.RoomDto;
import com.doan.hotelparking.repository.*;
import com.doan.hotelparking.security.HasPermission;
import com.doan.hotelparking.service.CurrentUserService;
import com.doan.hotelparking.service.DtoMapper;
import jakarta.validation.Valid;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.*;
import org.springframework.data.domain.PageRequest;

import java.math.BigDecimal;
import java.time.Duration;
import java.time.Instant;
import java.util.List;

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

    BookingController(BookingRepository repository,
                      RoomRepository rooms,
                      TimeSlotRepository timeSlots,
                      PaymentRepository payments,
                      OwnerSettingRepository ownerSettings,
                      CurrentUserService currentUser,
                      DtoMapper mapper) {
        this.bookings = repository;
        this.rooms = rooms;
        this.timeSlots = timeSlots;
        this.payments = payments;
        this.ownerSettings = ownerSettings;
        this.currentUser = currentUser;
        this.mapper = mapper;
    }

    @GetMapping
    @PreAuthorize("hasAnyRole('Admin','Owner')")
    @HasPermission("booking.read")
    ApiPagedResponse<BookingDto> getAll(@RequestParam(defaultValue = "1") int pageIndex,
                                        @RequestParam(defaultValue = "20") int pageSize) {
        var page = bookings.findAll(PageRequest.of(Math.max(pageIndex, 1) - 1, Math.min(Math.max(pageSize, 1), 100)));
        return ApiPagedResponse.ok(page.getContent().stream().map(mapper::toBookingDto).toList(),
                pageIndex, pageSize, page.getTotalElements());
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
        booking.setNote(request.note());
        booking.setStatus(paidAmount.compareTo(totalAmount) >= 0 ? BookingStatus.CONFIRMED : BookingStatus.PENDING);
        booking.setCreatedAt(Instant.now());
        booking.setUpdatedAt(Instant.now());
        var saved = bookings.save(booking);
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
        booking.setCancelledAt(Instant.now());
        booking.setUpdatedAt(Instant.now());
        return ApiResponse.ok("Booking cancelled", mapper.toBookingDto(bookings.save(booking)));
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
}

@RestController
@RequestMapping("/api/payments")
class PaymentController extends CrudController<Payment> {
    PaymentController(PaymentRepository repository) {
        super(repository);
    }
}

@RestController
@RequestMapping("/api/reviews")
class ReviewController extends CrudController<Review> {
    ReviewController(ReviewRepository repository) {
        super(repository);
    }
}

@RestController
@RequestMapping("/api/rooms")
class RoomController extends CrudController<Room> {
    private final RoomRepository rooms;
    private final DtoMapper mapper;

    RoomController(RoomRepository repository, DtoMapper mapper) {
        super(repository);
        this.rooms = repository;
        this.mapper = mapper;
    }

    @GetMapping("/by-hotel")
    ApiResponse<List<RoomDto>> byHotel(@RequestParam Integer hotelId) {
        return ApiResponse.ok(rooms.findByHotelId(hotelId).stream().map(mapper::toRoomDto).toList());
    }

    @GetMapping("/by-room-type")
    ApiResponse<List<RoomDto>> byRoomType(@RequestParam Integer roomTypeId) {
        return ApiResponse.ok(rooms.findByRoomTypeId(roomTypeId).stream().map(mapper::toRoomDto).toList());
    }
}

@RestController
@RequestMapping("/api/room-types")
class RoomTypeController extends CrudController<RoomType> {
    private final RoomTypeRepository roomTypes;

    RoomTypeController(RoomTypeRepository repository) {
        super(repository);
        this.roomTypes = repository;
    }

    @GetMapping("/by-hotel")
    ApiResponse<List<RoomType>> byHotel(@RequestParam Integer hotelId) {
        return ApiResponse.ok(roomTypes.findByHotelId(hotelId));
    }
}

@RestController
@RequestMapping("/api/time-slots")
class TimeSlotController extends CrudController<TimeSlot> {
    private final TimeSlotRepository timeSlots;

    TimeSlotController(TimeSlotRepository repository) {
        super(repository);
        this.timeSlots = repository;
    }

    @GetMapping("/hotel/{hotelId}")
    ApiResponse<List<TimeSlot>> byHotel(@PathVariable Integer hotelId) {
        return ApiResponse.ok(timeSlots.findByRoomHotelId(hotelId));
    }

    @GetMapping("/room/{roomId}")
    ApiResponse<List<TimeSlot>> byRoom(@PathVariable Integer roomId) {
        return ApiResponse.ok(timeSlots.findByRoomId(roomId));
    }
}
