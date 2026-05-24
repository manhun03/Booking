package com.doan.hotelparking.service;

import com.doan.hotelparking.domain.entity.*;
import com.doan.hotelparking.repository.*;
import org.springframework.boot.CommandLineRunner;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.util.Map;

@Component
public class DataSeeder implements CommandLineRunner {
    private final RoleRepository roles;
    private final PermissionRepository permissions;
    private final RolePermissionRepository rolePermissions;
    private final RoomTypeRepository roomTypes;

    public DataSeeder(RoleRepository roles,
                      PermissionRepository permissions,
                      RolePermissionRepository rolePermissions,
                      RoomTypeRepository roomTypes) {
        this.roles = roles;
        this.permissions = permissions;
        this.rolePermissions = rolePermissions;
        this.roomTypes = roomTypes;
    }

    @Override
    @Transactional
    public void run(String... args) {
        seedRoles();
        seedPermissions();
        seedRolePermissions();
        seedRoomTypes();
    }

    private void seedRoles() {
        saveRole("Admin", "System administrator");
        saveRole("Owner", "Hotel owner");
        saveRole("Customer", "Hotel customer");
    }

    private void saveRole(String name, String description) {
        if (roles.findByName(name).isPresent()) {
            return;
        }
        var role = new Role();
        role.setName(name);
        role.setDescription(description);
        role.setActive(true);
        role.setCreatedAt(Instant.parse("2026-01-01T00:00:00Z"));
        role.setUpdatedAt(role.getCreatedAt());
        roles.save(role);
    }

    private void seedPermissions() {
        var values = Map.ofEntries(
                Map.entry(1, new String[]{"user.read", "Read users", "User"}),
                Map.entry(2, new String[]{"user.manage", "Manage users", "User"}),
                Map.entry(3, new String[]{"hotel.read", "Read hotels", "Hotel"}),
                Map.entry(4, new String[]{"hotel.manage", "Manage hotels", "Hotel"}),
                Map.entry(5, new String[]{"room.read", "Read rooms", "Room"}),
                Map.entry(6, new String[]{"room.manage", "Manage rooms", "Room"}),
                Map.entry(7, new String[]{"booking.read", "Read bookings", "Booking"}),
                Map.entry(8, new String[]{"booking.manage", "Manage bookings", "Booking"}),
                Map.entry(9, new String[]{"payment.read", "Read payments", "Payment"}),
                Map.entry(10, new String[]{"payment.manage", "Manage payments", "Payment"}),
                Map.entry(11, new String[]{"review.read", "Read reviews", "Review"}),
                Map.entry(12, new String[]{"review.manage", "Manage reviews", "Review"}),
                Map.entry(13, new String[]{"notification.read", "Read notifications", "Notification"}),
                Map.entry(14, new String[]{"location.read", "Read locations", "Location"}),
                Map.entry(15, new String[]{"location.manage", "Manage locations", "Location"}),
                Map.entry(16, new String[]{"timeslot.read", "Read time slots", "TimeSlot"}),
                Map.entry(17, new String[]{"timeslot.manage", "Manage time slots", "TimeSlot"}),
                Map.entry(18, new String[]{"hotelimage.read", "Read hotel images", "HotelImage"}),
                Map.entry(19, new String[]{"hotelimage.manage", "Manage hotel images", "HotelImage"}),
                Map.entry(20, new String[]{"notification.manage", "Manage notifications", "Notification"}),
                Map.entry(21, new String[]{"permission.read", "Read permissions", "Permission"}),
                Map.entry(22, new String[]{"permission.manage", "Manage permissions", "Permission"}),
                Map.entry(23, new String[]{"ownersetting.read", "Read owner settings", "OwnerSetting"}),
                Map.entry(24, new String[]{"ownersetting.manage", "Manage owner settings", "OwnerSetting"}),
                Map.entry(25, new String[]{"system.manage", "Manage system configuration", "SystemConfig"}),
                Map.entry(26, new String[]{"statistics.read", "Read owner statistics", "Statistics"}),
                Map.entry(27, new String[]{"recommendation.read", "Read recommendations", "Recommendation"}),
                Map.entry(28, new String[]{"favorite.manage", "Manage favorite hotels", "Favorite"}),
                Map.entry(29, new String[]{"booking.force_complete", "Force complete booking", "Booking"}));
        values.forEach((ignoredId, data) -> {
            if (permissions.findByPermissionKeyIgnoreCase(data[0]).isEmpty()) {
                var permission = new Permission();
                permission.setPermissionKey(data[0]);
                permission.setDescription(data[1]);
                permission.setModule(data[2]);
                permission.setCreatedAt(Instant.parse("2026-01-01T00:00:00Z"));
                permission.setUpdatedAt(permission.getCreatedAt());
                permissions.save(permission);
            }
        });
    }

    private void seedRolePermissions() {
        var admin = roles.findByName("Admin").orElseThrow();
        var owner = roles.findByName("Owner").orElseThrow();
        var customer = roles.findByName("Customer").orElseThrow();
        var allPermissions = permissions.findAll();
        allPermissions.forEach(permission -> saveRolePermission(admin, permission));
        allPermissions.stream()
                .filter(permission -> !"booking.force_complete".equalsIgnoreCase(permission.getPermissionKey()))
                .forEach(permission -> saveRolePermission(owner, permission));
        var customerKeys = java.util.Set.of(
                "hotel.read", "room.read", "booking.read", "booking.manage", "payment.read", "payment.manage",
                "review.read", "review.manage", "notification.read", "location.read", "recommendation.read", "favorite.manage");
        allPermissions.stream()
                .filter(permission -> customerKeys.contains(permission.getPermissionKey().toLowerCase()))
                .forEach(permission -> saveRolePermission(customer, permission));
    }

    private void saveRolePermission(Role role, Permission permission) {
        var roleId = role.getId();
        var permissionId = permission.getId();
        if (roleId == null || permissionId == null) {
            return;
        }
        var id = new RolePermissionId(roleId, permissionId);
        if (rolePermissions.existsById(id)) {
            return;
        }
        var rolePermission = new RolePermission();
        rolePermission.setId(id);
        rolePermission.setRole(role);
        rolePermission.setPermission(permission);
        rolePermission.setCreatedAt(Instant.parse("2026-01-01T00:00:00Z"));
        rolePermissions.save(rolePermission);
    }

    private void seedRoomTypes() {
        saveRoomType("Standard", "Standard room");
        saveRoomType("Deluxe", "Deluxe room");
    }

    private void saveRoomType(String name, String description) {
        if (roomTypes.findByNameIgnoreCase(name).isPresent()) {
            return;
        }
        var roomType = new RoomType();
        roomType.setName(name);
        roomType.setDescription(description);
        roomTypes.save(roomType);
    }
}
