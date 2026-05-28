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
class CouponController {
    private final CouponRepository coupons;

    CouponController(CouponRepository repository) {
        this.coupons = repository;
    }

    @GetMapping
    @PreAuthorize("hasRole('Admin')")
    ApiResponse<List<Coupon>> all() {
        return ApiResponse.ok(coupons.findAll());
    }

    @GetMapping("/{id}")
    @PreAuthorize("hasRole('Admin')")
    ApiResponse<Coupon> byId(@PathVariable Integer id) {
        return ApiResponse.ok(coupons.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Coupon not found")));
    }

    @PostMapping
    @PreAuthorize("hasRole('Admin')")
    ApiResponse<Coupon> create(@RequestBody Coupon request) {
        return ApiResponse.ok("Created", coupons.save(request));
    }

    @PutMapping("/{id}")
    @PreAuthorize("hasRole('Admin')")
    ApiResponse<Coupon> update(@PathVariable Integer id, @RequestBody Coupon request) {
        var coupon = coupons.findById(id).orElseThrow(() -> new IllegalArgumentException("Coupon not found"));
        coupon.setCode(request.getCode());
        coupon.setDescription(request.getDescription());
        coupon.setDiscountType(request.getDiscountType());
        coupon.setDiscountValue(request.getDiscountValue());
        coupon.setMaxDiscountAmount(request.getMaxDiscountAmount());
        coupon.setMinOrderAmount(request.getMinOrderAmount());
        coupon.setStartAt(request.getStartAt());
        coupon.setEndAt(request.getEndAt());
        coupon.setMaxUses(request.getMaxUses());
        coupon.setUsedCount(request.getUsedCount());
        coupon.setActive(request.isActive());
        return ApiResponse.ok("Updated", coupons.save(coupon));
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('Admin')")
    ApiResponse<Void> delete(@PathVariable Integer id) {
        coupons.deleteById(id);
        return ApiResponse.ok("Deleted", null);
    }

    @GetMapping("/active")
    ApiResponse<List<Coupon>> active() {
        var now = Instant.now();
        return ApiResponse.ok(coupons.findAll().stream()
                .filter(Coupon::isActive)
                .filter(coupon -> coupon.getStartAt() == null || !now.isBefore(coupon.getStartAt()))
                .filter(coupon -> coupon.getEndAt() == null || !now.isAfter(coupon.getEndAt()))
                .filter(coupon -> coupon.getMaxUses() == null || coupon.getUsedCount() < coupon.getMaxUses())
                .toList());
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
    ApiResponse<ChatMessageDto> send(@RequestBody SendMessageRequest request) {
        var message = chatMessages.send(currentUser.requireUserId(),
                new SendChatMessageRequest(request.receiverId(), request.bookingId(), request.content()));
        publishMessage(message);
        return ApiResponse.ok("Message sent", message);
    }

    @PostMapping("/{id}/read")
    ApiResponse<ChatMessageDto> markRead(@PathVariable Integer id) {
        var message = chatMessages.markRead(currentUser.requireUserId(), id);
        publishMessage(message);
        return ApiResponse.ok("Message read", message);
    }

    record SendMessageRequest(Integer receiverId, Integer bookingId, String content) {}

    private void publishMessage(ChatMessageDto message) {
        messagingTemplate.convertAndSendToUser(message.senderId().toString(), "/queue/messages", message);
        messagingTemplate.convertAndSendToUser(message.receiverId().toString(), "/queue/messages", message);
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
