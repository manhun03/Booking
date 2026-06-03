package com.doan.hotelparking.service;

import com.doan.hotelparking.domain.entity.Hotel;
import com.doan.hotelparking.domain.entity.Room;
import com.doan.hotelparking.domain.enums.BookingStatus;
import com.doan.hotelparking.domain.enums.HotelStatus;
import com.doan.hotelparking.domain.enums.RoomStatus;
import com.doan.hotelparking.dto.recommendation.HotelRecommendationDto;
import com.doan.hotelparking.dto.recommendation.RecommendationResponse;
import com.doan.hotelparking.repository.BookingRepository;
import com.doan.hotelparking.repository.HotelRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.Comparator;
import java.util.List;

@Service
public class RecommendationService {
    private final HotelRepository hotels;
    private final BookingRepository bookings;

    public RecommendationService(HotelRepository hotels, BookingRepository bookings) {
        this.hotels = hotels;
        this.bookings = bookings;
    }

    @Transactional(readOnly = true)
    public RecommendationResponse similarHotels(Integer hotelId, int topK) {
        var currentHotel = hotels.findDetailedById(hotelId).orElse(null);
        if (currentHotel == null) {
            return new RecommendationResponse("item-to-item", List.of(), "Hotel not found");
        }

        var currentVector = vectorize(currentHotel);
        var province = currentHotel.getWard().getProvince().getName();
        var ward = currentHotel.getWard().getName();
        var candidates = hotels.findActiveDetailed(HotelStatus.ACTIVE, province, ward).stream()
                .filter(hotel -> !hotel.getId().equals(hotelId))
                .toList();

        if (candidates.isEmpty()) {
            candidates = hotels.findActiveDetailed(HotelStatus.ACTIVE, null, null).stream()
                    .filter(hotel -> !hotel.getId().equals(hotelId))
                    .toList();
        }

        var result = candidates.stream()
                .map(hotel -> map(hotel, cosine(currentVector, vectorize(hotel))))
                .sorted(Comparator.comparingDouble(HotelRecommendationDto::similarityScore).reversed())
                .limit(normalizeTopK(topK))
                .toList();

        return new RecommendationResponse("item-to-item", result, "Found " + result.size() + " similar hotels");
    }

    @Transactional(readOnly = true)
    public RecommendationResponse newUser(String province, String ward, int topK) {
        var candidateHotels = hotels.findActiveDetailed(HotelStatus.ACTIVE, province, ward);
        if (candidateHotels.isEmpty()) {
            candidateHotels = hotels.findActiveDetailed(HotelStatus.ACTIVE, null, null);
        }

        var maxBookingCount = Math.max(candidateHotels.stream().mapToInt(this::bookingCount).max().orElse(0), 1);
        var result = candidateHotels.stream()
                .map(hotel -> {
                    var normalizedBooking = (double) bookingCount(hotel) / maxBookingCount;
                    var normalizedRating = averageRating(hotel) / 5.0;
                    return map(hotel, (0.6 * normalizedBooking) + (0.4 * normalizedRating));
                })
                .sorted(Comparator.comparingDouble(HotelRecommendationDto::similarityScore).reversed())
                .limit(normalizeTopK(topK))
                .toList();

        return new RecommendationResponse("location-popularity", result,
                "Recommended " + result.size() + " popular hotels");
    }

    @Transactional(readOnly = true)
    public RecommendationResponse personalized(Integer userId, int topK, String province) {
        var history = bookings.findDetailedByCustomerId(userId);
        if (history.isEmpty()) {
            return newUser(province, null, topK);
        }

        var bookedHotelIds = history.stream()
                .map(booking -> booking.getRoom().getHotel().getId())
                .distinct()
                .toList();
        var userVector = averageVector(history.stream()
                .map(booking -> booking.getRoom().getHotel())
                .distinct()
                .map(this::vectorize)
                .toList());

        var result = hotels.findActiveDetailed(HotelStatus.ACTIVE, province, null).stream()
                .filter(hotel -> !bookedHotelIds.contains(hotel.getId()))
                .map(hotel -> map(hotel, cosine(userVector, vectorize(hotel))))
                .sorted(Comparator.comparingDouble(HotelRecommendationDto::similarityScore).reversed())
                .limit(normalizeTopK(topK))
                .toList();

        return new RecommendationResponse("content-based-user", result,
                "Recommended " + result.size() + " hotels for you");
    }

