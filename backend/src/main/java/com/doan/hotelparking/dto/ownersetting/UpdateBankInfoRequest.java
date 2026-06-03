package com.doan.hotelparking.dto.ownersetting;

public record UpdateBankInfoRequest(
        String bankName,
        String bankAccountNumber,
        String bankAccountName,
        String bankQrCodeUrl
) {
}
