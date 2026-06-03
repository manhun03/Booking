package com.doan.hotelparking.service;

import com.doan.hotelparking.domain.entity.Booking;
import com.doan.hotelparking.domain.entity.Coupon;
import com.doan.hotelparking.domain.entity.Hotel;
import com.doan.hotelparking.domain.entity.Room;
import com.doan.hotelparking.domain.enums.RoomStatus;
import com.doan.hotelparking.repository.BookingRepository;
import com.doan.hotelparking.repository.CouponRepository;
import com.doan.hotelparking.repository.HotelRepository;
import com.doan.hotelparking.repository.RoomRepository;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.data.domain.PageRequest;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.text.Normalizer;
import java.time.Instant;
import java.time.ZoneId;
import java.time.format.DateTimeFormatter;
import java.util.Comparator;
import java.util.Map;
import java.util.UUID;
import java.util.regex.Pattern;

@Service
public class LocalAiChatService {
    private static final Pattern DIACRITICS = Pattern.compile("\\p{InCombiningDiacriticalMarks}+");
    private static final DateTimeFormatter DATE_FORMATTER = DateTimeFormatter.ofPattern("dd/MM/yyyy")
            .withZone(ZoneId.of("Asia/Ho_Chi_Minh"));

    private final ObjectMapper objectMapper;
    private final BookingRepository bookings;
    private final HotelRepository hotels;
    private final RoomRepository rooms;
    private final CouponRepository coupons;
    private final CurrentUserService currentUser;

    public LocalAiChatService(ObjectMapper objectMapper,
                              BookingRepository bookings,
                              HotelRepository hotels,
                              RoomRepository rooms,
                              CouponRepository coupons,
                              CurrentUserService currentUser) {
        this.objectMapper = objectMapper;
        this.bookings = bookings;
        this.hotels = hotels;
        this.rooms = rooms;
        this.coupons = coupons;
        this.currentUser = currentUser;
    }

    public JsonNode health() {
        var node = objectMapper.createObjectNode();
        node.put("status", "UP");
        node.put("mode", "LOCAL_FALLBACK");
        node.put("message", "Local AI assistant is available.");
        return node;
    }

    @Transactional(readOnly = true)
    public JsonNode chat(Map<String, Object> body) {
        var message = stringValue(body == null ? null : body.get("message"));
        var threadId = stringValue(body == null ? null : body.get("threadId"));
        if (threadId == null) {
            threadId = "local-" + UUID.randomUUID();
        }

        var response = objectMapper.createObjectNode();
        response.put("threadId", threadId);
        response.put("content", answer(message));
        response.put("source", "local-fallback");
        return response;
    }

    private String answer(String message) {
        var normalized = normalize(message);
        if (normalized.isBlank()) {
            return "Ban hay nhap cau hoi ve khach san, phong, booking, thanh toan hoac ma giam gia.";
        }

        if (containsAny(normalized, "booking", "dat phong", "don phong", "lich su", "chuyen di")) {
            return bookingAnswer();
        }
        if (containsAny(normalized, "thanh toan", "payment", "vnpay", "hoan tien", "refund", "tra tien")) {
            return paymentAnswer();
        }
        if (containsAny(normalized, "ma giam gia", "coupon", "khuyen mai", "uu dai", "voucher")) {
            return couponAnswer();
        }
        if (containsAny(normalized, "khach san", "hotel", "phong", "di dau", "tim", "gia phong")) {
            return hotelAnswer();
        }
        if (containsAny(normalized, "xin chao", "hello", "hi", "chao")) {
            return "Chao ban, minh la tro ly AI StaySmart. Ban co the hoi ve khach san, phong trong, booking, thanh toan VNPay hoac ma giam gia.";
        }

        return """
                Minh co the ho tro cac viec sau:
                - Tim khach san va phong dang co tren he thong.
                - Xem booking gan day va trang thai dat phong cua ban.
                - Kiem tra so tien da thanh toan, con lai va trang thai thanh toan.
                - Goi y ma giam gia dang active.

                Ban thu hoi: "booking cua toi", "toi con phai thanh toan bao nhieu", hoac "co ma giam gia nao khong".
                """;
    }

