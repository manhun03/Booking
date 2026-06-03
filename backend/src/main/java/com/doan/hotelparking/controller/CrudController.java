package com.doan.hotelparking.controller;

import com.doan.hotelparking.common.ApiResponse;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.web.bind.annotation.*;

import java.util.List;

public abstract class CrudController<T> {
    private final JpaRepository<T, Integer> repository;

    protected CrudController(JpaRepository<T, Integer> repository) {
        this.repository = repository;
    }

    @GetMapping
    public ApiResponse<?> getAll() {
        return ApiResponse.ok(repository.findAll());
    }

    @GetMapping("/{id}")
    public ApiResponse<?> getById(@PathVariable Integer id) {
        return ApiResponse.ok(repository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Resource not found")));
    }

    @PostMapping
    public ApiResponse<T> create(@RequestBody T entity) {
        return ApiResponse.ok("Created", repository.save(entity));
    }

    @PutMapping("/{id}")
    public ApiResponse<T> update(@PathVariable Integer id, @RequestBody T entity) {
        if (!repository.existsById(id)) {
            throw new IllegalArgumentException("Resource not found");
        }
        return ApiResponse.ok("Updated", repository.save(entity));
    }

    @DeleteMapping("/{id}")
    public ApiResponse<Void> delete(@PathVariable Integer id) {
        repository.deleteById(id);
        return ApiResponse.ok("Deleted", null);
    }
}
