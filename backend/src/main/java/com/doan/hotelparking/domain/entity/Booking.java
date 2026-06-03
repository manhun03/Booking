package com.doan.hotelparking.domain.entity;

import com.doan.hotelparking.domain.enums.BookingStatus;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

import java.math.BigDecimal;
import java.time.Instant;

@Getter
@Setter
@Entity
@Table(name = "Booking")
public class Booking {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "Id")
    private Integer id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "RoomId")
    private Room room;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "CustomerId")
    private User customer;

    @Column(name = "CheckInDate")
    private Instant checkInDate;
    @Column(name = "CheckOutDate")
    private Instant checkOutDate;
    @Column(name = "NightCount")
    private int nightCount;
    @Column(name = "GuestCount")
    private int guestCount;
    @Column(name = "RoomUnitPrice")
    private BigDecimal roomUnitPrice = BigDecimal.ZERO;
    @Column(name = "TotalAmount")
    private BigDecimal totalAmount = BigDecimal.ZERO;
    @Column(name = "PaidAmount")
    private BigDecimal paidAmount = BigDecimal.ZERO;
    @Column(name = "CustomerAddress")
    private String customerAddress;
    @Column(name = "Note")
    private String note;

    @Enumerated(EnumType.ORDINAL)
    @Column(name = "Status")
    private BookingStatus status = BookingStatus.PENDING;

    @Column(name = "CancelledBy")
    private Integer cancelledBy;
    @Column(name = "CancelReason")
    private String cancelReason;
    @Column(name = "CancellationFee")
    private BigDecimal cancellationFee = BigDecimal.ZERO;
    @Column(name = "CancelledAt")
    private Instant cancelledAt;
    @Column(name = "RejectedReason")
    private String rejectedReason;
    @Column(name = "RejectedAt")
    private Instant rejectedAt;
    @Column(name = "CheckedInAt")
    private Instant checkedInAt;
    @Column(name = "CheckedOutAt")
    private Instant checkedOutAt;
    @Column(name = "CreatedAt")
    private Instant createdAt;
    @Column(name = "UpdatedAt")
    private Instant updatedAt;
}
