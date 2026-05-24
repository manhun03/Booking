package com.doan.hotelparking.dto.hotel;

import java.time.Instant;

public record FavoriteHotelDto(
        Integer id,
        Integer userId,
        Integer hotelId,
        String hotelName,
        String imageUrl,
        Instant createdAt
) {
}
