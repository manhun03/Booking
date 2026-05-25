package com.doan.hotelparking.domain.entity;

import com.doan.hotelparking.domain.enums.HotelStatus;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

import java.time.Instant;
import java.util.HashSet;
import java.util.Set;

@Getter
@Setter
@Entity
@Table(name = "Hotel")
public class Hotel {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "Id")
    private Integer id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "OwnerId")
    private User owner;

    @ManyToOne(fetch = FetchType.LAZY, optional = true)
    @JoinColumn(name = "WardId")
    private Ward ward;

    @Column(name = "Name")
    private String name;
    @Column(name = "Street")
    private String street;
    @Column(name = "Phone")
    private String phone;

    @Column(name = "Description", length = 2000)
    private String description;

    @Enumerated(EnumType.ORDINAL)
    @Column(name = "Status")
    private HotelStatus status = HotelStatus.ACTIVE;

    @Column(name = "IsDeleted")
    private boolean isDeleted;
    @Column(name = "CreatedAt")
    private Instant createdAt;
    @Column(name = "UpdatedAt")
    private Instant updatedAt;

    @OneToMany(mappedBy = "hotel", cascade = CascadeType.ALL, orphanRemoval = true)
    private Set<Room> rooms = new HashSet<>();

    @OneToMany(mappedBy = "hotel", cascade = CascadeType.ALL, orphanRemoval = true)
    private Set<HotelImage> hotelImages = new HashSet<>();

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
