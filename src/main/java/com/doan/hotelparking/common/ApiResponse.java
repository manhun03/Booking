package com.doan.hotelparking.common;

import java.util.List;

public record ApiResponse<T>(boolean success, String message, int statusCode, T data, List<String> errors) {
    public static <T> ApiResponse<T> ok(T data) {
        return new ApiResponse<>(true, "Success", 200, data, null);
    }

    public static <T> ApiResponse<T> ok(String message, T data) {
        return new ApiResponse<>(true, message, 200, data, null);
    }

    public static <T> ApiResponse<T> fail(String message) {
        return fail(message, 400, null);
    }

    public static <T> ApiResponse<T> fail(String message, int statusCode) {
        return fail(message, statusCode, null);
    }

    public static <T> ApiResponse<T> fail(String message, int statusCode, List<String> errors) {
        return new ApiResponse<>(false, message, statusCode, null, errors);
    }
}
