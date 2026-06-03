package com.doan.hotelparking.controller;

import com.doan.hotelparking.common.ApiResponse;
import com.doan.hotelparking.domain.entity.Role;
import com.doan.hotelparking.dto.common.SimpleDtos.RoleDto;
import com.doan.hotelparking.repository.RoleRepository;
import com.doan.hotelparking.security.HasPermission;
import com.doan.hotelparking.service.DtoMapper;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/roles")
@PreAuthorize("hasRole('Admin')")
@HasPermission("role.manage")
public class RoleController extends CrudController<Role> {
    private final RoleRepository roles;
    private final DtoMapper mapper;

    public RoleController(RoleRepository repository, DtoMapper mapper) {
        super(repository);
        this.roles = repository;
        this.mapper = mapper;
    }

    @Override
    @GetMapping
    public ApiResponse<List<RoleDto>> getAll() {
        return ApiResponse.ok(roles.findAll().stream().map(mapper::toRoleDto).toList());
    }

    @Override
    @GetMapping("/{id}")
    public ApiResponse<RoleDto> getById(@PathVariable Integer id) {
        return ApiResponse.ok(roles.findById(id)
                .map(mapper::toRoleDto)
                .orElseThrow(() -> new IllegalArgumentException("Role not found")));
    }
}
