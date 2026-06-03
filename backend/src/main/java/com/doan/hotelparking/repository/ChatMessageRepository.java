package com.doan.hotelparking.repository;

import com.doan.hotelparking.domain.entity.ChatMessage;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.util.List;

public interface ChatMessageRepository extends JpaRepository<ChatMessage, Integer> {
    @Query("""
            select m from ChatMessage m
            join fetch m.sender
            join fetch m.receiver
            left join fetch m.booking
            where m.sender.id = :userId or m.receiver.id = :userId
            order by m.createdAt desc
            """)
    List<ChatMessage> inboxMessages(Integer userId);

    @Query("""
            select m from ChatMessage m
            join fetch m.sender
            join fetch m.receiver
            left join fetch m.booking
            where (m.sender.id = :userId and m.receiver.id = :otherUserId)
               or (m.sender.id = :otherUserId and m.receiver.id = :userId)
            order by m.createdAt asc
            """)
    List<ChatMessage> conversation(Integer userId, Integer otherUserId);
    List<ChatMessage> findByReceiverIdAndReadFalseOrderByCreatedAtDesc(Integer receiverId);
}
