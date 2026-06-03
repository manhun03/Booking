package com.doan.hotelparking.dto.hotel;

public record HotelDto(
        Integer id,
        Integer ownerId,
        Integer wardId,
        String name,
        String street,
        String phone,
        String description,
        String status,
        boolean isDeleted,
        String provinceName,
        String wardName
) {
}
