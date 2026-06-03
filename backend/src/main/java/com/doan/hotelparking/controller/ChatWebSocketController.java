package com.doan.hotelparking.controller;

import com.doan.hotelparking.dto.chat.ChatMessageRequests.MarkChatMessageReadRequest;
import com.doan.hotelparking.dto.chat.ChatMessageRequests.SendChatMessageRequest;
import com.doan.hotelparking.dto.common.SimpleDtos.ChatMessageDto;
import com.doan.hotelparking.service.ChatMessageService;
import jakarta.validation.Valid;
import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.messaging.handler.annotation.Payload;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Controller;

import java.security.Principal;

@Controller
public class ChatWebSocketController {
    private final ChatMessageService chatMessages;
    private final SimpMessagingTemplate messagingTemplate;

    public ChatWebSocketController(ChatMessageService chatMessages, SimpMessagingTemplate messagingTemplate) {
        this.chatMessages = chatMessages;
        this.messagingTemplate = messagingTemplate;
    }

    @MessageMapping("/chat.send")
    public void send(@Valid @Payload SendChatMessageRequest request, Principal principal) {
        var message = chatMessages.send(userId(principal), request);
        publishMessage(message);
    }

    @MessageMapping("/chat.read")
    public void markRead(@Valid @Payload MarkChatMessageReadRequest request, Principal principal) {
        var message = chatMessages.markRead(userId(principal), request.messageId());
        publishMessage(message);
    }

    private void publishMessage(ChatMessageDto message) {
        messagingTemplate.convertAndSendToUser(message.senderId().toString(), "/queue/messages", message);
        messagingTemplate.convertAndSendToUser(message.receiverId().toString(), "/queue/messages", message);
    }

    private Integer userId(Principal principal) {
        if (principal == null || principal.getName() == null) {
            throw new IllegalArgumentException("Unable to resolve current user from WebSocket session");
        }
        return Integer.parseInt(principal.getName());
    }
}
