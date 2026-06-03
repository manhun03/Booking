package com.doan.hotelparking.repository;

import com.doan.hotelparking.domain.entity.PaymentCard;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface PaymentCardRepository extends JpaRepository<PaymentCard, Integer> {
    List<PaymentCard> findByCustomerIdAndDeletedFalseOrderByDefaultCardDescCreatedAtDesc(Integer customerId);

    Optional<PaymentCard> findByIdAndCustomerIdAndDeletedFalse(Integer id, Integer customerId);

    Optional<PaymentCard> findFirstByCustomerIdAndDeletedFalseOrderByCreatedAtDesc(Integer customerId);
}
