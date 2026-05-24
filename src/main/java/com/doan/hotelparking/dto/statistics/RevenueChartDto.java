package com.doan.hotelparking.dto.statistics;

import java.math.BigDecimal;
import java.time.LocalDate;

public record RevenueChartDto(LocalDate date, BigDecimal revenue, int bookingCount) {
}
