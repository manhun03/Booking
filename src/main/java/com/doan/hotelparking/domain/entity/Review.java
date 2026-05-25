package com.doan.hotelparking.domain.entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

import java.time.Instant;

@Getter
@Setter
@Entity
@Table(name = "Review")
public class Review {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "Id")
    private Integer id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "BookingId")
    private Booking booking;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "CustomerId")
    private User customer;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "RoomId")
    private Room room;

    @Column(name = "Rating")
    private byte rating;
    @Column(name = "Comment")
    private String comment;
    @Column(name = "OwnerReply")
    private String ownerReply;
    @Column(name = "OwnerRepliedAt")
    private Instant ownerRepliedAt;
    @Column(name = "IsReported")
    private boolean reported;
    @Column(name = "ReportReason")
    private String reportReason;
    @Column(name = "IsVisible")
    private boolean visible = true;
    @Column(name = "ModeratedAt")
    private Instant moderatedAt;
    @Column(name = "CreatedAt")
    private Instant createdAt;
}
