package com.doan.hotelparking.config;

import org.springframework.boot.context.properties.ConfigurationProperties;

@ConfigurationProperties(prefix = "app.firebase")
public record FirebaseProperties(String credentialsPath, String projectId) {
}
