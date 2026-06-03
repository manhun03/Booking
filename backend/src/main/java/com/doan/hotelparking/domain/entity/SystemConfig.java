package com.doan.hotelparking.domain.entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

import java.time.Instant;

@Getter
@Setter
@Entity
@Table(name = "SystemConfig", indexes = @Index(name = "IX_SystemConfig_Key", columnList = "ConfigKey", unique = true))
public class SystemConfig {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "Id")
    private Integer id;

    @Column(name = "ConfigKey", nullable = false)
    private String configKey;

    @Column(name = "ConfigValue")
    private String configValue;
    @Column(name = "DataType")
    private String dataType = "string";
    @Column(name = "Description")
    private String description;
    @Column(name = "UpdatedAt")
    private Instant updatedAt;
}
