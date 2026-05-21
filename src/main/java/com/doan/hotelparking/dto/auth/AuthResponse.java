package com.doan.hotelparking.dto.auth;

import java.time.Instant;
import java.util.List;

public record AuthResponse(
        Integer userId,
        String fullName,
        String email,
        List<String> roles,
        String accessToken,
        String refreshToken,
        Instant accessTokenExpiresAt
) {
}
