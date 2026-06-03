package com.doan.hotelparking.repository;

import com.doan.hotelparking.domain.entity.UserRole;
import com.doan.hotelparking.domain.entity.UserRoleId;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.util.List;

public interface UserRoleRepository extends JpaRepository<UserRole, UserRoleId> {
    @Query("select ur.role.name from UserRole ur where ur.user.id = :userId")
    List<String> findRoleNamesByUserId(Integer userId);
}
