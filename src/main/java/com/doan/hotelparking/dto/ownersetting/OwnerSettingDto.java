package com.doan.hotelparking.dto.ownersetting;

import java.math.BigDecimal;

public record OwnerSettingDto(
        Integer id,
        Integer ownerId,
        BigDecimal depositRate,
        Integer minBookingNotice,
        boolean allowReview,
        String bankName,
        String bankAccountNumber,
        String bankAccountName,
        String bankQrCodeUrl
) {
}
