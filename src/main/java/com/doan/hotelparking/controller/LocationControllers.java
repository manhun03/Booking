package com.doan.hotelparking.controller;

import com.doan.hotelparking.common.ApiResponse;
import com.doan.hotelparking.domain.entity.Province;
import com.doan.hotelparking.domain.entity.Ward;
import com.doan.hotelparking.dto.location.ProvinceDto;
import com.doan.hotelparking.dto.location.WardDto;
import com.doan.hotelparking.repository.ProvinceRepository;
import com.doan.hotelparking.repository.WardRepository;
import com.doan.hotelparking.security.HasPermission;
import com.doan.hotelparking.service.DtoMapper;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

final class LocationControllers {
    private LocationControllers() {
    }
}

@RestController
@RequestMapping("/api/provinces")
class ProvinceController {
    private final ProvinceRepository provinces;
    private final DtoMapper mapper;

    ProvinceController(ProvinceRepository repository, DtoMapper mapper) {
        this.provinces = repository;
        this.mapper = mapper;
    }

    @GetMapping
    ApiResponse<List<ProvinceDto>> getAll() {
        return ApiResponse.ok(provinces.findAll().stream().map(mapper::toProvinceDto).toList());
    }

    @GetMapping("/{id}")
    ApiResponse<ProvinceDto> getById(@PathVariable Integer id) {
        return ApiResponse.ok(provinces.findById(id).map(mapper::toProvinceDto)
                .orElseThrow(() -> new IllegalArgumentException("Province not found")));
    }

    @PostMapping
    @PreAuthorize("hasRole('Admin')")
    @HasPermission("location.manage")
    ApiResponse<ProvinceDto> create(@RequestBody Province province) {
        return ApiResponse.ok("Created", mapper.toProvinceDto(provinces.save(province)));
    }

    @PutMapping("/{id}")
    @PreAuthorize("hasRole('Admin')")
    @HasPermission("location.manage")
    ApiResponse<ProvinceDto> update(@PathVariable Integer id, @RequestBody Province request) {
        var province = provinces.findById(id).orElseThrow(() -> new IllegalArgumentException("Province not found"));
        province.setName(request.getName());
        province.setCode(request.getCode());
        province.setActive(request.isActive());
        return ApiResponse.ok("Updated", mapper.toProvinceDto(provinces.save(province)));
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('Admin')")
    @HasPermission("location.manage")
    ApiResponse<Void> delete(@PathVariable Integer id) {
        provinces.deleteById(id);
        return ApiResponse.ok("Deleted", null);
    }
}

@RestController
@RequestMapping("/api/wards")
class WardController {
    private final WardRepository wards;
    private final DtoMapper mapper;

    WardController(WardRepository repository, DtoMapper mapper) {
        this.wards = repository;
        this.mapper = mapper;
    }

    @GetMapping
    ApiResponse<List<WardDto>> getAll(@RequestParam(required = false) Integer provinceId) {
        var items = provinceId == null ? wards.findAll() : wards.findByProvinceId(provinceId);
        return ApiResponse.ok(items.stream().map(mapper::toWardDto).toList());
    }

    @GetMapping("/{id}")
    ApiResponse<WardDto> getById(@PathVariable Integer id) {
        return ApiResponse.ok(wards.findById(id).map(mapper::toWardDto)
                .orElseThrow(() -> new IllegalArgumentException("Ward not found")));
    }

    @PostMapping
    @PreAuthorize("hasRole('Admin')")
    @HasPermission("location.manage")
    ApiResponse<WardDto> create(@RequestBody Ward ward) {
        return ApiResponse.ok("Created", mapper.toWardDto(wards.save(ward)));
    }

    @PutMapping("/{id}")
    @PreAuthorize("hasRole('Admin')")
    @HasPermission("location.manage")
    ApiResponse<WardDto> update(@PathVariable Integer id, @RequestBody Ward request) {
        var ward = wards.findById(id).orElseThrow(() -> new IllegalArgumentException("Ward not found"));
        ward.setName(request.getName());
        ward.setCode(request.getCode());
        ward.setActive(request.isActive());
        if (request.getProvince() != null) {
            ward.setProvince(request.getProvince());
        }
        return ApiResponse.ok("Updated", mapper.toWardDto(wards.save(ward)));
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('Admin')")
    @HasPermission("location.manage")
    ApiResponse<Void> delete(@PathVariable Integer id) {
        wards.deleteById(id);
        return ApiResponse.ok("Deleted", null);
    }
}
