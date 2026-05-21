package com.doan.hotelparking.repository;

import com.doan.hotelparking.domain.entity.RolePermission;
import com.doan.hotelparking.domain.entity.RolePermissionId;
import org.springframework.data.jpa.repository.JpaRepository;

public interface RolePermissionRepository extends JpaRepository<RolePermission, RolePermissionId> {
}
