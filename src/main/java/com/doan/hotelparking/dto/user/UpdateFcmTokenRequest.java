package com.doan.hotelparking.dto.user;

import jakarta.validation.constraints.NotBlank;

public record UpdateFcmTokenRequest(@NotBlank String token) {
}
