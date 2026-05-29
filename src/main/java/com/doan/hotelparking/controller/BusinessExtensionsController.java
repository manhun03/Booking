package com.doan.hotelparking.controller;

import com.doan.hotelparking.common.ApiResponse;
import com.doan.hotelparking.domain.entity.Booking;
import com.doan.hotelparking.domain.entity.ChatMessage;
import com.doan.hotelparking.domain.entity.Coupon;
import com.doan.hotelparking.domain.entity.User;
import com.doan.hotelparking.dto.common.SimpleDtos.ChatMessageDto;
import com.doan.hotelparking.repository.AuditLogRepository;
import com.doan.hotelparking.repository.ChatMessageRepository;
import com.doan.hotelparking.repository.CouponRepository;
import com.doan.hotelparking.service.AuditService;
import com.doan.hotelparking.service.CurrentUserService;
import com.doan.hotelparking.service.DtoMapper;
import jakarta.validation.constraints.NotBlank;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.List;

final class BusinessExtensionsController {
    private BusinessExtensionsController() {}
}

@RestController
@RequestMapping("/api/coupons")
class CouponController extends CrudController<Coupon> {
    private final CouponRepository coupons;

    CouponController(CouponRepository repository) {
        super(repository);
        this.coupons = repository;
    }

    @GetMapping("/validate")
    ApiResponse<CouponValidationResponse> validate(@RequestParam String code, @RequestParam BigDecimal amount) {
        var coupon = coupons.findByCodeIgnoreCase(code).orElseThrow(() -> new IllegalArgumentException("Coupon not found"));
        var now = Instant.now();
        if (!coupon.isActive()
                || (coupon.getStartAt() != null && now.isBefore(coupon.getStartAt()))
                || (coupon.getEndAt() != null && now.isAfter(coupon.getEndAt()))
                || (coupon.getMaxUses() != null && coupon.getUsedCount() >= coupon.getMaxUses())
                || amount.compareTo(coupon.getMinOrderAmount()) < 0) {
            throw new IllegalArgumentException("Coupon is not valid");
        }
        var discount = "PERCENT".equalsIgnoreCase(coupon.getDiscountType())
                ? amount.multiply(coupon.getDiscountValue()).divide(BigDecimal.valueOf(100))
                : coupon.getDiscountValue();
        if (coupon.getMaxDiscountAmount() != null && discount.compareTo(coupon.getMaxDiscountAmount()) > 0) {
            discount = coupon.getMaxDiscountAmount();
        }
        return ApiResponse.ok(new CouponValidationResponse(coupon.getCode(), discount, amount.subtract(discount).max(BigDecimal.ZERO)));
    }

    record CouponValidationResponse(String code, BigDecimal discountAmount, BigDecimal finalAmount) {}
}

@RestController
@RequestMapping("/api/messages")
class ChatController {
    private final ChatMessageRepository messages;
    private final CurrentUserService currentUser;
    private final DtoMapper mapper;

    ChatController(ChatMessageRepository messages, CurrentUserService currentUser, DtoMapper mapper) {
        this.messages = messages;
        this.currentUser = currentUser;
        this.mapper = mapper;
    }

    @GetMapping("/conversation/{otherUserId}")
    ApiResponse<List<ChatMessageDto>> conversation(@PathVariable Integer otherUserId) {
        return ApiResponse.ok(messages.conversation(currentUser.requireUserId(), otherUserId).stream()
                .map(mapper::toChatMessageDto)
                .toList());
    }

    @GetMapping("/unread")
    ApiResponse<List<ChatMessageDto>> unread() {
        return ApiResponse.ok(messages.findByReceiverIdAndReadFalseOrderByCreatedAtDesc(currentUser.requireUserId()).stream()
                .map(mapper::toChatMessageDto)
                .toList());
    }

    @PostMapping
    ApiResponse<ChatMessageDto> send(@RequestBody SendMessageRequest request) {
        var sender = new User();
        sender.setId(currentUser.requireUserId());
        var receiver = new User();
        receiver.setId(request.receiverId());
        var message = new ChatMessage();
        message.setSender(sender);
        message.setReceiver(receiver);
        if (request.bookingId() != null) {
            var booking = new Booking();
            booking.setId(request.bookingId());
            message.setBooking(booking);
        }
        message.setContent(request.content());
        return ApiResponse.ok("Message sent", mapper.toChatMessageDto(messages.save(message)));
    }

    @PostMapping("/{id}/read")
    ApiResponse<ChatMessageDto> markRead(@PathVariable Integer id) {
        var message = messages.findById(id).orElseThrow(() -> new IllegalArgumentException("Message not found"));
        if (!message.getReceiver().getId().equals(currentUser.requireUserId())) {
            throw new IllegalArgumentException("Message not found");
        }
        message.setRead(true);
        message.setReadAt(Instant.now());
        return ApiResponse.ok("Message read", mapper.toChatMessageDto(messages.save(message)));
    }

    record SendMessageRequest(Integer receiverId, Integer bookingId, @NotBlank String content) {}
}

@RestController
@RequestMapping("/api/admin/audit-logs")
@PreAuthorize("hasRole('Admin')")
class AuditLogController {
    private final AuditLogRepository logs;
    private final AuditService auditService;
    private final CurrentUserService currentUser;

    AuditLogController(AuditLogRepository logs, AuditService auditService, CurrentUserService currentUser) {
        this.logs = logs;
        this.auditService = auditService;
        this.currentUser = currentUser;
    }

    @GetMapping
    ApiResponse<List<com.doan.hotelparking.domain.entity.AuditLog>> all() {
        auditService.record(currentUser.requireUserId(), "VIEW_AUDIT_LOGS", "AuditLog", null, "Admin viewed audit logs");
        return ApiResponse.ok(logs.findAll());
    }
}
