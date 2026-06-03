package com.doan.hotelparking.security;

import com.doan.hotelparking.repository.PermissionRepository;
import com.doan.hotelparking.service.JwtService;
import org.aspectj.lang.annotation.Aspect;
import org.aspectj.lang.annotation.Before;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Component;

@Aspect
@Component
public class PermissionAspect {
    private final PermissionRepository permissions;

    public PermissionAspect(PermissionRepository permissions) {
        this.permissions = permissions;
    }

    @Before("@annotation(hasPermission)")
    public void checkPermission(HasPermission hasPermission) {
        check(hasPermission.value());
    }

    @Before("@within(hasPermission)")
    public void checkClassPermission(HasPermission hasPermission) {
        check(hasPermission.value());
    }

    private void check(String permissionKey) {
        var authentication = SecurityContextHolder.getContext().getAuthentication();
        if (authentication == null || !(authentication.getPrincipal() instanceof JwtService.JwtPrincipal principal)) {
            throw new AccessDeniedException("Unauthorized");
        }
        if (principal.roles().stream().anyMatch(role -> "Admin".equalsIgnoreCase(role))) {
            return;
        }
        if (!permissions.userHasPermission(principal.userId(), permissionKey)) {
            throw new AccessDeniedException("Forbidden. Missing permission '" + permissionKey + "'.");
        }
    }
}