    private int normalizeTopK(int topK) {
        return Math.max(1, Math.min(topK, 50));
    }

    private double[] vectorize(Hotel hotel) {
        var rooms = hotel.getRooms().stream().filter(room -> !room.isDeleted()).toList();
        var roomCount = rooms.size();
        var averageRoomPrice = rooms.stream()
                .map(Room::getPrice)
                .reduce(BigDecimal.ZERO, BigDecimal::add)
                .divide(BigDecimal.valueOf(Math.max(roomCount, 1)), 2, RoundingMode.HALF_UP)
                .doubleValue();
        var availableRoomCount = rooms.stream().filter(room -> room.getStatus() == RoomStatus.AVAILABLE).count();
        var activeRoomRate = roomCount > 0 ? (double) availableRoomCount / roomCount : 0;

        return new double[]{
                Math.min(roomCount / 50.0, 1.0),
                Math.min(averageRoomPrice / 5_000_000.0, 1.0),
                averageRating(hotel) / 5.0,
                Math.min(bookingCount(hotel) / 500.0, 1.0),
                hotel.getHotelImages().isEmpty() ? 0.0 : 1.0,
                activeRoomRate
        };
    }

    private double[] averageVector(List<double[]> vectors) {
        if (vectors.isEmpty()) {
            return new double[6];
        }
        var result = new double[vectors.get(0).length];
        for (var vector : vectors) {
            for (var i = 0; i < vector.length; i++) {
                result[i] += vector[i] / vectors.size();
            }
        }
        return result;
    }

    private double cosine(double[] a, double[] b) {
        if (a.length != b.length) {
            return 0;
        }
        double dot = 0;
        double magA = 0;
        double magB = 0;
        for (var i = 0; i < a.length; i++) {
            dot += a[i] * b[i];
            magA += a[i] * a[i];
            magB += b[i] * b[i];
        }
        return magA == 0 || magB == 0 ? 0 : dot / (Math.sqrt(magA) * Math.sqrt(magB));
    }

    private int bookingCount(Hotel hotel) {
        return (int) hotel.getRooms().stream()
                .flatMap(room -> room.getBookings().stream())
                .filter(booking -> booking.getStatus() == BookingStatus.CONFIRMED ||
                        booking.getStatus() == BookingStatus.COMPLETED)
                .count();
    }

    private double averageRating(Hotel hotel) {
        return hotel.getRooms().stream()
                .flatMap(room -> room.getReviews().stream())
                .mapToInt(review -> review.getRating())
                .average()
                .orElse(0);
    }

    private HotelRecommendationDto map(Hotel hotel, double score) {
        var rooms = hotel.getRooms().stream().filter(room -> !room.isDeleted()).toList();
        var averagePrice = rooms.stream()
                .map(Room::getPrice)
                .reduce(BigDecimal.ZERO, BigDecimal::add)
                .divide(BigDecimal.valueOf(Math.max(rooms.size(), 1)), 2, RoundingMode.HALF_UP);
        var imageUrl = hotel.getHotelImages().stream()
                .sorted(Comparator.comparing(HotelImagePriority::new))
                .map(image -> image.getImageUrl())
                .findFirst()
                .orElse(null);

        return new HotelRecommendationDto(
                hotel.getId(),
                hotel.getName(),
                hotel.getOwner().getId(),
                hotel.getWard().getProvince().getName(),
                hotel.getWard().getName(),
                averagePrice,
                rooms.size(),
                Math.round(averageRating(hotel) * 100.0) / 100.0,
                bookingCount(hotel),
                Math.round(score * 1000.0) / 1000.0,
                imageUrl,
                !hotel.isDeleted() && hotel.getStatus() == HotelStatus.ACTIVE
        );
    }

    private record HotelImagePriority(com.doan.hotelparking.domain.entity.HotelImage image)
            implements Comparable<HotelImagePriority> {
        @Override
        public int compareTo(HotelImagePriority other) {
            var primaryCompare = Boolean.compare(other.image.isPrimaryImage(), image.isPrimaryImage());
            return primaryCompare != 0 ? primaryCompare : Integer.compare(image.getSortOrder(), other.image.getSortOrder());
        }
    }
}
