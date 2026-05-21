package com.doan.hotelparking.controller;

import com.doan.hotelparking.common.ApiResponse;
import com.doan.hotelparking.domain.entity.Permission;
import com.doan.hotelparking.repository.PermissionRepository;
import com.doan.hotelparking.security.HasPermission;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/permissions")
@PreAuthorize("isAuthenticated()")
public class PermissionController extends CrudController<Permission> {
    private final PermissionRepository permissions;

    public PermissionController(PermissionRepository repository) {
        super(repository);
        this.permissions = repository;
    }

    @GetMapping("/modules")
    @HasPermission("permission.read")
    public ApiResponse<List<String>> modules() {
        return ApiResponse.ok(permissions.findAll().stream()
                .map(Permission::getModule)
                .filter(module -> module != null && !module.isBlank())
                .distinct()
                .toList());
    }

    @GetMapping("/modules/{module}")
    @HasPermission("permission.read")
    public ApiResponse<List<Permission>> byModule(@PathVariable String module) {
        return ApiResponse.ok(permissions.findByModuleIgnoreCase(module));
    }
}