    private String bookingAnswer() {
        var items = bookings.findDetailedByCustomerId(currentUser.requireUserId()).stream()
                .sorted(Comparator.comparing(this::bookingSortDate).reversed())
                .limit(5)
                .toList();
        if (items.isEmpty()) {
            return "Ban chua co booking nao. Ban co the vao Trang chu hoac Tim kiem de chon khach san va dat phong.";
        }

        var builder = new StringBuilder("Cac booking gan day cua ban:\n");
        for (var booking : items) {
            builder.append("- #").append(booking.getId())
                    .append(" | ").append(hotelName(booking))
                    .append(" | Phong ").append(roomNumber(booking))
                    .append(" | ").append(formatDate(booking.getCheckInDate()))
                    .append(" - ").append(formatDate(booking.getCheckOutDate()))
                    .append(" | Trang thai: ").append(booking.getStatus())
                    .append("\n");
        }
        return builder.toString().trim();
    }

    private String paymentAnswer() {
        var items = bookings.findDetailedByCustomerId(currentUser.requireUserId()).stream()
                .sorted(Comparator.comparing(this::bookingSortDate).reversed())
                .limit(5)
                .toList();
        if (items.isEmpty()) {
            return "Ban chua co booking nao de kiem tra thanh toan.";
        }

        var builder = new StringBuilder("Thong tin thanh toan cac booking gan day:\n");
        for (var booking : items) {
            var total = money(booking.getTotalAmount());
            var paid = money(booking.getPaidAmount());
            var remaining = total.subtract(paid).max(BigDecimal.ZERO);
            builder.append("- Booking #").append(booking.getId())
                    .append(": da thanh toan ").append(formatMoney(paid))
                    .append(" / ").append(formatMoney(total))
                    .append(", con lai ").append(formatMoney(remaining))
                    .append(", trang thai booking ").append(booking.getStatus())
                    .append("\n");
        }
        return builder.toString().trim();
    }

    private String couponAnswer() {
        var now = Instant.now();
        var items = coupons.findAll().stream()
                .filter(Coupon::isActive)
                .filter(coupon -> coupon.getStartAt() == null || !coupon.getStartAt().isAfter(now))
                .filter(coupon -> coupon.getEndAt() == null || !coupon.getEndAt().isBefore(now))
                .filter(coupon -> coupon.getMaxUses() == null || coupon.getUsedCount() < coupon.getMaxUses())
                .limit(5)
                .toList();
        if (items.isEmpty()) {
            return "Hien chua co ma giam gia active. Ban co the kiem tra lai o man hinh Uu dai sau.";
        }

        var builder = new StringBuilder("Ma giam gia dang dung duoc:\n");
        for (var coupon : items) {
            builder.append("- ").append(coupon.getCode())
                    .append(": ").append(couponText(coupon))
                    .append(". Don toi thieu ").append(formatMoney(money(coupon.getMinOrderAmount())));
            if (coupon.getEndAt() != null) {
                builder.append(", het han ").append(formatDate(coupon.getEndAt()));
            }
            builder.append("\n");
        }
        return builder.toString().trim();
    }

