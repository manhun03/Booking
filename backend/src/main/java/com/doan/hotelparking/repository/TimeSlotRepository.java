package com.doan.hotelparking.repository;

import com.doan.hotelparking.domain.entity.TimeSlot;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.util.List;
import java.util.Optional;

public interface TimeSlotRepository extends JpaRepository<TimeSlot, Integer> {
    List<TimeSlot> findByRoomId(Integer roomId);
    List<TimeSlot> findByRoomHotelId(Integer hotelId);

    Optional<TimeSlot> findFirstByRoomIdAndActiveTrueAndStartDateLessThanEqualAndEndDateGreaterThanEqualOrderByCreatedAtDesc(
            Integer roomId,
            java.time.Instant checkInDate,
            java.time.Instant checkOutDate);
}
