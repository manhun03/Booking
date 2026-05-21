package com.doan.hotelparking.controller;

import com.doan.hotelparking.common.ApiResponse;
import com.doan.hotelparking.domain.entity.Booking;
import com.doan.hotelparking.domain.enums.BookingStatus;
import com.doan.hotelparking.repository.BookingRepository;
import com.doan.hotelparking.security.HasPermission;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.time.Instant;

@RestController
@RequestMapping("/api/admin")
@PreAuthorize("hasRole('Admin')")
public class AdminController {
    private final BookingRepository bookings;

    public AdminController(BookingRepository bookings) {
        this.bookings = bookings;
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
}
