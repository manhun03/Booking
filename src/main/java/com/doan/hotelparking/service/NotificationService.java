package com.doan.hotelparking.service;

import com.doan.hotelparking.domain.entity.Notification;
import com.doan.hotelparking.domain.entity.User;
import com.doan.hotelparking.domain.enums.NotificationType;
import com.doan.hotelparking.repository.NotificationRepository;
import org.springframework.stereotype.Service;

import java.time.Instant;

@Service
public class NotificationService {
    private final NotificationRepository notifications;
    private final FcmNotificationPushService pushService;

    public NotificationService(NotificationRepository notifications, FcmNotificationPushService pushService) {
        this.notifications = notifications;
        this.pushService = pushService;
    }

    public Notification create(Integer userId, String title, String message, NotificationType type, String relatedTable, Integer relatedId) {
        var user = new User();
        user.setId(userId);
        var notification = new Notification();
        notification.setUser(user);
        notification.setTitle(title);
        notification.setMessage(message);
        notification.setType(type);
        notification.setRelatedTable(relatedTable);
        notification.setRelatedId(relatedId);
        notification.setCreatedAt(Instant.now());
        var saved = notifications.save(notification);
        pushService.pushToUser(saved);
        return saved;
    }
}
