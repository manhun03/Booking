package com.doan.hotelparking.dto.user;

public record UpdateProfileRequest(
        String firstName,
        String lastName,
        String phone,
        String avatarUrl
) {
}
