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
            select u from User u
            where u.id <> :currentUserId
              and u.isDeleted = false
            order by u.lastName asc, u.firstName asc, u.email asc
            """)
    List<User> findChatContacts(Integer currentUserId);
}
