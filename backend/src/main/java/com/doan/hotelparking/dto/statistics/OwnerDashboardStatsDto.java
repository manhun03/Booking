package com.doan.hotelparking.dto.statistics;

import java.math.BigDecimal;

public record OwnerDashboardStatsDto(
        int totalBookings,
        int todayBookings,
        int pendingBookings,
        int completedBookings,
        int cancelledBookings,
        int totalHotels,
        int totalRooms,
        int activeRooms,
        BigDecimal occupancyRate,
        BigDecimal avgBookingValue
) {
}
