package com.doan.hotelparking.dto.recommendation;

import java.math.BigDecimal;

public record HotelRecommendationDto(
        Integer id,
        String name,
        Integer ownerId,
        String province,
        String ward,
        BigDecimal avgRoomPrice,
        int roomCount,
        double averageRating,
        int bookingCount,
        double similarityScore,
        String imageUrl,
        boolean active
) {
}
