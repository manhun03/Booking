package com.doan.hotelparking.dto.statistics;

import java.math.BigDecimal;

public record TopRoomDto(Integer roomId, String roomName, int bookingCount, BigDecimal revenue) {
}
