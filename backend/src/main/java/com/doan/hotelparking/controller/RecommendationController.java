package com.doan.hotelparking.controller;

import com.doan.hotelparking.common.ApiResponse;
import com.doan.hotelparking.dto.recommendation.RecommendationResponse;
import com.doan.hotelparking.service.RecommendationService;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/recommendations")
public class RecommendationController {
    private final RecommendationService recommendations;

    public RecommendationController(RecommendationService recommendations) {
        this.recommendations = recommendations;
    }

    @GetMapping("/similar/{hotelId}")
    public ApiResponse<RecommendationResponse> similar(@PathVariable Integer hotelId,
                                                       @RequestParam(defaultValue = "10") int topK) {
        return ApiResponse.ok(recommendations.similarHotels(hotelId, topK));
    }

    @GetMapping("/new-user")
    public ApiResponse<RecommendationResponse> newUser(@RequestParam(required = false) String province,
                                                       @RequestParam(required = false) String ward,
                                                       @RequestParam(defaultValue = "10") int topK) {
        return ApiResponse.ok(recommendations.newUser(province, ward, topK));
    }

    @GetMapping("/personalized")
    public ApiResponse<RecommendationResponse> personalized(@RequestParam Integer userId,
                                                            @RequestParam(required = false) String province,
                                                            @RequestParam(defaultValue = "10") int topK) {
        return ApiResponse.ok(recommendations.personalized(userId, topK, province));
    }

    @GetMapping("/smart")
    public ApiResponse<RecommendationResponse> smart(@RequestParam(required = false) Integer userId,
                                                     @RequestParam(required = false) Integer hotelId,
                                                     @RequestParam(required = false) String province,
                                                     @RequestParam(required = false) String ward,
                                                     @RequestParam(defaultValue = "10") int topK) {
        if (hotelId != null) {
            return ApiResponse.ok(recommendations.similarHotels(hotelId, topK));
        }
        if (userId != null) {
            return ApiResponse.ok(recommendations.personalized(userId, topK, province));
        }
        return ApiResponse.ok(recommendations.newUser(province, ward, topK));
    }
}
