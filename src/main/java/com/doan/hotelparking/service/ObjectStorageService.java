package com.doan.hotelparking.service;

import com.doan.hotelparking.config.MinioProperties;
import io.minio.*;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.util.UUID;

@Service
public class ObjectStorageService {
    private final MinioClient minioClient;
    private final MinioProperties properties;
    private volatile boolean bucketInitialized;

    public ObjectStorageService(MinioClient minioClient, MinioProperties properties) {
        this.minioClient = minioClient;
        this.properties = properties;
    }

    public UploadedObject upload(MultipartFile file, String folder) {
        try {
            ensureBucketExists();
            var originalName = file.getOriginalFilename() == null ? "file" : file.getOriginalFilename();
            var extension = originalName.contains(".") ? originalName.substring(originalName.lastIndexOf('.')) : "";
            var objectKey = folder + "/" + UUID.randomUUID() + extension;
            minioClient.putObject(PutObjectArgs.builder()
                    .bucket(properties.bucketName())
                    .object(objectKey)
                    .stream(file.getInputStream(), file.getSize(), -1)
                    .contentType(file.getContentType() == null ? "application/octet-stream" : file.getContentType())
                    .build());
            return new UploadedObject(objectKey, buildObjectUrl(objectKey));
        } catch (Exception ex) {
            throw new IllegalArgumentException("Unable to upload file to MinIO: " + ex.getMessage(), ex);
        }
    }

    public void delete(String objectKey) {
        try {
            minioClient.removeObject(RemoveObjectArgs.builder()
                    .bucket(properties.bucketName())
                    .object(objectKey)
                    .build());
        } catch (Exception ex) {
            throw new IllegalArgumentException("Unable to delete file from MinIO: " + ex.getMessage(), ex);
        }
    }

    private synchronized void ensureBucketExists() throws Exception {
        if (bucketInitialized) {
            return;
        }
        var exists = minioClient.bucketExists(BucketExistsArgs.builder().bucket(properties.bucketName()).build());
        if (!exists) {
            if (!properties.autoCreateBucket()) {
                throw new IllegalStateException("MinIO bucket '" + properties.bucketName() + "' does not exist");
            }
            minioClient.makeBucket(MakeBucketArgs.builder().bucket(properties.bucketName()).build());
        }
        bucketInitialized = true;
    }

    private String buildObjectUrl(String objectKey) {
        var baseUrl = properties.publicBaseUrl() == null || properties.publicBaseUrl().isBlank()
                ? properties.endpoint()
                : properties.publicBaseUrl();
        return baseUrl.replaceAll("/+$", "") + "/" + properties.bucketName() + "/" + objectKey;
    }

    public record UploadedObject(String objectKey, String url) {
    }
}
