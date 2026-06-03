package com.doan.hotelparking.service;

import com.doan.hotelparking.domain.entity.Booking;
import com.doan.hotelparking.domain.entity.ChatMessage;
import com.doan.hotelparking.domain.entity.User;
import com.doan.hotelparking.dto.chat.ChatMessageRequests.SendChatMessageRequest;
import com.doan.hotelparking.dto.common.SimpleDtos.ChatConversationDto;
import com.doan.hotelparking.dto.common.SimpleDtos.ChatMessageDto;
import com.doan.hotelparking.repository.ChatMessageRepository;
import com.doan.hotelparking.repository.UserRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;

@Service
public class ChatMessageService {
    private final ChatMessageRepository messages;
    private final UserRepository users;
    private final DtoMapper mapper;

    public ChatMessageService(ChatMessageRepository messages, UserRepository users, DtoMapper mapper) {
        this.messages = messages;
        this.users = users;
        this.mapper = mapper;
    }

    @Transactional(readOnly = true)
    public List<ChatConversationDto> conversations(Integer userId) {
        var summaries = new LinkedHashMap<Integer, ConversationAccumulator>();
        var rolesByUserId = new HashMap<Integer, Set<String>>();
        for (var message : messages.inboxMessages(userId)) {
            var other = userId.equals(message.getSender().getId()) ? message.getReceiver() : message.getSender();
            if (!canChat(userId, other.getId(), rolesByUserId)) {
                continue;
            }
            var summary = summaries.computeIfAbsent(other.getId(), ignored ->
                    new ConversationAccumulator(other.getId(), displayName(other), other.getEmail(),
                            message.getContent(), message.getCreatedAt()));
            if (message.getReceiver().getId().equals(userId) && !message.isRead()) {
                summary.unreadCount++;
            }
        }
        return summaries.values().stream()
                .map(ConversationAccumulator::toDto)
                .toList();
    }

    @Transactional(readOnly = true)
    public List<ChatConversationDto> contacts(Integer userId) {
        var conversations = new ArrayList<>(conversations(userId));
        var existingIds = conversations.stream()
                .map(ChatConversationDto::userId)
                .collect(java.util.stream.Collectors.toSet());
        var contacts = hasRole(userId, "Customer") && !hasRole(userId, "Owner")
                ? users.findOwnerChatContacts(userId)
                : users.findChatContacts(userId);
        contacts.stream()
                .filter(user -> !existingIds.contains(user.getId()))
                .map(user -> new ChatConversationDto(user.getId(), displayName(user), user.getEmail(), null, 0, null))
                .forEach(conversations::add);
        return conversations;
    }

    @Transactional(readOnly = true)
    public List<ChatMessageDto> conversation(Integer userId, Integer otherUserId) {
        if (!canChat(userId, otherUserId)) {
            throw new IllegalArgumentException("Customers can only chat with hotel owners");
        }
        return messages.conversation(userId, otherUserId).stream()
                .map(mapper::toChatMessageDto)
                .toList();
    }

    @Transactional(readOnly = true)
    public List<ChatMessageDto> unread(Integer receiverId) {
        return messages.findByReceiverIdAndReadFalseOrderByCreatedAtDesc(receiverId).stream()
                .map(mapper::toChatMessageDto)
                .toList();
    }

    @Transactional
    public ChatMessageDto send(Integer senderId, SendChatMessageRequest request) {
        var content = request.content() == null ? "" : request.content().trim();
        if (content.isBlank()) {
            throw new IllegalArgumentException("Message content is required");
        }
        if (request.receiverId() == null) {
            throw new IllegalArgumentException("Receiver is required");
        }
        if (request.receiverId().equals(senderId)) {
            throw new IllegalArgumentException("Receiver must be different from sender");
        }
        if (!canChat(senderId, request.receiverId())) {
            throw new IllegalArgumentException("Customers can only chat with hotel owners");
        }

        var sender = new User();
        sender.setId(senderId);
        var receiver = new User();
        receiver.setId(request.receiverId());
        var message = new ChatMessage();
        message.setSender(sender);
        message.setReceiver(receiver);
        if (request.bookingId() != null) {
            var booking = new Booking();
            booking.setId(request.bookingId());
            message.setBooking(booking);
        }
        message.setContent(content);
        return mapper.toChatMessageDto(messages.save(message));
    }

    private boolean canChat(Integer userId, Integer otherUserId) {
        return canChat(userId, otherUserId, new HashMap<>());
    }

    private boolean canChat(Integer userId, Integer otherUserId, Map<Integer, Set<String>> rolesByUserId) {
        if (userId == null || otherUserId == null || userId.equals(otherUserId)) {
            return false;
        }

        var userRoles = roles(userId, rolesByUserId);
        var otherRoles = roles(otherUserId, rolesByUserId);
        if (userRoles.isEmpty() || otherRoles.isEmpty()) {
            return false;
        }

        var userIsCustomerOnly = userRoles.contains("customer") && !userRoles.contains("owner") && !userRoles.contains("admin");
        var otherIsCustomerOnly = otherRoles.contains("customer") && !otherRoles.contains("owner") && !otherRoles.contains("admin");
        if (userIsCustomerOnly || otherIsCustomerOnly) {
            return (userRoles.contains("customer") && otherRoles.contains("owner"))
                    || (userRoles.contains("owner") && otherRoles.contains("customer"));
        }
        return true;
    }

    private boolean hasRole(Integer userId, String role) {
        return roles(userId, new HashMap<>()).contains(normalizeRole(role));
    }

    private Set<String> roles(Integer userId, Map<Integer, Set<String>> rolesByUserId) {
        return rolesByUserId.computeIfAbsent(userId, ignored -> {
            var names = new HashSet<String>();
            users.findRoleNamesByUserId(userId).stream()
                    .map(this::normalizeRole)
                    .filter(name -> !name.isBlank())
                    .forEach(names::add);
            return names;
        });
    }

    private String normalizeRole(String role) {
        return role == null ? "" : role.toLowerCase().replaceFirst("^role_", "").trim();
    }

    @Transactional
    public ChatMessageDto markRead(Integer receiverId, Integer messageId) {
        var message = messages.findById(messageId)
                .orElseThrow(() -> new IllegalArgumentException("Message not found"));
        if (!message.getReceiver().getId().equals(receiverId)) {
            throw new IllegalArgumentException("Message not found");
        }
        message.setRead(true);
        message.setReadAt(Instant.now());
        return mapper.toChatMessageDto(messages.save(message));
    }

    private String displayName(User user) {
        var fullName = ((user.getLastName() == null ? "" : user.getLastName()) + " " +
                (user.getFirstName() == null ? "" : user.getFirstName())).trim();
        if (!fullName.isBlank()) {
            return fullName;
        }
        if (user.getUsername() != null && !user.getUsername().isBlank()) {
            return user.getUsername();
        }
        return user.getEmail() == null ? "User #" + user.getId() : user.getEmail();
    }

    private static final class ConversationAccumulator {
        private final Integer userId;
        private final String displayName;
        private final String email;
        private final String lastMessage;
        private final Instant lastMessageAt;
        private int unreadCount;

        private ConversationAccumulator(Integer userId, String displayName, String email, String lastMessage, Instant lastMessageAt) {
            this.userId = userId;
            this.displayName = displayName;
            this.email = email;
            this.lastMessage = lastMessage;
            this.lastMessageAt = lastMessageAt;
        }

        private ChatConversationDto toDto() {
            return new ChatConversationDto(userId, displayName, email, lastMessage, unreadCount, lastMessageAt);
        }
    }
}
