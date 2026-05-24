package com.doan.hotelparking.service;

import com.doan.hotelparking.domain.entity.Booking;
import com.doan.hotelparking.domain.enums.BookingStatus;
import com.doan.hotelparking.domain.enums.RoomStatus;
import com.doan.hotelparking.dto.statistics.*;
import com.doan.hotelparking.repository.BookingRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.*;
import java.time.temporal.WeekFields;
import java.util.*;
import java.util.stream.Collectors;

@Service
public class StatisticsService {
    private final BookingRepository bookings;

    public StatisticsService(BookingRepository bookings) {
        this.bookings = bookings;
    }

    @Transactional(readOnly = true)
    public OwnerDashboardStatsDto dashboard(Integer ownerId) {
        var allBookings = bookings.findForOwner(ownerId);
        var today = LocalDate.now(ZoneOffset.UTC);
        var todayBookings = allBookings.stream().filter(b -> toDate(b.getCheckInDate()).equals(today)).toList();
        var revenueBookings = allBookings.stream().filter(this::isRevenueBooking).toList();
        var rooms = allBookings.stream().map(Booking::getRoom).collect(Collectors.toMap(r -> r.getId(), r -> r, (a, b) -> a)).values();
        var bookedRoomsToday = todayBookings.stream()
                .filter(b -> b.getStatus() != BookingStatus.CANCELLED)
                .map(b -> b.getRoom().getId())
                .distinct()
                .count();
        var occupancyRate = rooms.isEmpty()
                ? BigDecimal.ZERO
                : BigDecimal.valueOf(bookedRoomsToday).multiply(BigDecimal.valueOf(100))
                .divide(BigDecimal.valueOf(rooms.size()), 2, RoundingMode.HALF_UP);
        var totalRevenue = revenueBookings.stream().map(this::revenueFromBooking).reduce(BigDecimal.ZERO, BigDecimal::add);
        var avgBookingValue = revenueBookings.isEmpty()
                ? BigDecimal.ZERO
                : totalRevenue.divide(BigDecimal.valueOf(revenueBookings.size()), 0, RoundingMode.HALF_UP);

        return new OwnerDashboardStatsDto(
                allBookings.size(),
                todayBookings.size(),
                (int) allBookings.stream().filter(b -> b.getStatus() == BookingStatus.PENDING).count(),
                (int) allBookings.stream().filter(b -> b.getStatus() == BookingStatus.COMPLETED).count(),
                (int) allBookings.stream().filter(b -> b.getStatus() == BookingStatus.CANCELLED).count(),
                (int) rooms.stream().map(r -> r.getHotel().getId()).distinct().count(),
                rooms.size(),
                (int) rooms.stream().filter(r -> r.getStatus() == RoomStatus.AVAILABLE && !r.isDeleted()).count(),
                occupancyRate,
                avgBookingValue);
    }

    @Transactional(readOnly = true)
    public List<RevenueChartDto> revenueChart(Integer ownerId, LocalDate startDate, LocalDate endDate) {
        var grouped = bookings.findForOwner(ownerId).stream()
                .filter(this::isRevenueBooking)
                .filter(b -> !toDate(b.getCheckInDate()).isBefore(startDate) && !toDate(b.getCheckInDate()).isAfter(endDate))
                .collect(Collectors.groupingBy(b -> toDate(b.getCheckInDate())));
        var result = new ArrayList<RevenueChartDto>();
        for (var date = startDate; !date.isAfter(endDate); date = date.plusDays(1)) {
            var dayBookings = grouped.getOrDefault(date, List.of());
            result.add(new RevenueChartDto(date,
                    dayBookings.stream().map(this::revenueFromBooking).reduce(BigDecimal.ZERO, BigDecimal::add),
                    dayBookings.size()));
        }
        return result;
    }

    @Transactional(readOnly = true)
    public List<TopRoomDto> topRooms(Integer ownerId, int limit) {
        var normalizedLimit = Math.max(1, Math.min(limit, 20));
        return bookings.findForOwner(ownerId).stream()
                .filter(this::isRevenueBooking)
                .collect(Collectors.groupingBy(b -> b.getRoom().getId()))
                .values().stream()
                .map(group -> {
                    var first = group.get(0);
                    var roomName = first.getRoom().getRoomNumber() == null || first.getRoom().getRoomNumber().isBlank()
                            ? "Room " + first.getRoom().getId()
                            : first.getRoom().getRoomNumber();
                    return new TopRoomDto(first.getRoom().getId(), roomName, group.size(),
                            group.stream().map(this::revenueFromBooking).reduce(BigDecimal.ZERO, BigDecimal::add));
                })
                .sorted(Comparator.comparingInt(TopRoomDto::bookingCount).reversed()
                        .thenComparing(TopRoomDto::revenue, Comparator.reverseOrder()))
                .limit(normalizedLimit)
                .toList();
    }

