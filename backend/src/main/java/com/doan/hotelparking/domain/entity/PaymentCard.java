package com.doan.hotelparking.domain.entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

import java.time.Instant;

@Getter
@Setter
@Entity
@Table(name = "PaymentCard")
public class PaymentCard {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "Id")
    private Integer id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "CustomerId")
    private User customer;

    @Column(name = "CardHolderName")
    private String cardHolderName;
    @Column(name = "Brand")
    private String brand;
    @Column(name = "Last4")
    private String last4;
    @Column(name = "ExpiryMonth")
    private Integer expiryMonth;
    @Column(name = "ExpiryYear")
    private Integer expiryYear;
    @Column(name = "IsDefault")
    private boolean defaultCard;
    @Column(name = "IsDeleted")
    private boolean deleted;
    @Column(name = "CreatedAt")
    private Instant createdAt;
    @Column(name = "UpdatedAt")
    private Instant updatedAt;

    @PrePersist
    void prePersist() {
        var now = Instant.now();
        if (createdAt == null) {
            createdAt = now;
        }
        updatedAt = now;
    }

    @PreUpdate
    void preUpdate() {
        updatedAt = Instant.now();
    }
}
