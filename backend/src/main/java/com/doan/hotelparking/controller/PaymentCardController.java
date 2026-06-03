package com.doan.hotelparking.controller;

import com.doan.hotelparking.common.ApiResponse;
import com.doan.hotelparking.domain.entity.PaymentCard;
import com.doan.hotelparking.dto.payment.PaymentDtos.PaymentCardDto;
import com.doan.hotelparking.dto.payment.PaymentDtos.SavePaymentCardRequest;
import com.doan.hotelparking.repository.PaymentCardRepository;
import com.doan.hotelparking.repository.UserRepository;
import com.doan.hotelparking.service.CurrentUserService;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.*;

import java.time.YearMonth;
import java.util.List;

@RestController
@RequestMapping("/api/payment-cards")
@PreAuthorize("isAuthenticated()")
class PaymentCardController {
    private final PaymentCardRepository paymentCards;
    private final UserRepository users;
    private final CurrentUserService currentUser;

    PaymentCardController(PaymentCardRepository paymentCards, UserRepository users, CurrentUserService currentUser) {
        this.paymentCards = paymentCards;
        this.users = users;
        this.currentUser = currentUser;
    }

    @GetMapping
    @Transactional(readOnly = true)
    ApiResponse<List<PaymentCardDto>> myCards() {
        return ApiResponse.ok(paymentCards.findByCustomerIdAndDeletedFalseOrderByDefaultCardDescCreatedAtDesc(currentUser.requireUserId()).stream()
                .map(this::toDto)
                .toList());
    }

    @PostMapping
    @Transactional
    ApiResponse<PaymentCardDto> save(@RequestBody SavePaymentCardRequest request) {
        var customerId = currentUser.requireUserId();
        var customer = users.findById(customerId)
                .orElseThrow(() -> new IllegalArgumentException("User not found"));
        var digits = normalizeCardNumber(request.cardNumber());
        var expiry = parseExpiry(request.expiry());
        var existingCards = paymentCards.findByCustomerIdAndDeletedFalseOrderByDefaultCardDescCreatedAtDesc(customerId);
        var makeDefault = existingCards.isEmpty() || Boolean.TRUE.equals(request.defaultCard());
        if (makeDefault) {
            existingCards.forEach(card -> card.setDefaultCard(false));
            paymentCards.saveAll(existingCards);
        }

        var card = new PaymentCard();
        card.setCustomer(customer);
        card.setCardHolderName(normalizeHolderName(request.cardHolderName()));
        card.setBrand(normalizeBrand(request.brand(), digits));
        card.setLast4(digits.substring(digits.length() - 4));
        card.setExpiryMonth(expiry.getMonthValue());
        card.setExpiryYear(expiry.getYear());
        card.setDefaultCard(makeDefault);

        return ApiResponse.ok("Payment card saved", toDto(paymentCards.save(card)));
    }

    @PostMapping("/{id}/default")
    @Transactional
    ApiResponse<PaymentCardDto> makeDefault(@PathVariable Integer id) {
        var customerId = currentUser.requireUserId();
        var selected = paymentCards.findByIdAndCustomerIdAndDeletedFalse(id, customerId)
                .orElseThrow(() -> new IllegalArgumentException("Payment card not found"));
        var cards = paymentCards.findByCustomerIdAndDeletedFalseOrderByDefaultCardDescCreatedAtDesc(customerId);
        for (var card : cards) {
            card.setDefaultCard(card.getId().equals(selected.getId()));
        }
        paymentCards.saveAll(cards);
        return ApiResponse.ok("Default payment card updated", toDto(selected));
    }

    @DeleteMapping("/{id}")
    @Transactional
    ApiResponse<Void> delete(@PathVariable Integer id) {
        var customerId = currentUser.requireUserId();
        var card = paymentCards.findByIdAndCustomerIdAndDeletedFalse(id, customerId)
                .orElseThrow(() -> new IllegalArgumentException("Payment card not found"));
        var wasDefault = card.isDefaultCard();
        card.setDeleted(true);
        card.setDefaultCard(false);
        paymentCards.save(card);

        if (wasDefault) {
            paymentCards.findFirstByCustomerIdAndDeletedFalseOrderByCreatedAtDesc(customerId)
                    .ifPresent(next -> {
                        next.setDefaultCard(true);
                        paymentCards.save(next);
                    });
        }

        return ApiResponse.ok("Payment card deleted", null);
    }

    private PaymentCardDto toDto(PaymentCard card) {
        return new PaymentCardDto(
                card.getId(),
                card.getCustomer() == null ? null : card.getCustomer().getId(),
                card.getCardHolderName(),
                card.getBrand(),
                card.getLast4(),
                card.getExpiryMonth(),
                card.getExpiryYear(),
                card.isDefaultCard(),
                card.getCreatedAt(),
                card.getUpdatedAt());
    }

    private String normalizeCardNumber(String cardNumber) {
        var digits = cardNumber == null ? "" : cardNumber.replaceAll("\\D", "");
        if (digits.length() < 12 || digits.length() > 19) {
            throw new IllegalArgumentException("Card number must contain 12 to 19 digits");
        }
        return digits;
    }

    private String normalizeHolderName(String cardHolderName) {
        var holderName = cardHolderName == null ? "" : cardHolderName.trim();
        if (holderName.isBlank()) {
            throw new IllegalArgumentException("Card holder name is required");
        }
        if (holderName.length() > 120) {
            return holderName.substring(0, 120);
        }
        return holderName;
    }

    private YearMonth parseExpiry(String rawExpiry) {
        var expiry = rawExpiry == null ? "" : rawExpiry.trim();
        var matcher = java.util.regex.Pattern.compile("^(\\d{1,2})\\s*/\\s*(\\d{2}|\\d{4})$").matcher(expiry);
        if (!matcher.matches()) {
            throw new IllegalArgumentException("Expiry must use MM/YY format");
        }
        var month = Integer.parseInt(matcher.group(1));
        var year = Integer.parseInt(matcher.group(2));
        if (month < 1 || month > 12) {
            throw new IllegalArgumentException("Expiry month is invalid");
        }
        if (year < 100) {
            year += 2000;
        }
        var value = YearMonth.of(year, month);
        if (value.isBefore(YearMonth.now())) {
            throw new IllegalArgumentException("Payment card is expired");
        }
        return value;
    }

    private String normalizeBrand(String requestedBrand, String digits) {
        var brand = requestedBrand == null ? "" : requestedBrand.trim();
        if (!brand.isBlank()) {
            return brand.length() > 40 ? brand.substring(0, 40) : brand;
        }
        if (digits.startsWith("4")) {
            return "VISA";
        }
        if (digits.startsWith("34") || digits.startsWith("37")) {
            return "AMEX";
        }
        if (digits.matches("^(5[1-5]).*") || digits.matches("^(222[1-9]|22[3-9]\\d|2[3-6]\\d{2}|27[01]\\d|2720).*")) {
            return "MASTERCARD";
        }
        if (digits.startsWith("35")) {
            return "JCB";
        }
        return "CARD";
    }
}
