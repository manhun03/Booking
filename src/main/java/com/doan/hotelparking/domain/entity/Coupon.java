package com.doan.hotelparking.domain.entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

import java.math.BigDecimal;
import java.time.Instant;

@Getter
@Setter
@Entity
@Table(name = "Coupon", indexes = @Index(name = "IX_Coupon_Code", columnList = "Code", unique = true))
public class Coupon {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "Id")
    private Integer id;

    @Column(name = "Code")
    private String code;
    @Column(name = "Description")
    private String description;
    @Column(name = "DiscountType")
    private String discountType;
    @Column(name = "DiscountValue")
    private BigDecimal discountValue = BigDecimal.ZERO;
    @Column(name = "MaxDiscountAmount")
    private BigDecimal maxDiscountAmount;
    @Column(name = "MinOrderAmount")
    private BigDecimal minOrderAmount = BigDecimal.ZERO;
    @Column(name = "StartAt")
    private Instant startAt;
    @Column(name = "EndAt")
    private Instant endAt;
    @Column(name = "MaxUses")
    private Integer maxUses;
    @Column(name = "UsedCount")
    private int usedCount;
    @Column(name = "IsActive")
    private boolean active = true;
    @Column(name = "CreatedAt")
    private Instant createdAt;

    @PrePersist
    void prePersist() {
        if (createdAt == null) {
            createdAt = Instant.now();
        }
    }
}
