package com.doan.hotelparking.service;

import com.doan.hotelparking.domain.entity.User;
import com.doan.hotelparking.domain.entity.UserRole;
import com.doan.hotelparking.domain.entity.UserRoleId;
import com.doan.hotelparking.domain.entity.RefreshToken;
import com.doan.hotelparking.domain.entity.AuthToken;
import com.doan.hotelparking.domain.enums.AuthTokenType;
import com.doan.hotelparking.domain.enums.UserStatus;
import com.doan.hotelparking.dto.auth.AuthActionResponse;
import com.doan.hotelparking.dto.auth.AuthResponse;
import com.doan.hotelparking.dto.auth.ChangePasswordRequest;
import com.doan.hotelparking.dto.auth.EmailRequest;
import com.doan.hotelparking.dto.auth.ForgotPasswordRequest;
import com.doan.hotelparking.dto.auth.GoogleLoginRequest;
import com.doan.hotelparking.dto.auth.LoginRequest;
import com.doan.hotelparking.dto.auth.RefreshTokenRequest;
import com.doan.hotelparking.dto.auth.RegisterRequest;
import com.doan.hotelparking.dto.auth.ResetPasswordRequest;
import com.doan.hotelparking.dto.auth.VerifyEmailRequest;
import com.doan.hotelparking.repository.AuthTokenRepository;
import com.doan.hotelparking.repository.RefreshTokenRepository;
import com.doan.hotelparking.repository.RoleRepository;
import com.doan.hotelparking.repository.UserRoleRepository;
import com.doan.hotelparking.repository.UserRepository;
import com.google.api.client.googleapis.auth.oauth2.GoogleIdToken;
import com.google.api.client.googleapis.auth.oauth2.GoogleIdTokenVerifier;
import com.google.api.client.http.javanet.NetHttpTransport;
import com.google.api.client.json.gson.GsonFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.io.IOException;
import java.security.GeneralSecurityException;
import java.security.SecureRandom;
import java.time.Instant;
import java.util.Base64;
import java.util.Collections;
import java.util.List;

@Service
public class AuthService {
    private final UserRepository users;
    private final RoleRepository roles;
    private final UserRoleRepository userRoles;
    private final RefreshTokenRepository refreshTokens;
    private final AuthTokenRepository authTokens;
    private final PasswordEncoder passwordEncoder;
    private final JwtService jwtService;
    private final CurrentUserService currentUser;
    private final MailService mailService;
    private final String googleClientId;
    private final SecureRandom secureRandom = new SecureRandom();

    public AuthService(UserRepository users,
                       RoleRepository roles,
                       UserRoleRepository userRoles,
                       RefreshTokenRepository refreshTokens,
                       AuthTokenRepository authTokens,
                       PasswordEncoder passwordEncoder,
                       JwtService jwtService,
                       CurrentUserService currentUser,
                       MailService mailService,
                       @Value("${app.google.client-id:}") String googleClientId) {
        this.users = users;
        this.roles = roles;
        this.userRoles = userRoles;
        this.refreshTokens = refreshTokens;
        this.authTokens = authTokens;
        this.passwordEncoder = passwordEncoder;
        this.jwtService = jwtService;
        this.currentUser = currentUser;
        this.mailService = mailService;
        this.googleClientId = googleClientId;
    }

