package com.doan.hotelparking.dto.statistics;

import java.math.BigDecimal;
import java.time.Instant;

public record UpcomingBookingDto(
        Integer id,
        String roomName,
        String hotelName,
        String customerName,
        Instant checkInDate,
        Instant checkOutDate,
        BigDecimal totalAmount
) {
}
