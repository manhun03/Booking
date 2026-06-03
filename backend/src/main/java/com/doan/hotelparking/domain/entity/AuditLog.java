package com.doan.hotelparking.domain.entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

import java.time.Instant;

@Getter
@Setter
@Entity
@Table(name = "AuditLog")
public class AuditLog {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "Id")
    private Integer id;

    @Column(name = "ActorId")
    private Integer actorId;
    @Column(name = "Action")
    private String action;
    @Column(name = "TargetTable")
    private String targetTable;
    @Column(name = "TargetId")
    private Integer targetId;
    @Column(name = "Detail", length = 2000)
    private String detail;
    @Column(name = "CreatedAt")
    private Instant createdAt;

    @PrePersist
    void prePersist() {
        if (createdAt == null) {
            createdAt = Instant.now();
        }
    }
}
