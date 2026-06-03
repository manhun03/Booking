package com.doan.hotelparking.dto.hotel;

public record HotelImageDto(
        Integer id,
        Integer hotelId,
        String imageUrl,
        String objectKey,
        boolean isPrimary,
        int sortOrder
) {
}
