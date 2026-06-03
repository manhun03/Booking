package com.doan.hotelparking.dto.chat;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

public final class ChatMessageRequests {
    private ChatMessageRequests() {
    }

    public record SendChatMessageRequest(
            @NotNull Integer receiverId,
            Integer bookingId,
            @NotBlank String content) {
    }

    public record MarkChatMessageReadRequest(@NotNull Integer messageId) {
    }
}
