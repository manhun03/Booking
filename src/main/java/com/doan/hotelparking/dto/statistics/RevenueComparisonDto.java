package com.doan.hotelparking.dto.statistics;

import java.math.BigDecimal;

public record RevenueComparisonDto(
        String currentPeriod,
        String previousPeriod,
        BigDecimal currentRevenue,
        BigDecimal previousRevenue,
        BigDecimal changeAmount,
        BigDecimal changePercentage,
        int currentBookings,
        int previousBookings
) {
}
