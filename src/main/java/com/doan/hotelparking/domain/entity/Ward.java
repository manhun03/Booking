package com.doan.hotelparking.domain.entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
@Entity
@Table(name = "Ward")
public class Ward {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "Id")
    private Integer id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "ProvinceId")
    private Province province;

    @Column(name = "Name", nullable = false)
    private String name;

    @Column(name = "Code")
    private String code;
    @Column(name = "IsActive")
    private boolean active = true;
}
