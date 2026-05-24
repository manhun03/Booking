package com.doan.hotelparking.repository;

import com.doan.hotelparking.domain.entity.Permission;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.util.List;
import java.util.Optional;

public interface PermissionRepository extends JpaRepository<Permission, Integer> {
    List<Permission> findByModuleIgnoreCase(String module);
    Optional<Permission> findByPermissionKeyIgnoreCase(String permissionKey);

    @Query("""
            select count(p) > 0 from UserRole ur
            join ur.role r
            join r.rolePermissions rp
            join rp.permission p
            where ur.user.id = :userId
              and lower(p.permissionKey) = lower(:permissionKey)
            """)
    boolean userHasPermission(Integer userId, String permissionKey);
}
