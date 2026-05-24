package com.doan.hotelparking.dto.review;

public final class ReviewDtos {
    private ReviewDtos() {}

    public record CreateReviewRequest(Integer bookingId, byte rating, String comment) {}
    public record OwnerReplyRequest(String reply) {}
    public record ReportReviewRequest(String reason) {}
    public record ModerateReviewRequest(boolean visible) {}
}
