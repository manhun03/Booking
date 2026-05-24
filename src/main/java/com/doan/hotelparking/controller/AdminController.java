package com.doan.hotelparking.controller;

import com.doan.hotelparking.common.ApiResponse;
import com.doan.hotelparking.domain.entity.Booking;
import com.doan.hotelparking.domain.enums.HotelStatus;
import com.doan.hotelparking.domain.enums.BookingStatus;
import com.doan.hotelparking.domain.enums.UserStatus;
import com.doan.hotelparking.repository.BookingRepository;
import com.doan.hotelparking.repository.HotelRepository;
import com.doan.hotelparking.repository.UserRepository;
import com.doan.hotelparking.security.HasPermission;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.time.Instant;

@RestController
@RequestMapping("/api/admin")
@PreAuthorize("hasRole('Admin')")
public class AdminController {
    private final BookingRepository bookings;
    private final HotelRepository hotels;
    private final UserRepository users;

    public AdminController(BookingRepository bookings, HotelRepository hotels, UserRepository users) {
        this.bookings = bookings;
        this.hotels = hotels;
        this.users = users;
    }

    @GetMapping("/dashboard")
    @HasPermission("system.manage")
    public ApiResponse<java.util.Map<String, Object>> dashboard() {
        var totalBookings = bookings.count();
        var completedBookings = bookings.findAll().stream().filter(b -> b.getStatus() == BookingStatus.COMPLETED).count();
        var cancelledBookings = bookings.findAll().stream().filter(b -> b.getStatus() == BookingStatus.CANCELLED).count();
        var totalRevenue = bookings.findAll().stream()
                .filter(b -> b.getStatus() == BookingStatus.CONFIRMED || b.getStatus() == BookingStatus.COMPLETED)
                .map(Booking::getPaidAmount)
                .reduce(java.math.BigDecimal.ZERO, java.math.BigDecimal::add);
        return ApiResponse.ok(java.util.Map.of(
                "users", users.count(),
                "hotels", hotels.count(),
                "bookings", totalBookings,
                "completedBookings", completedBookings,
                "cancelledBookings", cancelledBookings,
                "revenue", totalRevenue));
    }

    @PatchMapping("/{id}/force-complete")
    @HasPermission("booking.force_complete")
    public ApiResponse<Booking> forceComplete(@PathVariable Integer id) {
        var booking = bookings.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Booking not found"));
        booking.setStatus(BookingStatus.COMPLETED);
        booking.setPaidAmount(booking.getTotalAmount());
        booking.setUpdatedAt(Instant.now());
        return ApiResponse.ok("Booking force completed", bookings.save(booking));
    }

    @PatchMapping("/hotels/{id}/approve")
    @HasPermission("hotel.manage")
    public ApiResponse<?> approveHotel(@PathVariable Integer id) {
        var hotel = hotels.findById(id).orElseThrow(() -> new IllegalArgumentException("Hotel not found"));
        hotel.setStatus(HotelStatus.ACTIVE);
        hotel.setUpdatedAt(Instant.now());
        return ApiResponse.ok("Hotel approved", hotels.save(hotel));
    }

    @PatchMapping("/hotels/{id}/reject")
    @HasPermission("hotel.manage")
    public ApiResponse<?> rejectHotel(@PathVariable Integer id) {
        var hotel = hotels.findById(id).orElseThrow(() -> new IllegalArgumentException("Hotel not found"));
        hotel.setStatus(HotelStatus.REJECTED);
        hotel.setUpdatedAt(Instant.now());
        return ApiResponse.ok("Hotel rejected", hotels.save(hotel));
    }

    @PatchMapping("/hotels/{id}/lock")
    @HasPermission("hotel.manage")
    public ApiResponse<?> lockHotel(@PathVariable Integer id) {
        var hotel = hotels.findById(id).orElseThrow(() -> new IllegalArgumentException("Hotel not found"));
        hotel.setStatus(HotelStatus.SUSPENDED);
        hotel.setUpdatedAt(Instant.now());
        return ApiResponse.ok("Hotel locked", hotels.save(hotel));
    }

    @PatchMapping("/hotels/{id}/unlock")
    @HasPermission("hotel.manage")
    public ApiResponse<?> unlockHotel(@PathVariable Integer id) {
        var hotel = hotels.findById(id).orElseThrow(() -> new IllegalArgumentException("Hotel not found"));
        hotel.setStatus(HotelStatus.ACTIVE);
        hotel.setUpdatedAt(Instant.now());
        return ApiResponse.ok("Hotel unlocked", hotels.save(hotel));
    }

    @PatchMapping("/users/{id}/lock")
    @HasPermission("user.manage")
    public ApiResponse<?> lockUser(@PathVariable Integer id) {
        var user = users.findById(id).orElseThrow(() -> new IllegalArgumentException("User not found"));
        user.setStatus(UserStatus.INACTIVE);
        user.setUpdatedAt(Instant.now());
        return ApiResponse.ok("User locked", users.save(user));
    }

    @PatchMapping("/users/{id}/unlock")
    @HasPermission("user.manage")
    public ApiResponse<?> unlockUser(@PathVariable Integer id) {
        var user = users.findById(id).orElseThrow(() -> new IllegalArgumentException("User not found"));
        user.setStatus(UserStatus.ACTIVE);
        user.setUpdatedAt(Instant.now());
        return ApiResponse.ok("User unlocked", users.save(user));
    }
}
