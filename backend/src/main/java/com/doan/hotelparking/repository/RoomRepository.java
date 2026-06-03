package com.doan.hotelparking.repository;

import com.doan.hotelparking.domain.entity.Room;
import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.util.List;
import java.util.Optional;

public interface RoomRepository extends JpaRepository<Room, Integer> {
    List<Room> findByHotelId(Integer hotelId);
    List<Room> findByHotelOwnerId(Integer ownerId);
    List<Room> findByRoomTypeId(Integer roomTypeId);

    @Query("""
            select r from Room r
            where r.hotel.id = :hotelId
              and r.isDeleted = false
              and r.hotel.isDeleted = false
              and r.hotel.status = com.doan.hotelparking.domain.enums.HotelStatus.ACTIVE
            order by r.price asc
            """)
    List<Room> findVisibleByHotelId(Integer hotelId);

    @EntityGraph(attributePaths = {"hotel", "hotel.owner", "roomType"})
    Optional<Room> findDetailedById(Integer id);
}
