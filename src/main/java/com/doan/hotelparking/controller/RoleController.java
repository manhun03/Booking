package com.doan.hotelparking.controller;

import com.doan.hotelparking.domain.entity.Role;
import com.doan.hotelparking.repository.RoleRepository;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/roles")
public class RoleController extends CrudController<Role> {
    public RoleController(RoleRepository repository) {
        super(repository);
    }
}