    @Transactional(readOnly = true)
    public List<PeakHourDto> peakHours(Integer ownerId) {
        return bookings.findForOwner(ownerId).stream()
                .filter(this::isRevenueBooking)
                .collect(Collectors.groupingBy(b -> LocalDateTime.ofInstant(b.getCreatedAt(), ZoneOffset.UTC).getHour(), Collectors.counting()))
                .entrySet().stream()
                .map(entry -> new PeakHourDto(String.format("%02d:00", entry.getKey()), entry.getValue().intValue()))
                .sorted(Comparator.comparingInt(PeakHourDto::bookingCount).reversed())
                .toList();
    }

    @Transactional(readOnly = true)
    public List<UpcomingBookingDto> upcoming(Integer ownerId, int hoursAhead) {
        var normalizedHoursAhead = Math.max(1, Math.min(hoursAhead, 72));
        var now = Instant.now();
        var future = now.plusSeconds(normalizedHoursAhead * 3600L);
        return bookings.findForOwner(ownerId).stream()
                .filter(b -> b.getStatus() == BookingStatus.CONFIRMED)
                .filter(b -> !b.getCheckInDate().isBefore(now) && !b.getCheckInDate().isAfter(future))
                .sorted(Comparator.comparing(Booking::getCheckInDate))
                .limit(20)
                .map(b -> new UpcomingBookingDto(
                        b.getId(),
                        b.getRoom().getRoomNumber() == null ? "Room " + b.getRoom().getId() : b.getRoom().getRoomNumber(),
                        b.getRoom().getHotel().getName(),
                        ((b.getCustomer().getLastName() == null ? "" : b.getCustomer().getLastName()) + " " +
                                (b.getCustomer().getFirstName() == null ? "" : b.getCustomer().getFirstName())).trim(),
                        b.getCheckInDate(),
                        b.getCheckOutDate(),
                        b.getTotalAmount()))
                .toList();
    }

    @Transactional(readOnly = true)
    public List<RevenueSummaryDto> revenueSummary(Integer ownerId, RevenuePeriodType periodType, LocalDate startDate, LocalDate endDate) {
        var filtered = bookings.findForOwner(ownerId).stream()
                .filter(this::isRevenueBooking)
                .filter(b -> !toDate(b.getCheckInDate()).isBefore(startDate) && !toDate(b.getCheckInDate()).isAfter(endDate))
                .toList();
        return switch (periodType) {
            case WEEKLY -> groupWeekly(filtered, startDate, endDate);
            case MONTHLY -> groupMonthly(filtered, startDate, endDate);
            case QUARTERLY -> groupQuarterly(filtered, startDate, endDate);
            case YEARLY -> groupYearly(filtered, startDate, endDate);
            default -> groupDaily(filtered, startDate, endDate);
        };
    }

    @Transactional(readOnly = true)
    public RevenueComparisonDto revenueComparison(Integer ownerId, RevenuePeriodType periodType, LocalDate currentStart, LocalDate currentEnd) {
        var periodLength = currentEnd.toEpochDay() - currentStart.toEpochDay() + 1;
        var previousEnd = currentStart.minusDays(1);
        var previousStart = previousEnd.minusDays(periodLength - 1);
        var currentData = revenueSummary(ownerId, periodType, currentStart, currentEnd);
        var previousData = revenueSummary(ownerId, periodType, previousStart, previousEnd);
        var currentRevenue = currentData.stream().map(RevenueSummaryDto::totalRevenue).reduce(BigDecimal.ZERO, BigDecimal::add);
        var previousRevenue = previousData.stream().map(RevenueSummaryDto::totalRevenue).reduce(BigDecimal.ZERO, BigDecimal::add);
        var currentBookings = currentData.stream().mapToInt(RevenueSummaryDto::totalBookings).sum();
        var previousBookings = previousData.stream().mapToInt(RevenueSummaryDto::totalBookings).sum();
        var changeAmount = currentRevenue.subtract(previousRevenue);
        var changePercentage = previousRevenue.compareTo(BigDecimal.ZERO) > 0
                ? changeAmount.multiply(BigDecimal.valueOf(100)).divide(previousRevenue, 2, RoundingMode.HALF_UP)
                : BigDecimal.ZERO;
        return new RevenueComparisonDto(currentStart + " - " + currentEnd, previousStart + " - " + previousEnd,
                currentRevenue, previousRevenue, changeAmount, changePercentage, currentBookings, previousBookings);
    }

    private List<RevenueSummaryDto> groupDaily(List<Booking> source, LocalDate startDate, LocalDate endDate) {
        var result = new ArrayList<RevenueSummaryDto>();
        for (var date = startDate; !date.isAfter(endDate); date = date.plusDays(1)) {
            var cursor = date;
            result.add(toSummary(source.stream().filter(b -> toDate(b.getCheckInDate()).equals(cursor)).toList(),
                    cursor.toString(), cursor, cursor));
        }
        return result;
    }

