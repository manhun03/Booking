package com.doan.hotelparking.dto.recommendation;

import java.util.List;

public record RecommendationResponse(
        String recommendationType,
        List<HotelRecommendationDto> hotels,
        String message
) {
}
