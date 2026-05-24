package com.doan.hotelparking.domain.entity;

import com.doan.hotelparking.domain.enums.PaymentStatus;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

import java.math.BigDecimal;
import java.time.Instant;

@Getter
@Setter
@Entity
@Table(name = "Payment")
public class Payment {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "Id")
    private Integer id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "BookingId")
    private Booking booking;

    @Column(name = "Amount")
    private BigDecimal amount = BigDecimal.ZERO;
    @Column(name = "Method")
    private String method;

    @Enumerated(EnumType.ORDINAL)
    @Column(name = "Status")
    private PaymentStatus status = PaymentStatus.PENDING;

    @Column(name = "TransactionCode")
    private String transactionCode;
    @Column(name = "Note")
    private String note;
    @Column(name = "PaidAt")
    private Instant paidAt;
    @Column(name = "CreatedAt")
    private Instant createdAt;
}
