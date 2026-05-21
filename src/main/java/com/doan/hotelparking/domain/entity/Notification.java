package com.doan.hotelparking.domain.entity;

import com.doan.hotelparking.domain.enums.NotificationType;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

import java.time.Instant;

@Getter
@Setter
@Entity
@Table(name = "Notification")
public class Notification {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "Id")
    private Integer id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "UserId")
    private User user;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "SenderId")
    private User sender;

    @Column(name = "Title")
    private String title;
    @Column(name = "Message")
    private String message;

    @Enumerated(EnumType.ORDINAL)
    @Column(name = "Type")
    private NotificationType type = NotificationType.GENERAL;

    @Column(name = "RelatedTable")
    private String relatedTable;
    @Column(name = "RelatedId")
    private Integer relatedId;
    @Column(name = "IsRead")
    private boolean read;
    @Column(name = "CreatedAt")
    private Instant createdAt;
    @Column(name = "ReadAt")
    private Instant readAt;
}
