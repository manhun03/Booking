package com.doan.hotelparking.domain.entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

import java.math.BigDecimal;
import java.time.Instant;

@Getter
@Setter
@Entity
@Table(name = "OwnerSetting")
public class OwnerSetting {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "Id")
    private Integer id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "OwnerId")
    private User owner;

    @Column(name = "DepositRate")
    private BigDecimal depositRate;
    @Column(name = "MinBookingNotice")
    private Integer minBookingNotice;
    @Column(name = "AllowReview")
    private boolean allowReview = true;
    @Column(name = "BankName")
    private String bankName;
    @Column(name = "BankAccountNumber")
    private String bankAccountNumber;
    @Column(name = "BankAccountName")
    private String bankAccountName;
    @Column(name = "BankQrCodeUrl")
    private String bankQrCodeUrl;
    @Column(name = "CreatedAt")
    private Instant createdAt;
    @Column(name = "UpdatedAt")
    private Instant updatedAt;
}
