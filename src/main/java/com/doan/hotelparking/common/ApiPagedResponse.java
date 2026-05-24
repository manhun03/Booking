package com.doan.hotelparking.common;

import java.util.List;

public record ApiPagedResponse<T>(
        boolean success,
        String message,
        int statusCode,
        List<T> data,
        int pageIndex,
        int pageSize,
        long totalRecords,
        int totalPages,
        boolean hasPreviousPage,
        boolean hasNextPage
) {
    public static <T> ApiPagedResponse<T> ok(List<T> data, int pageIndex, int pageSize, long totalRecords) {
        var totalPages = pageSize <= 0 ? 0 : (int) Math.ceil((double) totalRecords / pageSize);
        return new ApiPagedResponse<>(
                true,
                "Success",
                200,
                data,
                pageIndex,
                pageSize,
                totalRecords,
                totalPages,
                pageIndex > 1,
                pageIndex < totalPages);
    }
}
