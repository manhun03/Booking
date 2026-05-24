package com.doan.hotelparking.controller;

import com.doan.hotelparking.common.ApiResponse;
import com.doan.hotelparking.domain.entity.Notification;
import com.doan.hotelparking.domain.entity.OwnerSetting;
import com.doan.hotelparking.domain.entity.SystemConfig;
import com.doan.hotelparking.domain.entity.User;
import com.doan.hotelparking.dto.ownersetting.UpdateBankInfoRequest;
import com.doan.hotelparking.dto.ownersetting.OwnerSettingDto;
import com.doan.hotelparking.repository.NotificationRepository;
import com.doan.hotelparking.repository.OwnerSettingRepository;
import com.doan.hotelparking.repository.SystemConfigRepository;
import com.doan.hotelparking.security.HasPermission;
import com.doan.hotelparking.service.CurrentUserService;
import com.doan.hotelparking.service.DtoMapper;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.time.Instant;

final class MiscControllers {
    private MiscControllers() {
    }
}

@RestController
@RequestMapping("/api/notifications")
class NotificationController extends CrudController<Notification> {
    NotificationController(NotificationRepository repository) {
        super(repository);
    }
}

@RestController
@RequestMapping("/api/owner/settings")
@PreAuthorize("hasRole('Owner')")
class OwnerSettingController {
    private final OwnerSettingRepository ownerSettings;
    private final CurrentUserService currentUser;
    private final DtoMapper mapper;

    OwnerSettingController(OwnerSettingRepository repository, CurrentUserService currentUser, DtoMapper mapper) {
        this.ownerSettings = repository;
        this.currentUser = currentUser;
        this.mapper = mapper;
    }

    @GetMapping
    @HasPermission("ownersetting.read")
    ApiResponse<OwnerSettingDto> me() {
        return ApiResponse.ok(mapper.toOwnerSettingDto(ownerSettings.findByOwnerId(currentUser.requireUserId()).orElseGet(() -> createDefault(currentUser.requireUserId()))));
    }

    @PutMapping
    @HasPermission("ownersetting.manage")
    ApiResponse<OwnerSettingDto> update(@RequestBody OwnerSetting request) {
        var setting = ownerSettings.findByOwnerId(currentUser.requireUserId()).orElseGet(() -> createDefault(currentUser.requireUserId()));
        setting.setDepositRate(request.getDepositRate());
        setting.setMinBookingNotice(request.getMinBookingNotice());
        setting.setAllowReview(request.isAllowReview());
        setting.setUpdatedAt(Instant.now());
        return ApiResponse.ok("Updated", mapper.toOwnerSettingDto(ownerSettings.save(setting)));
    }

    @RequestMapping(value = "/bank-info", method = {RequestMethod.PUT, RequestMethod.POST})
    @HasPermission("ownersetting.manage")
    ApiResponse<OwnerSettingDto> updateBankInfo(@RequestBody UpdateBankInfoRequest request) {
        var setting = ownerSettings.findByOwnerId(currentUser.requireUserId()).orElseGet(() -> createDefault(currentUser.requireUserId()));
        setting.setBankName(request.bankName());
        setting.setBankAccountNumber(request.bankAccountNumber());
        setting.setBankAccountName(request.bankAccountName());
        setting.setBankQrCodeUrl(request.bankQrCodeUrl());
        setting.setUpdatedAt(Instant.now());
        return ApiResponse.ok("Bank info updated", mapper.toOwnerSettingDto(ownerSettings.save(setting)));
    }

    @GetMapping("/bank-info/validate")
    @HasPermission("ownersetting.read")
    ApiResponse<Boolean> validateBankInfo() {
        var setting = ownerSettings.findByOwnerId(currentUser.requireUserId()).orElse(null);
        var valid = setting != null
                && setting.getBankName() != null && !setting.getBankName().isBlank()
                && setting.getBankAccountNumber() != null && !setting.getBankAccountNumber().isBlank()
                && setting.getBankAccountName() != null && !setting.getBankAccountName().isBlank();
        return ApiResponse.ok(valid);
    }

    private OwnerSetting createDefault(Integer ownerId) {
        var owner = new User();
        owner.setId(ownerId);
        var setting = new OwnerSetting();
        setting.setOwner(owner);
        setting.setAllowReview(true);
        setting.setCreatedAt(Instant.now());
        setting.setUpdatedAt(Instant.now());
        return ownerSettings.save(setting);
    }
}

@RestController
@RequestMapping("/api/admin/system-configs")
@PreAuthorize("hasRole('Admin')")
@HasPermission("system.manage")
class SystemConfigController {
    private final SystemConfigRepository configs;

    SystemConfigController(SystemConfigRepository repository) {
        this.configs = repository;
    }

    @GetMapping
    ApiResponse<java.util.List<SystemConfig>> getAll() {
        return ApiResponse.ok(configs.findAll());
    }

    @GetMapping("/{key}")
    ApiResponse<SystemConfig> byKey(@PathVariable String key) {
        return ApiResponse.ok(configs.findByConfigKey(key)
                .orElseThrow(() -> new IllegalArgumentException("System config not found")));
    }

    @PutMapping("/{key}")
    ApiResponse<SystemConfig> updateByKey(@PathVariable String key, @RequestBody SystemConfig request) {
        var config = configs.findByConfigKey(key).orElseGet(() -> {
            var created = new SystemConfig();
            created.setConfigKey(key);
            return created;
        });
        config.setConfigValue(request.getConfigValue());
        config.setDataType(request.getDataType());
        config.setDescription(request.getDescription());
        config.setUpdatedAt(Instant.now());
        return ApiResponse.ok("Updated", configs.save(config));
    }
}
