package com.doan.hotelparking.domain.entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

import java.math.BigDecimal;
import java.time.Instant;

@Getter
@Setter
@Entity
@Table(name = "TimeSlot")
public class TimeSlot {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "Id")
    private Integer id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "RoomId")
    private Room room;

    @Column(name = "StartDate")
    private Instant startDate;
    @Column(name = "EndDate")
    private Instant endDate;
    @Column(name = "Price")
    private BigDecimal price = BigDecimal.ZERO;
    @Column(name = "IsActive")
    private boolean active = true;
    @Column(name = "CreatedAt")
    private Instant createdAt;
    @Column(name = "UpdatedAt")
    private Instant updatedAt;
}
