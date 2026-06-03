package com.doan.hotelparking.repository;

import com.doan.hotelparking.domain.entity.HotelImage;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface HotelImageRepository extends JpaRepository<HotelImage, Integer> {
    List<HotelImage> findByHotelIdOrderByPrimaryImageDescSortOrderAsc(Integer hotelId);
}
