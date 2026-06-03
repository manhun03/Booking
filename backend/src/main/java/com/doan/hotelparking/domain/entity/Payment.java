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
    @Column(name = "Provider")
    private String provider;

    @Enumerated(EnumType.ORDINAL)
    @Column(name = "Status")
    private PaymentStatus status = PaymentStatus.PENDING;

    @Column(name = "TransactionCode")
    private String transactionCode;
    @Column(name = "GatewayTransactionId")
    private String gatewayTransactionId;
    @Column(name = "CheckoutUrl")
    private String checkoutUrl;
    @Column(name = "FailureReason")
    private String failureReason;
    @Column(name = "RefundedAmount")
    private BigDecimal refundedAmount = BigDecimal.ZERO;
    @Column(name = "Note")
    private String note;
    @Column(name = "PaidAt")
    private Instant paidAt;
    @Column(name = "RefundedAt")
    private Instant refundedAt;
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
