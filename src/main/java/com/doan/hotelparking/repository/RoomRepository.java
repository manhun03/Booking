package com.doan.hotelparking.repository;

import com.doan.hotelparking.domain.entity.Room;
import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface RoomRepository extends JpaRepository<Room, Integer> {
    List<Room> findByHotelId(Integer hotelId);
    List<Room> findByHotelOwnerId(Integer ownerId);
    List<Room> findByRoomTypeId(Integer roomTypeId);

    @EntityGraph(attributePaths = {"hotel", "hotel.owner", "roomType"})
    Optional<Room> findDetailedById(Integer id);
}