    @Transactional
    public AuthResponse register(RegisterRequest request) {
        var normalizedEmail = request.email().trim().toLowerCase();
        var normalizedUsername = request.username().trim();
        users.findByEmail(normalizedEmail).ifPresent(existing -> {
            throw new IllegalArgumentException("Email already exists");
        });
        users.findByUsername(normalizedUsername).ifPresent(existing -> {
            throw new IllegalArgumentException("Username already exists");
        });

        var selectedRole = request.role() == null || request.role().isBlank() ? "Customer" : request.role().trim();
        var role = roles.findByName(selectedRole)
                .or(() -> roles.findByName("Customer"))
                .orElseThrow(() -> new IllegalArgumentException("Default role 'Customer' was not found"));

        var user = new User();
        user.setLastName(request.lastName());
        user.setFirstName(request.firstName());
        user.setEmail(normalizedEmail);
        user.setUsername(normalizedUsername);
        user.setPhone(request.phone());
        user.setPassword(passwordEncoder.encode(request.password()));
        user.setStatus(UserStatus.ACTIVE);
        user.setEmailVerified(false);
        user.setCreatedAt(Instant.now());
        users.save(user);

        assignRole(user, role.getName());

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

    @Transactional
    public AuthActionResponse forgotPassword(ForgotPasswordRequest request) {
        var normalizedEmail = request.email().trim().toLowerCase();
        var user = users.findByEmail(normalizedEmail).orElse(null);
        if (user == null || user.isDeleted()) {
            return new AuthActionResponse("If the email exists, a reset token has been generated.", null, null);
        }
        var token = createAuthToken(user, AuthTokenType.PASSWORD_RESET, 30 * 60);
        mailService.send(user.getEmail(), "Reset your password", "Use this token to reset your password: " + token.getToken());
        return new AuthActionResponse("Password reset token generated.", token.getToken(), token.getExpiresAt());
    }

    @Transactional
    public AuthActionResponse resetPassword(ResetPasswordRequest request) {
        var token = requireUsableToken(request.token(), AuthTokenType.PASSWORD_RESET);
        var user = token.getUser();
        user.setPassword(passwordEncoder.encode(request.newPassword()));
        user.setUpdatedAt(Instant.now());
        users.save(user);
        token.setUsedAt(Instant.now());
        authTokens.save(token);
        return new AuthActionResponse("Password has been reset.", null, null);
    }

    @Transactional
    public AuthActionResponse sendEmailVerification(EmailRequest request) {
        var normalizedEmail = request.email().trim().toLowerCase();
        var user = users.findByEmail(normalizedEmail)
                .orElseThrow(() -> new IllegalArgumentException("User not found"));
        if (user.isEmailVerified()) {
            return new AuthActionResponse("Email is already verified.", null, null);
        }
        var token = createAuthToken(user, AuthTokenType.EMAIL_VERIFICATION, 24 * 60 * 60);
        mailService.send(user.getEmail(), "Verify your email", "Use this token to verify your email: " + token.getToken());
        return new AuthActionResponse("Email verification token generated.", token.getToken(), token.getExpiresAt());
    }

    @Transactional
    public AuthActionResponse verifyEmail(VerifyEmailRequest request) {
        var token = requireUsableToken(request.token(), AuthTokenType.EMAIL_VERIFICATION);
        var user = token.getUser();
        user.setEmailVerified(true);
        user.setUpdatedAt(Instant.now());
        users.save(user);
        token.setUsedAt(Instant.now());
        authTokens.save(token);
        return new AuthActionResponse("Email has been verified.", null, null);
    }

    @Transactional
    public AuthActionResponse changePassword(ChangePasswordRequest request) {
        var user = users.findById(currentUser.requireUserId())
                .orElseThrow(() -> new IllegalArgumentException("User not found"));
        if (user.getPassword() == null || !passwordEncoder.matches(request.currentPassword(), user.getPassword())) {
            throw new IllegalArgumentException("Current password is incorrect");
        }
        user.setPassword(passwordEncoder.encode(request.newPassword()));
        user.setUpdatedAt(Instant.now());
        users.save(user);
        return new AuthActionResponse("Password changed successfully.", null, null);
    }

    @Transactional
    public AuthResponse googleLogin(GoogleLoginRequest request) {
        var payload = verifyGoogleToken(request.idToken());
        var email = String.valueOf(payload.getEmail()).trim().toLowerCase();
        if (email.isBlank()) {
            throw new IllegalArgumentException("Google account email is missing");
        }

        var user = users.findByEmail(email).orElseGet(() -> createGoogleUser(payload, request.role()));
        if (user.getStatus() != UserStatus.ACTIVE || user.isDeleted()) {
            throw new IllegalArgumentException("User is not active");
        }
        if (!user.isEmailVerified()) {
            user.setEmailVerified(Boolean.TRUE.equals(payload.getEmailVerified()));
            user.setUpdatedAt(Instant.now());
            users.save(user);
        }
        var roleNames = userRoles.findRoleNamesByUserId(user.getId());
        var refreshToken = createRefreshToken(user);
        refreshTokens.save(refreshToken);
        return buildAuthResponse(user, roleNames, refreshToken.getToken());
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

    private AuthToken createAuthToken(User user, AuthTokenType type, long validSeconds) {
        var bytes = new byte[32];
        secureRandom.nextBytes(bytes);
        var token = new AuthToken();
        token.setUser(user);
        token.setType(type);
        token.setToken(Base64.getUrlEncoder().withoutPadding().encodeToString(bytes));
        token.setExpiresAt(Instant.now().plusSeconds(validSeconds));
        token.setCreatedAt(Instant.now());
        return authTokens.save(token);
    }

    private AuthToken requireUsableToken(String tokenValue, AuthTokenType type) {
        var token = authTokens.findByTokenAndType(tokenValue, type)
                .orElseThrow(() -> new IllegalArgumentException("Invalid or expired token"));
        if (!token.isUsable()) {
            throw new IllegalArgumentException("Invalid or expired token");
        }
        return token;
    }

    private void assignRole(User user, String roleName) {
        var role = roles.findByName(roleName)
                .or(() -> roles.findByName("Customer"))
                .orElseThrow(() -> new IllegalArgumentException("Default role 'Customer' was not found"));
        var userRole = new UserRole();
        userRole.setId(new UserRoleId(user.getId(), role.getId()));
        userRole.setUser(user);
        userRole.setRole(role);
        userRole.setCreatedAt(Instant.now());
        userRoles.save(userRole);
    }

    private User createGoogleUser(GoogleIdToken.Payload payload, String requestedRole) {
        var fullName = payload.get("name") == null ? "" : payload.get("name").toString().trim();
        var parts = fullName.split("\\s+");
        var user = new User();
        user.setEmail(payload.getEmail().trim().toLowerCase());
        user.setUsername(generateGoogleUsername(payload));
        user.setFirstName(parts.length == 0 || fullName.isBlank() ? payload.getEmail() : parts[parts.length - 1]);
        user.setLastName(parts.length <= 1 ? "" : String.join(" ", java.util.Arrays.copyOf(parts, parts.length - 1)));
        user.setAvatarUrl(payload.get("picture") == null ? null : payload.get("picture").toString());
        user.setPassword(passwordEncoder.encode(generateInternalPassword()));
        user.setStatus(UserStatus.ACTIVE);
        user.setEmailVerified(Boolean.TRUE.equals(payload.getEmailVerified()));
        user.setCreatedAt(Instant.now());
        users.save(user);
        assignRole(user, requestedRole == null || requestedRole.isBlank() ? "Customer" : requestedRole.trim());
        return user;
    }

    private GoogleIdToken.Payload verifyGoogleToken(String idToken) {
        if (googleClientId == null || googleClientId.isBlank()) {
            throw new IllegalArgumentException("Google login is not configured. Set GOOGLE_CLIENT_ID.");
        }
        try {
            var verifier = new GoogleIdTokenVerifier.Builder(new NetHttpTransport(), GsonFactory.getDefaultInstance())
                    .setAudience(Collections.singletonList(googleClientId))
                    .build();
            var verifiedToken = verifier.verify(idToken);
            if (verifiedToken == null) {
                throw new IllegalArgumentException("Invalid Google ID token");
            }
            return verifiedToken.getPayload();
        } catch (GeneralSecurityException | IOException ex) {
            throw new IllegalArgumentException("Unable to verify Google ID token", ex);
        }
    }

    private String generateInternalPassword() {
        var bytes = new byte[24];
        secureRandom.nextBytes(bytes);
        return Base64.getUrlEncoder().withoutPadding().encodeToString(bytes);
    }

    private String generateGoogleUsername(GoogleIdToken.Payload payload) {
        var email = payload.getEmail() == null ? "googleuser" : payload.getEmail();
        var base = email.split("@")[0].replaceAll("[^A-Za-z0-9_]", "");
        if (base.length() < 4) {
            base = (base + "user").substring(0, 4);
        }
        if (base.length() > 16) {
            base = base.substring(0, 16);
        }
        var username = base;
        var suffix = 1;
        while (users.findByUsername(username).isPresent()) {
            var tail = String.valueOf(suffix++);
            var prefixLength = Math.min(base.length(), 20 - tail.length());
            username = base.substring(0, prefixLength) + tail;
        }
        return username;
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
