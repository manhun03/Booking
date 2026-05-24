package com.doan.hotelparking.dto.user;

import jakarta.validation.constraints.NotBlank;

public record UpdateUserAvatarRequest(@NotBlank String avatarUrl) {
}
