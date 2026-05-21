package com.doan.hotelparking.repository;

import com.doan.hotelparking.domain.entity.FavoriteHotel;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface FavoriteHotelRepository extends JpaRepository<FavoriteHotel, Integer> {
    List<FavoriteHotel> findByUserId(Integer userId);
    Optional<FavoriteHotel> findByUserIdAndHotelId(Integer userId, Integer hotelId);
    boolean existsByUserIdAndHotelId(Integer userId, Integer hotelId);
}
