package com.doan.hotelparking.dto.hotel;

import java.math.BigDecimal;

public record RoomDto(
        Integer id,
        Integer hotelId,
        Integer roomTypeId,
        String roomNumber,
        int capacity,
        BigDecimal price,
        String amenities,
        BigDecimal seasonalPrice,
        BigDecimal promotionPrice,
        String status,
        boolean isDeleted
) {
}
