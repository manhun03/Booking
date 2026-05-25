package com.doan.hotelparking.dto.auth;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;

public record RegisterRequest(
        String lastName,
        String firstName,
        @NotBlank
        @Size(min = 4, max = 20)
        @Pattern(regexp = "^[A-Za-z0-9_]+$", message = "Username must contain only letters, numbers, and underscores")
        String username,
        @Email @NotBlank String email,
        String phone,
        @NotBlank
        @Size(min = 8)
        @Pattern(
                regexp = "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[^A-Za-z0-9]).+$",
                message = "Password must contain uppercase, lowercase, number, and special character"
        )
        String password,
        String role
) {
}
