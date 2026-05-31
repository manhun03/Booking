package com.doan.hotelparking.controller;

import com.doan.hotelparking.common.ApiResponse;
import com.doan.hotelparking.domain.entity.Coupon;
import com.doan.hotelparking.dto.chat.ChatMessageRequests.SendChatMessageRequest;
import com.doan.hotelparking.dto.common.SimpleDtos.ChatConversationDto;
import com.doan.hotelparking.dto.common.SimpleDtos.ChatMessageDto;
import com.doan.hotelparking.repository.AuditLogRepository;
import com.doan.hotelparking.repository.CouponRepository;
import com.doan.hotelparking.service.AuditService;
import com.doan.hotelparking.service.ChatMessageService;
import com.doan.hotelparking.service.CurrentUserService;
import jakarta.validation.Valid;
import org.springframework.messaging.simp.SimpMessagingTemplate;
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

    @GetMapping("/active")
    ApiResponse<List<Coupon>> active() {
        var now = Instant.now();
        return ApiResponse.ok(coupons.findAll().stream()
                .filter(coupon -> isUsable(coupon, now))
                .toList());
    }

    @GetMapping("/validate")
    ApiResponse<CouponValidationResponse> validate(@RequestParam String code, @RequestParam BigDecimal amount) {
        var coupon = coupons.findByCodeIgnoreCase(code).orElseThrow(() -> new IllegalArgumentException("Coupon not found"));
        var now = Instant.now();
        if (!isUsable(coupon, now) || amount.compareTo(coupon.getMinOrderAmount()) < 0) {
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

    private boolean isUsable(Coupon coupon, Instant now) {
        return coupon.isActive()
                && (coupon.getStartAt() == null || !now.isBefore(coupon.getStartAt()))
                && (coupon.getEndAt() == null || !now.isAfter(coupon.getEndAt()))
                && (coupon.getMaxUses() == null || coupon.getUsedCount() < coupon.getMaxUses());
    }

    record CouponValidationResponse(String code, BigDecimal discountAmount, BigDecimal finalAmount) {}
}

@RestController
@RequestMapping("/api/messages")
class ChatController {
    private final ChatMessageService chatMessages;
    private final CurrentUserService currentUser;
    private final SimpMessagingTemplate messagingTemplate;

    ChatController(ChatMessageService chatMessages, CurrentUserService currentUser, SimpMessagingTemplate messagingTemplate) {
        this.chatMessages = chatMessages;
        this.currentUser = currentUser;
        this.messagingTemplate = messagingTemplate;
    }

    @GetMapping("/conversations")
    ApiResponse<List<ChatConversationDto>> conversations() {
        return ApiResponse.ok(chatMessages.conversations(currentUser.requireUserId()));
    }

    @GetMapping("/contacts")
    ApiResponse<List<ChatConversationDto>> contacts() {
        return ApiResponse.ok(chatMessages.contacts(currentUser.requireUserId()));
    }

    @GetMapping("/conversation/{otherUserId}")
    ApiResponse<List<ChatMessageDto>> conversation(@PathVariable Integer otherUserId) {
        return ApiResponse.ok(chatMessages.conversation(currentUser.requireUserId(), otherUserId));
    }

    @GetMapping("/unread")
    ApiResponse<List<ChatMessageDto>> unread() {
        return ApiResponse.ok(chatMessages.unread(currentUser.requireUserId()));
    }

    @PostMapping
    ApiResponse<ChatMessageDto> send(@Valid @RequestBody SendChatMessageRequest request) {
        var message = chatMessages.send(currentUser.requireUserId(), request);
        publishMessage(message);
        return ApiResponse.ok("Message sent", message);
    }

    @PostMapping("/{id}/read")
    ApiResponse<ChatMessageDto> markRead(@PathVariable Integer id) {
        var message = chatMessages.markRead(currentUser.requireUserId(), id);
        publishMessage(message);
        return ApiResponse.ok("Message read", message);
    }

    private void publishMessage(ChatMessageDto message) {
        if (message.senderId() != null) {
            messagingTemplate.convertAndSendToUser(message.senderId().toString(), "/queue/messages", message);
        }
        if (message.receiverId() != null) {
            messagingTemplate.convertAndSendToUser(message.receiverId().toString(), "/queue/messages", message);
        }
    }
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