    private String hotelAnswer() {
        var visibleHotels = hotels.findVisible(PageRequest.of(0, 5)).getContent();
        if (visibleHotels.isEmpty()) {
            return "Hien chua co khach san nao dang hien thi tren he thong.";
        }

        var builder = new StringBuilder("Mot so khach san tren StaySmart:\n");
        for (var hotel : visibleHotels) {
            var availableRooms = rooms.findVisibleByHotelId(hotel.getId()).stream()
                    .filter(room -> room.getStatus() == RoomStatus.AVAILABLE)
                    .toList();
            builder.append("- ").append(hotel.getName())
                    .append(" | ").append(address(hotel))
                    .append(" | ").append(availableRooms.size()).append(" phong kha dung");
            availableRooms.stream()
                    .min(Comparator.comparing(room -> money(bestRoomPrice(room))))
                    .ifPresent(room -> builder.append(" | tu ").append(formatMoney(bestRoomPrice(room))));
            builder.append("\n");
        }
        return builder.append("Ban co the bam 'Tim khach san' de xem chi tiet va dat phong.").toString().trim();
    }

    private boolean containsAny(String value, String... needles) {
        for (var needle : needles) {
            if (value.contains(needle)) {
                return true;
            }
        }
        return false;
    }

    private String normalize(String value) {
        if (value == null) {
            return "";
        }
        var normalized = Normalizer.normalize(value.toLowerCase(), Normalizer.Form.NFD);
        return DIACRITICS.matcher(normalized).replaceAll("").replace('đ', 'd');
    }

    private String stringValue(Object value) {
        if (value == null) {
            return null;
        }
        var text = value.toString().trim();
        return text.isEmpty() ? null : text;
    }

    private Instant bookingSortDate(Booking booking) {
        if (booking.getUpdatedAt() != null) {
            return booking.getUpdatedAt();
        }
        if (booking.getCreatedAt() != null) {
            return booking.getCreatedAt();
        }
        return Instant.EPOCH;
    }

    private String hotelName(Booking booking) {
        return booking.getRoom() == null || booking.getRoom().getHotel() == null
                ? "Khach san"
                : booking.getRoom().getHotel().getName();
    }

    private String roomNumber(Booking booking) {
        return booking.getRoom() == null || booking.getRoom().getRoomNumber() == null
                ? "dang cap nhat"
                : booking.getRoom().getRoomNumber();
    }

    private String address(Hotel hotel) {
        var ward = hotel.getWard();
        var province = ward == null ? null : ward.getProvince();
        var parts = new StringBuilder();
        if (hotel.getStreet() != null && !hotel.getStreet().isBlank()) {
            parts.append(hotel.getStreet());
        }
        if (ward != null && ward.getName() != null && !ward.getName().isBlank()) {
            if (!parts.isEmpty()) {
                parts.append(", ");
            }
            parts.append(ward.getName());
        }
        if (province != null && province.getName() != null && !province.getName().isBlank()) {
            if (!parts.isEmpty()) {
                parts.append(", ");
            }
            parts.append(province.getName());
        }
        return parts.isEmpty() ? "Dia chi dang cap nhat" : parts.toString();
    }

    private BigDecimal bestRoomPrice(Room room) {
        if (room.getPromotionPrice() != null) {
            return room.getPromotionPrice();
        }
        if (room.getSeasonalPrice() != null) {
            return room.getSeasonalPrice();
        }
        return room.getPrice();
    }

    private String couponText(Coupon coupon) {
        var type = coupon.getDiscountType() == null ? "" : coupon.getDiscountType().trim().toUpperCase();
        if ("PERCENT".equals(type)) {
            var result = "giam " + money(coupon.getDiscountValue()).stripTrailingZeros().toPlainString() + "%";
            if (coupon.getMaxDiscountAmount() != null) {
                result += ", toi da " + formatMoney(coupon.getMaxDiscountAmount());
            }
            return result;
        }
        return "giam " + formatMoney(money(coupon.getDiscountValue()));
    }

    private String formatDate(Instant value) {
        return value == null ? "dang cap nhat" : DATE_FORMATTER.format(value);
    }

    private String formatMoney(BigDecimal value) {
        return String.format("%,.0f VND", money(value)).replace(",", ".");
    }

    private BigDecimal money(BigDecimal value) {
        return value == null ? BigDecimal.ZERO : value;
    }
}
