package com.doan.hotelparking.domain.entity;

import com.doan.hotelparking.domain.enums.UserStatus;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

import java.time.Instant;
import java.util.HashSet;
import java.util.Set;

@Getter
@Setter
@Entity
@Table(name = "[User]", indexes = @Index(name = "IX_User_Email", columnList = "Email", unique = true))
public class User {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "Id")
    private Integer id;

    @Column(name = "LastName")
    private String lastName;
    @Column(name = "FirstName")
    private String firstName;
    @Column(name = "Email")
    private String email;
    @Column(name = "Phone")
    private String phone;
    @Column(name = "Password")
    private String password;
    @Column(name = "AvatarUrl")
    private String avatarUrl;

    @Enumerated(EnumType.ORDINAL)
    @Column(name = "Status")
    private UserStatus status = UserStatus.ACTIVE;

    @Column(name = "IsDeleted")
    private boolean isDeleted;
    @Column(name = "DeletedBy")
    private Integer deletedBy;
    @Column(name = "CreatedAt")
    private Instant createdAt;
    @Column(name = "UpdatedAt")
    private Instant updatedAt;
    @Column(name = "DeletedAt")
    private Instant deletedAt;

    @OneToMany(mappedBy = "user", cascade = CascadeType.ALL, orphanRemoval = true)
    private Set<UserRole> userRoles = new HashSet<>();
}
