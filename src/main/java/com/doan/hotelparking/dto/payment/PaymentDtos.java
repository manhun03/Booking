package com.doan.hotelparking.dto.payment;

import java.math.BigDecimal;
import java.time.Instant;

public final class PaymentDtos {
    private PaymentDtos() {}

    public record InitiatePaymentRequest(Integer bookingId, BigDecimal amount, String provider, String method) {}
    public record PaymentWebhookRequest(String transactionCode, String gatewayTransactionId, String status, String failureReason) {}
    public record RefundRequest(BigDecimal amount, String reason) {}
    public record PaymentResult(Integer paymentId, String transactionCode, String provider, String status, String checkoutUrl) {}
    public record SavePaymentCardRequest(String cardNumber, String cardHolderName, String expiry, String brand, Boolean defaultCard) {}
    public record PaymentCardDto(
            Integer id,
            Integer customerId,
            String cardHolderName,
            String brand,
            String last4,
            Integer expiryMonth,
            Integer expiryYear,
            boolean defaultCard,
            Instant createdAt,
            Instant updatedAt) {}
}
