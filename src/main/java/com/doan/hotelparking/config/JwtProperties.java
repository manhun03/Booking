package com.doan.hotelparking.config;

import org.springframework.boot.context.properties.ConfigurationProperties;

@ConfigurationProperties(prefix = "app.jwt")
public record JwtProperties(
        String issuer,
        String audience,
        String secretKey,
        long accessTokenExpirationMinutes
) {
}
