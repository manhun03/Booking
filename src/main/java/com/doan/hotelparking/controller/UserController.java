package com.doan.hotelparking.controller;

import com.doan.hotelparking.domain.entity.User;
import com.doan.hotelparking.domain.entity.FcmToken;
import com.doan.hotelparking.common.ApiResponse;
import com.doan.hotelparking.common.ApiPagedResponse;
import com.doan.hotelparking.dto.user.UpdateFcmTokenRequest;
import com.doan.hotelparking.dto.user.UpdateProfileRequest;
import com.doan.hotelparking.dto.user.UserDto;
import com.doan.hotelparking.repository.FcmTokenRepository;
import com.doan.hotelparking.repository.UserRepository;
import com.doan.hotelparking.service.CurrentUserService;
import com.doan.hotelparking.service.DtoMapper;
import com.doan.hotelparking.service.ObjectStorageService;
import com.doan.hotelparking.security.HasPermission;
import jakarta.validation.Valid;
import org.springframework.data.domain.PageRequest;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

import java.time.Instant;

@RestController
@RequestMapping("/api/users")
public class UserController {
    private final UserRepository users;
    private final FcmTokenRepository fcmTokens;
    private final CurrentUserService currentUser;
    private final DtoMapper mapper;
    private final ObjectStorageService storage;
    private final PasswordEncoder passwordEncoder;

    public UserController(UserRepository repository,
                          FcmTokenRepository fcmTokens,
                          CurrentUserService currentUser,
                          DtoMapper mapper,
                          ObjectStorageService storage,
                          PasswordEncoder passwordEncoder) {
        this.users = repository;
        this.fcmTokens = fcmTokens;
        this.currentUser = currentUser;
        this.mapper = mapper;
        this.storage = storage;
        this.passwordEncoder = passwordEncoder;
    }

    @GetMapping
    @PreAuthorize("hasRole('Admin')")
    @HasPermission("user.read")
    public ApiPagedResponse<UserDto> getAll(@RequestParam(defaultValue = "1") int pageIndex,
                                            @RequestParam(defaultValue = "20") int pageSize) {
        var page = users.findAll(PageRequest.of(Math.max(pageIndex, 1) - 1, Math.min(Math.max(pageSize, 1), 100)));
        return ApiPagedResponse.ok(page.getContent().stream().map(mapper::toUserDto).toList(),
                pageIndex, pageSize, page.getTotalElements());
    }

    @GetMapping("/me")
    public ApiResponse<UserDto> me() {
        var user = users.findById(currentUser.requireUserId())
                .orElseThrow(() -> new IllegalArgumentException("User not found"));
        return ApiResponse.ok(mapper.toUserDto(user));
    }

    @PutMapping("/me")
    public ApiResponse<UserDto> updateMe(@RequestBody UpdateProfileRequest request) {
        var user = users.findById(currentUser.requireUserId())
                .orElseThrow(() -> new IllegalArgumentException("User not found"));
        user.setFirstName(clean(request.firstName()));
        user.setLastName(clean(request.lastName()));
        user.setPhone(clean(request.phone()));
        user.setAvatarUrl(clean(request.avatarUrl()));
        user.setUpdatedAt(Instant.now());
        return ApiResponse.ok("Updated", mapper.toUserDto(users.save(user)));
    }

    @GetMapping("/{id}")
    public ApiResponse<UserDto> getById(@PathVariable Integer id) {
        requireSelfOrAdmin(id);
        return ApiResponse.ok(users.findById(id).map(mapper::toUserDto)
                .orElseThrow(() -> new IllegalArgumentException("User not found")));
    }

    @PostMapping
    @PreAuthorize("hasRole('Admin')")
    @HasPermission("user.manage")
    public ApiResponse<UserDto> create(@RequestBody User request) {
        var user = new User();
        user.setFirstName(request.getFirstName());
        user.setLastName(request.getLastName());
        user.setEmail(request.getEmail() == null ? null : request.getEmail().trim().toLowerCase());
        user.setPhone(request.getPhone());
        user.setAvatarUrl(request.getAvatarUrl());
        user.setStatus(request.getStatus());
        user.setPassword(request.getPassword() == null ? null : passwordEncoder.encode(request.getPassword()));
        user.setCreatedAt(Instant.now());
        return ApiResponse.ok("Created", mapper.toUserDto(users.save(user)));
    }

    @PutMapping("/{id}")
    public ApiResponse<UserDto> update(@PathVariable Integer id, @RequestBody User request) {
        var admin = isAdmin();
        if (!admin) {
            requireSelfOrAdmin(id);
        }
        var user = users.findById(id).orElseThrow(() -> new IllegalArgumentException("User not found"));
        user.setFirstName(request.getFirstName());
        user.setLastName(request.getLastName());
        user.setPhone(request.getPhone());
        user.setAvatarUrl(request.getAvatarUrl());
        if (admin) {
            user.setStatus(request.getStatus());
        }
        user.setUpdatedAt(Instant.now());
        return ApiResponse.ok("Updated", mapper.toUserDto(users.save(user)));
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('Admin')")
    @HasPermission("user.manage")
    public ApiResponse<Void> delete(@PathVariable Integer id) {
        users.deleteById(id);
        return ApiResponse.ok("Deleted", null);
    }

    @PostMapping({"/addtokenforuser", "/fcm-token"})
    public ApiResponse<Void> updateFcmToken(@Valid @RequestBody UpdateFcmTokenRequest request) {
        var userId = currentUser.requireUserId();
        var token = fcmTokens.findByToken(request.token()).orElseGet(FcmToken::new);
        var user = new User();
        user.setId(userId);
        token.setUser(user);
        token.setToken(request.token());
        if (token.getCreatedAt() == null) {
            token.setCreatedAt(Instant.now());
        }
        token.setUpdatedAt(Instant.now());
        fcmTokens.save(token);
        return ApiResponse.ok("FCM token updated", null);
    }

    @PostMapping("/me/avatar")
    public ApiResponse<UserDto> updateAvatar(@RequestParam("file") MultipartFile file) {
        if (file == null || file.isEmpty()) {
            throw new IllegalArgumentException("File is required.");
        }
        var user = users.findById(currentUser.requireUserId())
                .orElseThrow(() -> new IllegalArgumentException("User not found"));
        var uploaded = storage.upload(file, "users/" + user.getId() + "/avatar");
        user.setAvatarUrl(uploaded.url());
        user.setUpdatedAt(Instant.now());
        return ApiResponse.ok("Avatar updated", mapper.toUserDto(users.save(user)));
    }

    private void requireSelfOrAdmin(Integer id) {
        if (!id.equals(currentUser.requireUserId()) && !isAdmin()) {
            throw new IllegalArgumentException("User not found");
        }
    }

    private boolean isAdmin() {
        var authentication = SecurityContextHolder.getContext().getAuthentication();
        return authentication != null && authentication.getAuthorities().stream()
                .anyMatch(authority -> "ROLE_Admin".equals(authority.getAuthority()));
    }

    private String clean(String value) {
        if (value == null) {
            return null;
        }
        var cleaned = value.trim();
        return cleaned.isEmpty() ? null : cleaned;
    }
}
