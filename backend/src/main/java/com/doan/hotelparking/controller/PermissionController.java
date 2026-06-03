package com.doan.hotelparking.controller;

import com.doan.hotelparking.common.ApiResponse;
import com.doan.hotelparking.domain.entity.Permission;
import com.doan.hotelparking.dto.common.SimpleDtos.PermissionDto;
import com.doan.hotelparking.repository.PermissionRepository;
import com.doan.hotelparking.security.HasPermission;
import com.doan.hotelparking.service.DtoMapper;
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
    private final DtoMapper mapper;

    public PermissionController(PermissionRepository repository, DtoMapper mapper) {
        super(repository);
        this.permissions = repository;
        this.mapper = mapper;
    }

    @Override
    @GetMapping
    public ApiResponse<List<PermissionDto>> getAll() {
        return ApiResponse.ok(permissions.findAll().stream().map(mapper::toPermissionDto).toList());
    }

    @Override
    @GetMapping("/{id}")
    public ApiResponse<PermissionDto> getById(@PathVariable Integer id) {
        return ApiResponse.ok(permissions.findById(id)
                .map(mapper::toPermissionDto)
                .orElseThrow(() -> new IllegalArgumentException("Permission not found")));
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
    public ApiResponse<List<PermissionDto>> byModule(@PathVariable String module) {
        return ApiResponse.ok(permissions.findByModuleIgnoreCase(module).stream().map(mapper::toPermissionDto).toList());
    }
}
