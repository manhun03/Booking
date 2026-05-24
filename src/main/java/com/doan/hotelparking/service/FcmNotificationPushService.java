package com.doan.hotelparking.service;

import com.doan.hotelparking.config.FirebaseProperties;
import com.doan.hotelparking.domain.entity.Notification;
import com.doan.hotelparking.repository.FcmTokenRepository;
import com.google.auth.oauth2.GoogleCredentials;
import com.google.firebase.FirebaseApp;
import com.google.firebase.FirebaseOptions;
import com.google.firebase.messaging.FirebaseMessaging;
import com.google.firebase.messaging.Message;
import org.springframework.stereotype.Service;

import java.io.FileInputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.Map;

@Service
public class FcmNotificationPushService {
    private final FcmTokenRepository fcmTokens;
    private final FirebaseProperties properties;
    private FirebaseApp firebaseApp;

    public FcmNotificationPushService(FcmTokenRepository fcmTokens, FirebaseProperties properties) {
        this.fcmTokens = fcmTokens;
        this.properties = properties;
    }

    public void pushToUser(Notification notification) {
        var app = getFirebaseApp();
        if (app == null) {
            return;
        }
        var tokens = fcmTokens.findByUserId(notification.getUser().getId());
        for (var token : tokens) {
            if (token.getToken() == null || token.getToken().isBlank()) {
                continue;
            }
            try {
                var message = Message.builder()
                        .setToken(token.getToken())
                        .setNotification(com.google.firebase.messaging.Notification.builder()
                                .setTitle(notification.getTitle() == null ? "Hotel Parking" : notification.getTitle())
                                .setBody(notification.getMessage() == null ? "" : notification.getMessage())
                                .build())
                        .putAllData(Map.of(
                                "notificationId", notification.getId().toString(),
                                "userId", notification.getUser().getId().toString(),
                                "title", notification.getTitle() == null ? "" : notification.getTitle(),
                                "message", notification.getMessage() == null ? "" : notification.getMessage(),
                                "type", notification.getType().name(),
                                "relatedTable", notification.getRelatedTable() == null ? "" : notification.getRelatedTable(),
                                "relatedId", notification.getRelatedId() == null ? "" : notification.getRelatedId().toString()))
                        .build();
                FirebaseMessaging.getInstance(app).send(message);
            } catch (Exception ignored) {
                // Keep notification persistence independent from push delivery.
            }
        }
    }

    private synchronized FirebaseApp getFirebaseApp() {
        if (firebaseApp != null) {
            return firebaseApp;
        }
        try {
            var path = Path.of(properties.credentialsPath());
            if (!Files.exists(path)) {
                return null;
            }
            try (var stream = new FileInputStream(path.toFile())) {
                var options = FirebaseOptions.builder()
                        .setCredentials(GoogleCredentials.fromStream(stream))
                        .setProjectId(properties.projectId())
                        .build();
                firebaseApp = FirebaseApp.initializeApp(options, "hotel-booking-api");
                return firebaseApp;
            }
        } catch (Exception ex) {
            return null;
        }
    }
}
