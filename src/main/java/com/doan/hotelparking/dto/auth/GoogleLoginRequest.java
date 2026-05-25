package com.doan.hotelparking.dto.auth;

import jakarta.validation.constraints.NotBlank;

public record GoogleLoginRequest(
        @NotBlank String idToken,
        String role
) {
}
