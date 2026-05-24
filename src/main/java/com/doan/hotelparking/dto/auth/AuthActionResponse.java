package com.doan.hotelparking.dto.auth;

import java.time.Instant;

public record AuthActionResponse(
        String message,
        String token,
        Instant expiresAt
) {
}
