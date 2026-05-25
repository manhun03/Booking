package com.doan.hotelparking.repository;

import com.doan.hotelparking.domain.entity.Booking;
import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.util.List;
import java.util.Optional;

public interface BookingRepository extends JpaRepository<Booking, Integer> {
    List<Booking> findByCustomerId(Integer customerId);

    @EntityGraph(attributePaths = {"room", "room.hotel", "customer"})
    @Query("select b from Booking b")
    List<Booking> findAllDetailed();

    @EntityGraph(attributePaths = {"room", "room.hotel", "room.hotel.ward", "room.hotel.ward.province"})
    @Query("select b from Booking b where b.customer.id = :customerId")
    List<Booking> findDetailedByCustomerId(Integer customerId);

    @EntityGraph(attributePaths = {"room", "room.hotel", "customer"})
    @Query("select b from Booking b where b.room.hotel.owner.id = :ownerId")
    List<Booking> findForOwner(Integer ownerId);

    @EntityGraph(attributePaths = {"room", "room.hotel", "customer"})
    @Query("select b from Booking b where b.id = :id")
    Optional<Booking> findDetailedById(Integer id);

    @Query("""
            select count(b) > 0 from Booking b
            where b.room.id = :roomId
              and b.status <> com.doan.hotelparking.domain.enums.BookingStatus.CANCELLED
              and (:excludedBookingId is null or b.id <> :excludedBookingId)
              and b.checkInDate < :checkOutDate
              and b.checkOutDate > :checkInDate
            """)
    boolean hasOverlappingBooking(Integer roomId,
                                  java.time.Instant checkInDate,
                                  java.time.Instant checkOutDate,
                                  Integer excludedBookingId);
}
