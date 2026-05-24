package com.doan.hotelparking.domain.entity;

import jakarta.persistence.Embeddable;
import jakarta.persistence.Column;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.EqualsAndHashCode;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.io.Serializable;

@Getter
@Setter
@EqualsAndHashCode
@Embeddable
@NoArgsConstructor
@AllArgsConstructor
public class UserRoleId implements Serializable {
    @Column(name = "UserId")
    private Integer userId;
    @Column(name = "RoleId")
    private Integer roleId;
}