    private List<RevenueSummaryDto> groupWeekly(List<Booking> source, LocalDate startDate, LocalDate endDate) {
        var result = new ArrayList<RevenueSummaryDto>();
        var cursor = startDate;
        while (!cursor.isAfter(endDate)) {
            var weekEnd = cursor.plusDays(6).isAfter(endDate) ? endDate : cursor.plusDays(6);
            var from = cursor;
            var to = weekEnd;
            var week = WeekFields.ISO.weekOfWeekBasedYear();
            result.add(toSummary(source.stream().filter(b -> between(toDate(b.getCheckInDate()), from, to)).toList(),
                    from.getYear() + "-W" + String.format("%02d", from.get(week)), from, to));
            cursor = cursor.plusDays(7);
        }
        return result;
    }

    private List<RevenueSummaryDto> groupMonthly(List<Booking> source, LocalDate startDate, LocalDate endDate) {
        var result = new ArrayList<RevenueSummaryDto>();
        var cursor = startDate.withDayOfMonth(1);
        while (!cursor.isAfter(endDate)) {
            var monthEnd = cursor.plusMonths(1).minusDays(1).isAfter(endDate) ? endDate : cursor.plusMonths(1).minusDays(1);
            var from = cursor;
            var to = monthEnd;
            result.add(toSummary(source.stream().filter(b -> between(toDate(b.getCheckInDate()), from, to)).toList(),
                    from.getYear() + "-" + String.format("%02d", from.getMonthValue()), from, to));
            cursor = cursor.plusMonths(1);
        }
        return result;
    }

    private List<RevenueSummaryDto> groupQuarterly(List<Booking> source, LocalDate startDate, LocalDate endDate) {
        var result = new ArrayList<RevenueSummaryDto>();
        var quarterMonth = ((startDate.getMonthValue() - 1) / 3) * 3 + 1;
        var cursor = LocalDate.of(startDate.getYear(), quarterMonth, 1);
        while (!cursor.isAfter(endDate)) {
            var quarterEnd = cursor.plusMonths(3).minusDays(1).isAfter(endDate) ? endDate : cursor.plusMonths(3).minusDays(1);
            var from = cursor;
            var to = quarterEnd;
            var quarter = ((cursor.getMonthValue() - 1) / 3) + 1;
            result.add(toSummary(source.stream().filter(b -> between(toDate(b.getCheckInDate()), from, to)).toList(),
                    cursor.getYear() + "-Q" + quarter, from, to));
            cursor = cursor.plusMonths(3);
        }
        return result;
    }

    private List<RevenueSummaryDto> groupYearly(List<Booking> source, LocalDate startDate, LocalDate endDate) {
        var result = new ArrayList<RevenueSummaryDto>();
        var cursor = LocalDate.of(startDate.getYear(), 1, 1);
        while (!cursor.isAfter(endDate)) {
            var yearEnd = LocalDate.of(cursor.getYear(), 12, 31).isAfter(endDate) ? endDate : LocalDate.of(cursor.getYear(), 12, 31);
            var from = cursor;
            var to = yearEnd;
            result.add(toSummary(source.stream().filter(b -> between(toDate(b.getCheckInDate()), from, to)).toList(),
                    String.valueOf(cursor.getYear()), from, to));
            cursor = cursor.plusYears(1);
        }
        return result;
    }

    private RevenueSummaryDto toSummary(List<Booking> source, String period, LocalDate startDate, LocalDate endDate) {
        var confirmed = source.stream().filter(b -> b.getStatus() == BookingStatus.CONFIRMED).toList();
        var completed = source.stream().filter(b -> b.getStatus() == BookingStatus.COMPLETED).toList();
        return new RevenueSummaryDto(period, startDate, endDate,
                source.stream().map(this::revenueFromBooking).reduce(BigDecimal.ZERO, BigDecimal::add),
                confirmed.stream().map(this::revenueFromBooking).reduce(BigDecimal.ZERO, BigDecimal::add),
                completed.stream().map(this::revenueFromBooking).reduce(BigDecimal.ZERO, BigDecimal::add),
                source.size(), completed.size(), confirmed.size());
    }

    private boolean between(LocalDate date, LocalDate start, LocalDate end) {
        return !date.isBefore(start) && !date.isAfter(end);
    }

    private boolean isRevenueBooking(Booking booking) {
        return booking.getStatus() == BookingStatus.CONFIRMED || booking.getStatus() == BookingStatus.COMPLETED;
    }

    private BigDecimal revenueFromBooking(Booking booking) {
        if (booking.getStatus() == BookingStatus.COMPLETED) {
            return booking.getTotalAmount();
        }
        return booking.getPaidAmount() == null ? BigDecimal.ZERO : booking.getPaidAmount();
    }

    private LocalDate toDate(Instant instant) {
        return LocalDateTime.ofInstant(instant, ZoneOffset.UTC).toLocalDate();
    }
}
