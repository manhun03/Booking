package com.doan.hotelparking.repository;

import com.doan.hotelparking.domain.entity.Review;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Optional;

public interface ReviewRepository extends JpaRepository<Review, Integer> {
    List<Review> findByRoomHotelId(Integer hotelId);
    boolean existsByBookingIdAndCustomerId(Integer bookingId, Integer customerId);
    @Query("""
            select count(r) > 0 from Review r
            where r.customer.id = :customerId
              and r.room.hotel.id = :hotelId
            """)
    boolean existsByCustomerIdAndHotelId(@Param("customerId") Integer customerId,
                                         @Param("hotelId") Integer hotelId);
    Optional<Review> findByBookingIdAndCustomerId(Integer bookingId, Integer customerId);
}