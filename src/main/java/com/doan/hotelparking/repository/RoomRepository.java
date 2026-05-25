package com.doan.hotelparking.repository;

import com.doan.hotelparking.domain.entity.Room;
import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Optional;

public interface RoomRepository extends JpaRepository<Room, Integer> {
    @EntityGraph(attributePaths = {"hotel", "roomType"})
    @Query("select r from Room r where r.isDeleted = false")
    List<Room> findVisible();

    @EntityGraph(attributePaths = {"hotel", "roomType"})
    List<Room> findByHotelId(Integer hotelId);

    @EntityGraph(attributePaths = {"hotel", "roomType"})
    @Query("select r from Room r where r.hotel.id = :hotelId and r.isDeleted = false and r.hotel.isDeleted = false")
    List<Room> findVisibleByHotelId(@Param("hotelId") Integer hotelId);

    List<Room> findByHotelOwnerId(Integer ownerId);

    @EntityGraph(attributePaths = {"hotel", "roomType"})
    @Query("select r from Room r where r.hotel.owner.id = :ownerId and r.isDeleted = false and r.hotel.isDeleted = false")
    List<Room> findVisibleByHotelOwnerId(@Param("ownerId") Integer ownerId);

    @EntityGraph(attributePaths = {"hotel", "roomType"})
    List<Room> findByRoomTypeId(Integer roomTypeId);

    @EntityGraph(attributePaths = {"hotel", "roomType"})
    @Query("select r from Room r where r.roomType.id = :roomTypeId and r.isDeleted = false and r.hotel.isDeleted = false")
    List<Room> findVisibleByRoomTypeId(@Param("roomTypeId") Integer roomTypeId);

    @EntityGraph(attributePaths = {"hotel", "hotel.owner", "roomType"})
    Optional<Room> findDetailedById(Integer id);
}
