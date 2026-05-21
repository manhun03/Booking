package com.doan.hotelparking.service;

import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;

@Service
public class CurrentUserService {
    public Integer requireUserId() {
        var authentication = SecurityContextHolder.getContext().getAuthentication();
        if (authentication == null || !(authentication.getPrincipal() instanceof JwtService.JwtPrincipal principal)) {
            throw new IllegalArgumentException("Unable to resolve current user from token");
        }
        return principal.userId();
    }
}
