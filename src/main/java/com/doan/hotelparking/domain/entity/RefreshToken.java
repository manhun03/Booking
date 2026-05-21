package com.doan.hotelparking.domain.entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

import java.time.Instant;

@Getter
@Setter
@Entity
@Table(name = "RefreshToken", indexes = @Index(name = "IX_RefreshToken_Token", columnList = "Token", unique = true))
public class RefreshToken {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "Id")
    private Integer id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "UserId")
    private User user;

    @Column(name = "Token")
    private String token;
    @Column(name = "ExpiresAt")
    private Instant expiresAt;
    @Column(name = "IsRevoked")
    private boolean revoked;
    @Column(name = "CreatedAt")
    private Instant createdAt;
}
