package com.doan.hotelparking.service;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatusCode;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import java.io.IOException;
import java.net.URI;
import java.net.URLEncoder;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.nio.charset.StandardCharsets;
import java.time.Duration;
import java.util.Map;

@Service
public class AiChatProxyService {
    private final HttpClient httpClient;
    private final ObjectMapper objectMapper;
    private final String baseUrl;

    public AiChatProxyService(ObjectMapper objectMapper,
                              @Value("${app.ai-agent.base-url:http://localhost:8000}") String baseUrl) {
        this.objectMapper = objectMapper;
        this.baseUrl = baseUrl == null ? "http://localhost:8000" : baseUrl.replaceAll("/+$", "");
        this.httpClient = HttpClient.newBuilder()
                .connectTimeout(Duration.ofSeconds(5))
                .build();
    }

    public JsonNode get(String path, String authorization) {
        return forward("GET", path, authorization, null);
    }

    public JsonNode post(String path, String authorization, Map<String, Object> body) {
        return forward("POST", path, authorization, body);
    }

    public void delete(String path, String authorization) {
        forward("DELETE", path, authorization, null);
    }

    public String path(String value) {
        return URLEncoder.encode(value, StandardCharsets.UTF_8).replace("+", "%20");
    }

    private JsonNode forward(String method, String path, String authorization, Map<String, Object> body) {
        try {
            var request = buildRequest(method, path, authorization, body);
            var response = httpClient.send(request, HttpResponse.BodyHandlers.ofString(StandardCharsets.UTF_8));
            if (response.statusCode() >= 400) {
                throw new ResponseStatusException(
                        HttpStatusCode.valueOf(response.statusCode()),
                        response.body() == null || response.body().isBlank() ? "AI chat service error" : response.body());
            }
            if (response.statusCode() == 204 || response.body() == null || response.body().isBlank()) {
                return objectMapper.createObjectNode();
            }
            return objectMapper.readTree(response.body());
        } catch (ResponseStatusException ex) {
            throw ex;
        } catch (IOException ex) {
            throw new ResponseStatusException(HttpStatusCode.valueOf(502), "Invalid AI chat response", ex);
        } catch (InterruptedException ex) {
            Thread.currentThread().interrupt();
            throw new ResponseStatusException(HttpStatusCode.valueOf(502), "AI chat request interrupted", ex);
        } catch (Exception ex) {
            throw new ResponseStatusException(HttpStatusCode.valueOf(502), "Cannot connect to AI chat service", ex);
        }
    }

    private HttpRequest buildRequest(String method, String path, String authorization, Map<String, Object> body) throws IOException {
        var builder = HttpRequest.newBuilder()
                .uri(URI.create(baseUrl + path))
                .timeout(Duration.ofSeconds(120))
                .header("Accept", "application/json");
        if (authorization != null && !authorization.isBlank()) {
            builder.header("Authorization", authorization);
        }
        if ("POST".equals(method)) {
            builder.header("Content-Type", "application/json");
            builder.POST(HttpRequest.BodyPublishers.ofString(
                    objectMapper.writeValueAsString(body == null ? Map.of() : body),
                    StandardCharsets.UTF_8));
        } else if ("DELETE".equals(method)) {
            builder.DELETE();
        } else {
            builder.GET();
        }
        return builder.build();
    }
}
