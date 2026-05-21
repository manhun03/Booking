package com.doan.hotelparking.service;

import com.doan.hotelparking.domain.entity.Booking;
import com.doan.hotelparking.domain.entity.FavoriteHotel;
import com.doan.hotelparking.domain.entity.Hotel;
import com.doan.hotelparking.domain.entity.HotelImage;
import com.doan.hotelparking.domain.entity.OwnerSetting;
import com.doan.hotelparking.domain.entity.Province;
import com.doan.hotelparking.domain.entity.Room;
import com.doan.hotelparking.domain.entity.User;
import com.doan.hotelparking.domain.entity.Ward;
import com.doan.hotelparking.dto.booking.BookingDto;
import com.doan.hotelparking.dto.hotel.FavoriteHotelDto;
import com.doan.hotelparking.dto.hotel.HotelDto;
import com.doan.hotelparking.dto.hotel.HotelImageDto;
import com.doan.hotelparking.dto.hotel.RoomDto;
import com.doan.hotelparking.dto.location.ProvinceDto;
import com.doan.hotelparking.dto.location.WardDto;
import com.doan.hotelparking.dto.ownersetting.OwnerSettingDto;
import com.doan.hotelparking.dto.user.UserDto;
import org.springframework.stereotype.Component;

@Component
public class DtoMapper {
    public HotelDto toHotelDto(Hotel hotel) {
        var ward = hotel.getWard();
        var province = ward == null ? null : ward.getProvince();
        return new HotelDto(
                hotel.getId(),
                hotel.getOwner() == null ? null : hotel.getOwner().getId(),
                ward == null ? null : ward.getId(),
                hotel.getName(),
                hotel.getStreet(),
                hotel.getPhone(),
                hotel.getDescription(),
                hotel.getStatus() == null ? null : hotel.getStatus().name(),
                hotel.isDeleted(),
                province == null ? null : province.getName(),
                ward == null ? null : ward.getName());
    }

    public RoomDto toRoomDto(Room room) {
        return new RoomDto(
                room.getId(),
                room.getHotel() == null ? null : room.getHotel().getId(),
                room.getRoomType() == null ? null : room.getRoomType().getId(),
                room.getRoomNumber(),
                room.getCapacity(),
                room.getPrice(),
                room.getStatus() == null ? null : room.getStatus().name(),
                room.isDeleted());
    }

    public HotelImageDto toHotelImageDto(HotelImage image) {
        return new HotelImageDto(
                image.getId(),
                image.getHotel() == null ? null : image.getHotel().getId(),
                image.getImageUrl(),
                image.getObjectKey(),
                image.isPrimaryImage(),
                image.getSortOrder());
    }

    public BookingDto toBookingDto(Booking booking) {
        var room = booking.getRoom();
        var hotel = room == null ? null : room.getHotel();
        return new BookingDto(
                booking.getId(),
                room == null ? null : room.getId(),
                booking.getCustomer() == null ? null : booking.getCustomer().getId(),
                booking.getCheckInDate(),
                booking.getCheckOutDate(),
                booking.getNightCount(),
                booking.getGuestCount(),
                booking.getRoomUnitPrice(),
                booking.getTotalAmount(),
                booking.getPaidAmount(),
                booking.getNote(),
                booking.getStatus() == null ? null : booking.getStatus().name(),
                room == null ? null : room.getRoomNumber(),
                hotel == null ? null : hotel.getName());
    }

    public ProvinceDto toProvinceDto(Province province) {
        return new ProvinceDto(province.getId(), province.getName(), province.getCode(), province.isActive());
    }

    public WardDto toWardDto(Ward ward) {
        return new WardDto(
                ward.getId(),
                ward.getProvince() == null ? null : ward.getProvince().getId(),
                ward.getName(),
                ward.getCode(),
                ward.isActive());
    }

    public FavoriteHotelDto toFavoriteHotelDto(FavoriteHotel favorite) {
        var hotel = favorite.getHotel();
        var imageUrl = hotel == null ? null : hotel.getHotelImages().stream()
                .sorted((a, b) -> {
                    var primaryCompare = Boolean.compare(b.isPrimaryImage(), a.isPrimaryImage());
                    return primaryCompare != 0 ? primaryCompare : Integer.compare(a.getSortOrder(), b.getSortOrder());
                })
                .map(HotelImage::getImageUrl)
                .findFirst()
                .orElse(null);
        return new FavoriteHotelDto(
                favorite.getId(),
                favorite.getUser() == null ? null : favorite.getUser().getId(),
                hotel == null ? null : hotel.getId(),
                hotel == null ? null : hotel.getName(),
                imageUrl,
                favorite.getCreatedAt());
    }

    public OwnerSettingDto toOwnerSettingDto(OwnerSetting setting) {
        return new OwnerSettingDto(
                setting.getId(),
                setting.getOwner() == null ? null : setting.getOwner().getId(),
                setting.getDepositRate(),
                setting.getMinBookingNotice(),
                setting.isAllowReview(),
                setting.getBankName(),
                setting.getBankAccountNumber(),
                setting.getBankAccountName(),
                setting.getBankQrCodeUrl());
    }

    public UserDto toUserDto(User user) {
        return new UserDto(
                user.getId(),
                user.getLastName(),
                user.getFirstName(),
                user.getEmail(),
                user.getPhone(),
                user.getAvatarUrl(),
                user.getStatus() == null ? null : user.getStatus().name(),
                user.getCreatedAt());
    }
}
