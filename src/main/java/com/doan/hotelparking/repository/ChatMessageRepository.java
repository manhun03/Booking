package com.doan.hotelparking.repository;

import com.doan.hotelparking.domain.entity.ChatMessage;
import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.util.List;

public interface ChatMessageRepository extends JpaRepository<ChatMessage, Integer> {
    @Query("""
            select m from ChatMessage m
            where (m.sender.id = :userId and m.receiver.id = :otherUserId)
               or (m.sender.id = :otherUserId and m.receiver.id = :userId)
            order by m.createdAt asc
            """)
    List<ChatMessage> conversation(Integer userId, Integer otherUserId);

    @EntityGraph(attributePaths = {"sender", "receiver"})
    @Query("""
            select m from ChatMessage m
            where m.sender.id = :userId or m.receiver.id = :userId
            order by m.createdAt desc
            """)
    List<ChatMessage> inboxMessages(Integer userId);

    List<ChatMessage> findByReceiverIdAndReadFalseOrderByCreatedAtDesc(Integer receiverId);
}
