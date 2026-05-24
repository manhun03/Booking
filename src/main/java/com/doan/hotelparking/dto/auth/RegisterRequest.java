package com.doan.hotelparking.dto.auth;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;

public record RegisterRequest(
        String lastName,
        String firstName,
        @Email @NotBlank String email,
        String phone,
        @NotBlank String password,
        String role
) {
}
