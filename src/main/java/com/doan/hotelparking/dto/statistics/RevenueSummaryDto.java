package com.doan.hotelparking.dto.statistics;

import java.math.BigDecimal;
import java.time.LocalDate;

public record RevenueSummaryDto(
        String period,
        LocalDate startDate,
        LocalDate endDate,
        BigDecimal totalRevenue,
        BigDecimal confirmedRevenue,
        BigDecimal completedRevenue,
        int totalBookings,
        int completedBookings,
        int confirmedBookings
) {
}
