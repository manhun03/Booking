package com.doan.hotelparking.service;

import com.doan.hotelparking.domain.entity.Booking;
import com.doan.hotelparking.domain.entity.ChatMessage;
import com.doan.hotelparking.domain.entity.FavoriteHotel;
import com.doan.hotelparking.domain.entity.Hotel;
import com.doan.hotelparking.domain.entity.HotelImage;
import com.doan.hotelparking.domain.entity.Notification;
import com.doan.hotelparking.domain.entity.OwnerSetting;
import com.doan.hotelparking.domain.entity.Payment;
import com.doan.hotelparking.domain.entity.Permission;
import com.doan.hotelparking.domain.entity.Province;
import com.doan.hotelparking.domain.entity.Review;
import com.doan.hotelparking.domain.entity.Role;
import com.doan.hotelparking.domain.entity.Room;
import com.doan.hotelparking.domain.entity.RoomType;
import com.doan.hotelparking.domain.entity.TimeSlot;
import com.doan.hotelparking.domain.entity.User;
import com.doan.hotelparking.domain.entity.Ward;
import com.doan.hotelparking.dto.booking.BookingDto;
import com.doan.hotelparking.dto.common.SimpleDtos.ChatMessageDto;
import com.doan.hotelparking.dto.common.SimpleDtos.NotificationDto;
import com.doan.hotelparking.dto.common.SimpleDtos.PaymentDto;
import com.doan.hotelparking.dto.common.SimpleDtos.PermissionDto;
import com.doan.hotelparking.dto.common.SimpleDtos.ReviewDto;
import com.doan.hotelparking.dto.common.SimpleDtos.RoleDto;
import com.doan.hotelparking.dto.common.SimpleDtos.RoomTypeDto;
import com.doan.hotelparking.dto.common.SimpleDtos.TimeSlotDto;
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

    public NotificationDto toNotificationDto(Notification notification) {
        return new NotificationDto(
                notification.getId(),
                notification.getUser() == null ? null : notification.getUser().getId(),
                notification.getSender() == null ? null : notification.getSender().getId(),
                notification.getTitle(),
                notification.getMessage(),
                notification.getType() == null ? null : notification.getType().name(),
                notification.getRelatedTable(),
                notification.getRelatedId(),
                notification.isRead(),
                notification.getCreatedAt(),
                notification.getReadAt());
    }

    public ChatMessageDto toChatMessageDto(ChatMessage message) {
        return new ChatMessageDto(
                message.getId(),
                message.getSender() == null ? null : message.getSender().getId(),
                message.getReceiver() == null ? null : message.getReceiver().getId(),
                message.getBooking() == null ? null : message.getBooking().getId(),
                message.getContent(),
                message.isRead(),
                message.getCreatedAt(),
                message.getReadAt());
    }

    public PaymentDto toPaymentDto(Payment payment) {
        return new PaymentDto(
                payment.getId(),
                payment.getBooking() == null ? null : payment.getBooking().getId(),
                payment.getAmount(),
                payment.getMethod(),
                payment.getProvider(),
                payment.getStatus() == null ? null : payment.getStatus().name(),
                payment.getTransactionCode(),
                payment.getGatewayTransactionId(),
                payment.getCheckoutUrl(),
                payment.getFailureReason(),
                payment.getRefundedAmount(),
                payment.getNote(),
                payment.getPaidAt(),
                payment.getRefundedAt(),
                payment.getCreatedAt(),
                payment.getUpdatedAt());
    }

    public RoleDto toRoleDto(Role role) {
        return new RoleDto(
                role.getId(),
                role.getName(),
                role.getDescription(),
                role.isActive(),
                role.getCreatedAt(),
                role.getUpdatedAt());
    }

    public PermissionDto toPermissionDto(Permission permission) {
        return new PermissionDto(
                permission.getId(),
                permission.getPermissionKey(),
                permission.getDescription(),
                permission.getModule(),
                permission.getCreatedAt(),
                permission.getUpdatedAt());
    }

    public ReviewDto toReviewDto(Review review) {
        return new ReviewDto(
                review.getId(),
                review.getBooking() == null ? null : review.getBooking().getId(),
                review.getCustomer() == null ? null : review.getCustomer().getId(),
                review.getRoom() == null ? null : review.getRoom().getId(),
                review.getRating(),
                review.getComment(),
                review.getOwnerReply(),
                review.getOwnerRepliedAt(),
                review.isReported(),
                review.getReportReason(),
                review.isVisible(),
                review.getModeratedAt(),
                review.getCreatedAt());
    }

    public RoomTypeDto toRoomTypeDto(RoomType roomType) {
        return new RoomTypeDto(roomType.getId(), roomType.getName(), roomType.getDescription());
    }

    public TimeSlotDto toTimeSlotDto(TimeSlot timeSlot) {
        return new TimeSlotDto(
                timeSlot.getId(),
                timeSlot.getRoom() == null ? null : timeSlot.getRoom().getId(),
                timeSlot.getStartDate(),
                timeSlot.getEndDate(),
                timeSlot.getPrice(),
                timeSlot.isActive(),
                timeSlot.getCreatedAt(),
                timeSlot.getUpdatedAt());
    }
}
