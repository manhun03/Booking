package com.doan.hotelparking.health;

import com.doan.hotelparking.config.FirebaseProperties;
import org.springframework.boot.actuate.health.Health;
import org.springframework.boot.actuate.health.HealthIndicator;
import org.springframework.stereotype.Component;

import java.nio.file.Files;
import java.nio.file.Path;

@Component
public class FirebaseHealthIndicator implements HealthIndicator {
    private final FirebaseProperties properties;

    public FirebaseHealthIndicator(FirebaseProperties properties) {
        this.properties = properties;
    }

    @Override
    public Health health() {
        var path = Path.of(properties.credentialsPath());
        if (Files.exists(path)) {
            return Health.up()
                    .withDetail("projectId", properties.projectId())
                    .withDetail("credentialsPath", path.toString())
                    .build();
        }
        return Health.up()
                .withDetail("projectId", properties.projectId())
                .withDetail("credentialsPath", path.toString())
                .withDetail("available", false)
                .withDetail("reason", "Firebase credentials file not found")
                .build();
    }
}
