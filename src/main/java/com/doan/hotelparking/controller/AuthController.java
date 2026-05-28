package com.doan.hotelparking.controller;

import com.doan.hotelparking.common.ApiResponse;
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
import com.doan.hotelparking.service.AuthService;
import jakarta.validation.Valid;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/auth")
public class AuthController {
    private final AuthService authService;

    public AuthController(AuthService authService) {
        this.authService = authService;
    }

    @PostMapping("/register")
    public ApiResponse<AuthResponse> register(@Valid @RequestBody RegisterRequest request) {
        return ApiResponse.ok(authService.register(request));
    }

    @PostMapping("/login")
    public ApiResponse<AuthResponse> login(@Valid @RequestBody LoginRequest request) {
        return ApiResponse.ok(authService.login(request));
    }

    @PostMapping("/refresh-token")
    public ApiResponse<AuthResponse> refreshToken(@Valid @RequestBody RefreshTokenRequest request) {
        return ApiResponse.ok("Refresh token successfully", authService.refreshToken(request));
    }

    @PostMapping("/forgot-password")
    public ApiResponse<AuthActionResponse> forgotPassword(@Valid @RequestBody ForgotPasswordRequest request) {
        return ApiResponse.ok(authService.forgotPassword(request));
    }

    @PostMapping("/reset-password")
    public ApiResponse<AuthActionResponse> resetPassword(@Valid @RequestBody ResetPasswordRequest request) {
        return ApiResponse.ok(authService.resetPassword(request));
    }

    @PostMapping("/send-email-verification")
    public ApiResponse<AuthActionResponse> sendEmailVerification(@Valid @RequestBody EmailRequest request) {
        return ApiResponse.ok(authService.sendEmailVerification(request));
    }

    @PostMapping("/verify-email")
    public ApiResponse<AuthActionResponse> verifyEmail(@Valid @RequestBody VerifyEmailRequest request) {
        return ApiResponse.ok(authService.verifyEmail(request));
    }

    @PostMapping("/change-password")
    @PreAuthorize("hasRole('Customer')")
    public ApiResponse<AuthActionResponse> changePassword(@Valid @RequestBody ChangePasswordRequest request) {
        return ApiResponse.ok(authService.changePassword(request));
    }

    @PostMapping("/google")
    public ApiResponse<AuthResponse> googleLogin(@Valid @RequestBody GoogleLoginRequest request) {
        return ApiResponse.ok(authService.googleLogin(request));
    }
}
