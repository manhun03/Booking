package com.doan.hotelparking.health;

import com.doan.hotelparking.config.MinioProperties;
import io.minio.BucketExistsArgs;
import io.minio.MinioClient;
import org.springframework.boot.actuate.health.Health;
import org.springframework.boot.actuate.health.HealthIndicator;
import org.springframework.stereotype.Component;

@Component
public class MinioHealthIndicator implements HealthIndicator {
    private final MinioClient minioClient;
    private final MinioProperties properties;

    public MinioHealthIndicator(MinioClient minioClient, MinioProperties properties) {
        this.minioClient = minioClient;
        this.properties = properties;
    }

    @Override
    public Health health() {
        try {
            var exists = minioClient.bucketExists(BucketExistsArgs.builder()
                    .bucket(properties.bucketName())
                    .build());
            return Health.up()
                    .withDetail("endpoint", properties.endpoint())
                    .withDetail("bucket", properties.bucketName())
                    .withDetail("bucketExists", exists)
                    .build();
        } catch (Exception ex) {
            return Health.down(ex)
                    .withDetail("endpoint", properties.endpoint())
                    .withDetail("bucket", properties.bucketName())
                    .build();
        }
    }
}
