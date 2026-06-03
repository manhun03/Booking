package com.doan.hotelparking.domain.entity;

import com.doan.hotelparking.domain.enums.RoomStatus;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.HashSet;
import java.util.Set;

@Getter
@Setter
@Entity
@Table(name = "Room")
public class Room {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "Id")
    private Integer id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "HotelId")
    private Hotel hotel;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "RoomTypeId")
    private RoomType roomType;

    @Column(name = "RoomNumber")
    private String roomNumber;
    @Column(name = "Capacity")
    private int capacity;
    @Column(name = "Price")
    private BigDecimal price = BigDecimal.ZERO;
    @Column(name = "Amenities", length = 2000)
    private String amenities;
    @Column(name = "SeasonalPrice")
    private BigDecimal seasonalPrice;
    @Column(name = "PromotionPrice")
    private BigDecimal promotionPrice;

    @Enumerated(EnumType.ORDINAL)
    @Column(name = "Status")
    private RoomStatus status = RoomStatus.AVAILABLE;

    @Column(name = "IsDeleted")
    private boolean isDeleted;
    @Column(name = "CreatedAt")
    private Instant createdAt;

    @OneToMany(mappedBy = "room")
    private Set<Booking> bookings = new HashSet<>();

    @OneToMany(mappedBy = "room")
    private Set<Review> reviews = new HashSet<>();

    @PrePersist
    void prePersist() {
        if (createdAt == null) {
            createdAt = Instant.now();
        }
    }
}
