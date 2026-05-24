package com.doan.hotelparking.domain.entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

import java.time.Instant;

@Getter
@Setter
@Entity
@Table(name = "FcmToken", indexes = @Index(name = "IX_FcmToken_Token", columnList = "Token", unique = true))
public class FcmToken {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "Id")
    private Integer id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "UserId")
    private User user;

    @Column(name = "Token", nullable = false, length = 512)
    private String token;

    @Column(name = "CreatedAt")
    private Instant createdAt;
    @Column(name = "UpdatedAt")
    private Instant updatedAt;
}
