package com.doan.hotelparking.repository;

import com.doan.hotelparking.domain.entity.FcmToken;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface FcmTokenRepository extends JpaRepository<FcmToken, Integer> {
    List<FcmToken> findByUserId(Integer userId);
    Optional<FcmToken> findByToken(String token);
}
