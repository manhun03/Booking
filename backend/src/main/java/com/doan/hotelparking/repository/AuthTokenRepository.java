package com.doan.hotelparking.repository;

import com.doan.hotelparking.domain.entity.AuthToken;
import com.doan.hotelparking.domain.enums.AuthTokenType;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface AuthTokenRepository extends JpaRepository<AuthToken, Integer> {
    Optional<AuthToken> findByTokenAndType(String token, AuthTokenType type);
}
