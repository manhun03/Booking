package com.doan.hotelparking.service;

import com.doan.hotelparking.config.JwtProperties;
import com.doan.hotelparking.domain.entity.User;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.security.Keys;
import org.springframework.stereotype.Service;

import javax.crypto.SecretKey;
import java.nio.charset.StandardCharsets;
import java.time.Instant;
import java.util.Date;
import java.util.List;
import java.util.UUID;

@Service
public class JwtService {
    private final JwtProperties properties;
    private final SecretKey key;

    public JwtService(JwtProperties properties) {
        this.properties = properties;
        this.key = Keys.hmacShaKeyFor(properties.secretKey().getBytes(StandardCharsets.UTF_8));
    }

    public String generateAccessToken(User user, List<String> roles) {
        var now = Instant.now();
        var expiresAt = getAccessTokenExpiresAt();
        return Jwts.builder()
                .issuer(properties.issuer())
                .audience().add(properties.audience()).and()
                .subject(user.getId().toString())
                .claim("email", user.getEmail())
                .claim("name", ((user.getLastName() == null ? "" : user.getLastName()) + " " +
                        (user.getFirstName() == null ? "" : user.getFirstName())).trim())
                .claim("roles", roles)
                .issuedAt(Date.from(now))
                .expiration(Date.from(expiresAt))
                .signWith(key)
                .compact();
    }

    public Instant getAccessTokenExpiresAt() {
        return Instant.now().plusSeconds(properties.accessTokenExpirationMinutes() * 60);
    }

    public String generateRefreshToken() {
        return UUID.randomUUID().toString().replace("-", "") + UUID.randomUUID().toString().replace("-", "");
    }

    public JwtPrincipal parse(String token) {
        var claims = Jwts.parser()
                .verifyWith(key)
                .requireIssuer(properties.issuer())
                .build()
                .parseSignedClaims(token)
                .getPayload();
        var userId = Integer.parseInt(claims.getSubject());
        var email = claims.get("email", String.class);
        var roles = claims.get("roles", List.class).stream()
                .map(Object::toString)
                .toList();
        return new JwtPrincipal(userId, email, roles);
    }

    public record JwtPrincipal(Integer userId, String email, List<String> roles) {
    }
}
