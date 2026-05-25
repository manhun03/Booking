package com.doan.hotelparking.domain.entity;

import com.doan.hotelparking.domain.enums.AuthTokenType;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

import java.time.Instant;

@Getter
@Setter
@Entity
@Table(name = "AuthToken", indexes = {
        @Index(name = "IX_AuthToken_Token", columnList = "Token", unique = true),
        @Index(name = "IX_AuthToken_UserId_Type", columnList = "UserId, Type")
})
public class AuthToken {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "Id")
    private Integer id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "UserId")
    private User user;

    @Enumerated(EnumType.STRING)
    @Column(name = "Type")
    private AuthTokenType type;

    @Column(name = "Token")
    private String token;
    @Column(name = "ExpiresAt")
    private Instant expiresAt;
    @Column(name = "UsedAt")
    private Instant usedAt;
    @Column(name = "CreatedAt")
    private Instant createdAt;

    public boolean isUsable() {
        return usedAt == null && expiresAt != null && expiresAt.isAfter(Instant.now());
    }
}
