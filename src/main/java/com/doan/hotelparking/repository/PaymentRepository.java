package com.doan.hotelparking.repository;

import com.doan.hotelparking.domain.entity.Payment;
import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Optional;

public interface PaymentRepository extends JpaRepository<Payment, Integer> {
    List<Payment> findByBookingId(Integer bookingId);

    @EntityGraph(attributePaths = {"booking", "booking.customer", "booking.room", "booking.room.hotel", "booking.room.hotel.owner"})
    List<Payment> findByBookingIdOrderByCreatedAtDesc(Integer bookingId);

    @EntityGraph(attributePaths = {"booking", "booking.customer", "booking.room", "booking.room.hotel", "booking.room.hotel.owner"})
    List<Payment> findByBookingCustomerIdOrderByCreatedAtDesc(Integer customerId);

    @EntityGraph(attributePaths = {"booking", "booking.room", "booking.room.hotel", "booking.room.hotel.owner"})
    @Query("select p from Payment p where p.booking.room.hotel.owner.id = :ownerId order by p.createdAt desc")
    List<Payment> findByOwnerId(@Param("ownerId") Integer ownerId);

    Optional<Payment> findByTransactionCode(String transactionCode);
    Optional<Payment> findByGatewayTransactionId(String gatewayTransactionId);
}
