package com.doan.hotelparking.repository;

import com.doan.hotelparking.domain.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.util.List;
import java.util.Optional;

public interface UserRepository extends JpaRepository<User, Integer> {
    Optional<User> findByEmail(String email);
    Optional<User> findByUsername(String username);

    @Query("""
            select distinct u from User u
            join u.userRoles ur
            join ur.role r
            where u.id <> :userId
              and u.isDeleted = false
              and u.status = com.doan.hotelparking.domain.enums.UserStatus.ACTIVE
              and r.active = true
            order by u.lastName asc, u.firstName asc, u.email asc
            """)
    List<User> findChatContacts(Integer userId);

    @Query("""
            select distinct u from User u
            join u.userRoles ur
            join ur.role r
            where u.id <> :userId
              and u.isDeleted = false
              and u.status = com.doan.hotelparking.domain.enums.UserStatus.ACTIVE
              and r.active = true
              and lower(r.name) in ('owner', 'role_owner')
            order by u.lastName asc, u.firstName asc, u.email asc
            """)
    List<User> findOwnerChatContacts(Integer userId);

    @Query("""
            select r.name from UserRole ur
            join ur.role r
            where ur.user.id = :userId and r.active = true
            """)
    List<String> findRoleNamesByUserId(Integer userId);
}
