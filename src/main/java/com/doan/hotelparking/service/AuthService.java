package com.doan.hotelparking.service;

import com.doan.hotelparking.domain.entity.User;
import com.doan.hotelparking.domain.entity.UserRole;
import com.doan.hotelparking.domain.entity.UserRoleId;
import com.doan.hotelparking.domain.entity.RefreshToken;
import com.doan.hotelparking.domain.enums.UserStatus;
import com.doan.hotelparking.dto.auth.AuthResponse;
import com.doan.hotelparking.dto.auth.LoginRequest;
import com.doan.hotelparking.dto.auth.RefreshTokenRequest;
import com.doan.hotelparking.dto.auth.RegisterRequest;
import com.doan.hotelparking.repository.RefreshTokenRepository;
import com.doan.hotelparking.repository.RoleRepository;
import com.doan.hotelparking.repository.UserRoleRepository;
import com.doan.hotelparking.repository.UserRepository;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.util.List;

@Service
public class AuthService {
    private final UserRepository users;
    private final RoleRepository roles;
    private final UserRoleRepository userRoles;
    private final RefreshTokenRepository refreshTokens;
    private final PasswordEncoder passwordEncoder;
    private final JwtService jwtService;

    public AuthService(UserRepository users,
                       RoleRepository roles,
                       UserRoleRepository userRoles,
                       RefreshTokenRepository refreshTokens,
                       PasswordEncoder passwordEncoder,
                       JwtService jwtService) {
        this.users = users;
        this.roles = roles;
        this.userRoles = userRoles;
        this.refreshTokens = refreshTokens;
        this.passwordEncoder = passwordEncoder;
        this.jwtService = jwtService;
    }

    @Transactional
    public AuthResponse register(RegisterRequest request) {
        var normalizedEmail = request.email().trim().toLowerCase();
        users.findByEmail(normalizedEmail).ifPresent(existing -> {
            throw new IllegalArgumentException("Email already exists");
        });

        var selectedRole = request.role() == null || request.role().isBlank() ? "Customer" : request.role().trim();
        var role = roles.findByName(selectedRole)
                .or(() -> roles.findByName("Customer"))
                .orElseThrow(() -> new IllegalArgumentException("Default role 'Customer' was not found"));

        var user = new User();
        user.setLastName(request.lastName());
        user.setFirstName(request.firstName());
        user.setEmail(normalizedEmail);
        user.setPhone(request.phone());
        user.setPassword(passwordEncoder.encode(request.password()));
        user.setStatus(UserStatus.ACTIVE);
        user.setCreatedAt(Instant.now());
        users.save(user);

        var userRole = new UserRole();
        userRole.setId(new UserRoleId(user.getId(), role.getId()));
        userRole.setUser(user);
        userRole.setRole(role);
        userRole.setCreatedAt(Instant.now());
        userRoles.save(userRole);

        var refreshToken = createRefreshToken(user);
        refreshTokens.save(refreshToken);

        return buildAuthResponse(user, List.of(role.getName()), refreshToken.getToken());
    }

    @Transactional
    public AuthResponse login(LoginRequest request) {
        var user = users.findByEmail(request.email().trim().toLowerCase())
                .orElseThrow(() -> new IllegalArgumentException("Invalid email or password"));
        if (!passwordEncoder.matches(request.password(), user.getPassword())) {
            throw new IllegalArgumentException("Invalid email or password");
        }
        if (user.getStatus() != UserStatus.ACTIVE || user.isDeleted()) {
            throw new IllegalArgumentException("User is not active");
        }
        var roleNames = userRoles.findRoleNamesByUserId(user.getId());
        var refreshToken = createRefreshToken(user);
        refreshTokens.save(refreshToken);
        return buildAuthResponse(user, roleNames, refreshToken.getToken());
    }

    @Transactional
    public AuthResponse refreshToken(RefreshTokenRequest request) {
        var storedToken = refreshTokens.findByToken(request.refreshToken())
                .orElseThrow(() -> new IllegalArgumentException("Invalid or expired refresh token"));
        if (storedToken.isRevoked() || storedToken.getExpiresAt().isBefore(Instant.now())) {
            throw new IllegalArgumentException("Invalid or expired refresh token");
        }
        var user = storedToken.getUser();
        if (user.getStatus() != UserStatus.ACTIVE || user.isDeleted()) {
            throw new IllegalArgumentException("User is not active");
        }
        storedToken.setRevoked(true);
        refreshTokens.save(storedToken);

        var newRefreshToken = createRefreshToken(user);
        refreshTokens.save(newRefreshToken);
        return buildAuthResponse(user, userRoles.findRoleNamesByUserId(user.getId()), newRefreshToken.getToken());
    }

    private RefreshToken createRefreshToken(User user) {
        var refreshToken = new RefreshToken();
        refreshToken.setUser(user);
        refreshToken.setToken(jwtService.generateRefreshToken());
        refreshToken.setExpiresAt(Instant.now().plusSeconds(7 * 24 * 60 * 60));
        refreshToken.setRevoked(false);
        refreshToken.setCreatedAt(Instant.now());
        return refreshToken;
    }

    private AuthResponse buildAuthResponse(User user, List<String> roles, String refreshToken) {
        var fullName = ((user.getLastName() == null ? "" : user.getLastName()) + " " +
                (user.getFirstName() == null ? "" : user.getFirstName())).trim();
        return new AuthResponse(
                user.getId(),
                fullName,
                user.getEmail(),
                roles,
                jwtService.generateAccessToken(user, roles),
                refreshToken,
                jwtService.getAccessTokenExpiresAt());
    }
}
