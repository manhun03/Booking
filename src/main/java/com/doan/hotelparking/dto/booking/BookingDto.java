package com.doan.hotelparking.dto.booking;

import java.math.BigDecimal;
import java.time.Instant;

public record BookingDto(
        Integer id,
        Integer roomId,
        Integer customerId,
        String customerName,
        String customerEmail,
        String customerPhone,
        Instant checkInDate,
        Instant checkOutDate,
        int nightCount,
        int guestCount,
        BigDecimal roomUnitPrice,
        BigDecimal totalAmount,
        BigDecimal paidAmount,
        String customerAddress,
        String note,
        String status,
        boolean reviewed,
        String roomNumber,
        String hotelName,
        Integer ownerId
) {
}
