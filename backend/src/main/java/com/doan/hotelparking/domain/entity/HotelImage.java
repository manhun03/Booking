package com.doan.hotelparking.domain.entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

import java.time.Instant;

@Getter
@Setter
@Entity
@Table(name = "HotelImage")
public class HotelImage {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "Id")
    private Integer id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "HotelId")
    private Hotel hotel;

    @Column(name = "ImageUrl")
    private String imageUrl;
    @Column(name = "ObjectKey")
    private String objectKey;
    @Column(name = "IsPrimary")
    private boolean primaryImage;
    @Column(name = "SortOrder")
    private int sortOrder;
    @Column(name = "CreatedAt")
    private Instant createdAt;
}
