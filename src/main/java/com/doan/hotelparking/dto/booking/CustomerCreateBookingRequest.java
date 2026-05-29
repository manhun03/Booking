package com.doan.hotelparking.dto.booking;

import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;

import java.math.BigDecimal;
import java.time.Instant;

public record CustomerCreateBookingRequest(
        @NotNull Integer roomId,
        @NotNull Instant checkInDate,
        @NotNull Instant checkOutDate,
        @Min(1) int guestCount,
        BigDecimal paidAmount,
        String note,
        String paymentMethod,
        String transactionCode,
        String paymentNote
) {
}
