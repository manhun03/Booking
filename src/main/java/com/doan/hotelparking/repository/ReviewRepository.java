package com.doan.hotelparking.repository;

import com.doan.hotelparking.domain.entity.Review;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface ReviewRepository extends JpaRepository<Review, Integer> {
    List<Review> findByRoomHotelId(Integer hotelId);
}
