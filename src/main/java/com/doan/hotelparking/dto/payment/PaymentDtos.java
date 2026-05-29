package com.doan.hotelparking.dto.payment;

import java.math.BigDecimal;

public final class PaymentDtos {
    private PaymentDtos() {}

    public record InitiatePaymentRequest(Integer bookingId, BigDecimal amount, String provider, String method) {}
    public record PaymentWebhookRequest(String transactionCode, String gatewayTransactionId, String status, String failureReason) {}
    public record RefundRequest(BigDecimal amount, String reason) {}
    public record PaymentResult(Integer paymentId, String transactionCode, String provider, String status, String checkoutUrl) {}
}
