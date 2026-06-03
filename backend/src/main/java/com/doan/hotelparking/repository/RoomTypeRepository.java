package com.doan.hotelparking.repository;

import com.doan.hotelparking.domain.entity.RoomType;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.util.List;
import java.util.Optional;

public interface RoomTypeRepository extends JpaRepository<RoomType, Integer> {
    Optional<RoomType> findByNameIgnoreCase(String name);

    @Query("select distinct rt from RoomType rt join Room r on r.roomType = rt where r.hotel.id = :hotelId")
    List<RoomType> findByHotelId(Integer hotelId);
}
