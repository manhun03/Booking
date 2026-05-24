package com.doan.hotelparking.dto.user;

import java.time.Instant;

public record UserDto(
        Integer id,
        String lastName,
        String firstName,
        String email,
        String phone,
        String avatarUrl,
        String status,
        Instant createdAt
) {
}
