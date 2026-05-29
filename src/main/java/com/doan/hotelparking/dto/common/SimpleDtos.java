package com.doan.hotelparking.dto.common;

import java.math.BigDecimal;
import java.time.Instant;

public final class SimpleDtos {
    private SimpleDtos() {
    }

    public record NotificationDto(
            Integer id,
            Integer userId,
            Integer senderId,
            String title,
            String message,
            String type,
            String relatedTable,
            Integer relatedId,
            boolean read,
            Instant createdAt,
            Instant readAt) {
    }

    public record ChatMessageDto(
            Integer id,
            Integer senderId,
            Integer receiverId,
            Integer bookingId,
            String content,
            boolean read,
            Instant createdAt,
            Instant readAt) {
    }

    public record PaymentDto(
            Integer id,
            Integer bookingId,
            BigDecimal amount,
            String method,
            String provider,
            String status,
            String transactionCode,
            String gatewayTransactionId,
            String checkoutUrl,
            String failureReason,
            BigDecimal refundedAmount,
            String note,
            Instant paidAt,
            Instant refundedAt,
            Instant createdAt,
            Instant updatedAt) {
    }

    public record RoleDto(
            Integer id,
            String name,
            String description,
            boolean active,
            Instant createdAt,
            Instant updatedAt) {
    }

    public record PermissionDto(
            Integer id,
            String permissionKey,
            String description,
            String module,
            Instant createdAt,
            Instant updatedAt) {
    }

    public record ReviewDto(
            Integer id,
            Integer bookingId,
            Integer customerId,
            Integer roomId,
            Byte rating,
            String comment,
            String ownerReply,
            Instant ownerRepliedAt,
            boolean reported,
            String reportReason,
            boolean visible,
            Instant moderatedAt,
            Instant createdAt) {
    }

    public record RoomTypeDto(Integer id, String name, String description) {
    }

    public record TimeSlotDto(
            Integer id,
            Integer roomId,
            Instant startDate,
            Instant endDate,
            BigDecimal price,
            boolean active,
            Instant createdAt,
            Instant updatedAt) {
    }
}
