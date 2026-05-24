package com.doan.hotelparking.dto.booking;

import java.time.Instant;

public final class BookingActionRequests {
    private BookingActionRequests() {}

    public record RejectBookingRequest(String reason) {}
    public record ChangeBookingRequest(Integer roomId, Instant checkInDate, Instant checkOutDate, Integer guestCount, String note) {}
}
