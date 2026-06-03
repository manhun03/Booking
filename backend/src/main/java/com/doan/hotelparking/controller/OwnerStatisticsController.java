package com.doan.hotelparking.controller;

import com.doan.hotelparking.common.ApiResponse;
import com.doan.hotelparking.dto.statistics.*;
import com.doan.hotelparking.security.HasPermission;
import com.doan.hotelparking.service.CurrentUserService;
import com.doan.hotelparking.service.StatisticsService;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.List;

@RestController
@RequestMapping("/api/statistics/owner")
@PreAuthorize("hasRole('Owner')")
@HasPermission("statistics.read")
public class OwnerStatisticsController {
    private final StatisticsService statistics;
    private final CurrentUserService currentUser;

    public OwnerStatisticsController(StatisticsService statistics, CurrentUserService currentUser) {
        this.statistics = statistics;
        this.currentUser = currentUser;
    }

    @GetMapping("/dashboard")
    public ApiResponse<OwnerDashboardStatsDto> dashboard() {
        return ApiResponse.ok(statistics.dashboard(currentUser.requireUserId()));
    }

    @GetMapping("/revenue")
    public ApiResponse<List<RevenueChartDto>> revenue(
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate startDate,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate endDate) {
        return ApiResponse.ok(statistics.revenueChart(currentUser.requireUserId(), startDate, endDate));
    }

    @GetMapping("/top-rooms")
    public ApiResponse<List<TopRoomDto>> topRooms(@RequestParam(defaultValue = "5") int limit) {
        return ApiResponse.ok(statistics.topRooms(currentUser.requireUserId(), limit));
    }

    @GetMapping("/peak-hours")
    public ApiResponse<List<PeakHourDto>> peakHours() {
        return ApiResponse.ok(statistics.peakHours(currentUser.requireUserId()));
    }

    @GetMapping("/upcoming")
    public ApiResponse<List<UpcomingBookingDto>> upcoming(@RequestParam(defaultValue = "3") int hoursAhead) {
        return ApiResponse.ok(statistics.upcoming(currentUser.requireUserId(), hoursAhead));
    }

    @GetMapping("/revenue-summary")
    public ApiResponse<List<RevenueSummaryDto>> revenueSummary(
            @RequestParam(defaultValue = "DAILY") RevenuePeriodType periodType,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate startDate,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate endDate) {
        return ApiResponse.ok(statistics.revenueSummary(currentUser.requireUserId(), periodType, startDate, endDate));
    }

    @GetMapping("/revenue-comparison")
    public ApiResponse<RevenueComparisonDto> revenueComparison(
            @RequestParam(defaultValue = "DAILY") RevenuePeriodType periodType,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate currentStartDate,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate currentEndDate) {
        return ApiResponse.ok(statistics.revenueComparison(currentUser.requireUserId(), periodType, currentStartDate, currentEndDate));
    }
}
