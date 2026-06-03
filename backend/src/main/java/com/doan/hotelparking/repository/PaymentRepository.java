package com.doan.hotelparking.repository;

import com.doan.hotelparking.domain.entity.Payment;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface PaymentRepository extends JpaRepository<Payment, Integer> {
    List<Payment> findByBookingId(Integer bookingId);
    Optional<Payment> findByTransactionCode(String transactionCode);
    Optional<Payment> findByGatewayTransactionId(String gatewayTransactionId);
}
