package com.doan.hotelparking.domain.entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

import java.time.Instant;
import java.util.HashSet;
import java.util.Set;

@Getter
@Setter
@Entity
@Table(name = "Permission", indexes = @Index(name = "IX_Permission_Key", columnList = "PermissionKey", unique = true))
public class Permission {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "Id")
    private Integer id;

    @Column(name = "PermissionKey")
    private String permissionKey;
    @Column(name = "Description")
    private String description;
    @Column(name = "Module")
    private String module;
    @Column(name = "CreatedAt")
    private Instant createdAt;
    @Column(name = "UpdatedAt")
    private Instant updatedAt;

    @OneToMany(mappedBy = "permission", cascade = CascadeType.ALL, orphanRemoval = true)
    private Set<RolePermission> rolePermissions = new HashSet<>();
}
