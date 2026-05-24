package com.doan.hotelparking.controller;

import com.doan.hotelparking.common.ApiResponse;
import com.doan.hotelparking.common.ApiPagedResponse;
import com.doan.hotelparking.domain.entity.FavoriteHotel;
import com.doan.hotelparking.domain.entity.Hotel;
import com.doan.hotelparking.domain.entity.HotelImage;
import com.doan.hotelparking.domain.entity.User;
import com.doan.hotelparking.dto.hotel.HotelDto;
import com.doan.hotelparking.dto.hotel.FavoriteHotelDto;
import com.doan.hotelparking.dto.hotel.HotelImageDto;
import com.doan.hotelparking.repository.FavoriteHotelRepository;
import com.doan.hotelparking.repository.HotelImageRepository;
import com.doan.hotelparking.repository.HotelRepository;
import com.doan.hotelparking.security.HasPermission;
import com.doan.hotelparking.service.CurrentUserService;
import com.doan.hotelparking.service.DtoMapper;
import com.doan.hotelparking.service.ObjectStorageService;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.data.domain.PageRequest;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.util.List;

final class HotelControllers {
    private HotelControllers() {
    }
}

@RestController
@RequestMapping("/api/hotels")
class HotelController {
    private final HotelRepository hotels;
    private final DtoMapper mapper;
    private final CurrentUserService currentUser;

    HotelController(HotelRepository repository, DtoMapper mapper, CurrentUserService currentUser) {
        this.hotels = repository;
        this.mapper = mapper;
        this.currentUser = currentUser;
    }

    @GetMapping
    @Transactional(readOnly = true)
    ApiPagedResponse<HotelDto> getAll(@RequestParam(defaultValue = "1") int pageIndex,
                                      @RequestParam(defaultValue = "20") int pageSize) {
        var page = hotels.findAll(PageRequest.of(Math.max(pageIndex, 1) - 1, Math.min(Math.max(pageSize, 1), 100)));
        return ApiPagedResponse.ok(page.getContent().stream().map(mapper::toHotelDto).toList(),
                pageIndex, pageSize, page.getTotalElements());
    }

    @GetMapping("/{id}")
    @Transactional(readOnly = true)
    ApiResponse<HotelDto> getById(@PathVariable Integer id) {
        return ApiResponse.ok(hotels.findById(id).map(mapper::toHotelDto)
                .orElseThrow(() -> new IllegalArgumentException("Hotel not found")));
    }

    @PostMapping
    @PreAuthorize("hasRole('Admin')")
    @HasPermission("hotel.manage")
    ApiResponse<HotelDto> create(@RequestBody Hotel hotel) {
        return ApiResponse.ok("Created", mapper.toHotelDto(hotels.save(hotel)));
    }

    @PostMapping("/owner")
    @PreAuthorize("hasRole('Owner')")
    ApiResponse<HotelDto> createOwnerHotel(@RequestBody Hotel hotel) {
        var owner = new User();
        owner.setId(currentUser.requireUserId());
        hotel.setOwner(owner);
        return ApiResponse.ok("Created", mapper.toHotelDto(hotels.save(hotel)));
    }

    @PutMapping("/{id}")
    @PreAuthorize("hasRole('Admin')")
    @HasPermission("hotel.manage")
    ApiResponse<HotelDto> update(@PathVariable Integer id, @RequestBody Hotel request) {
        var hotel = hotels.findById(id).orElseThrow(() -> new IllegalArgumentException("Hotel not found"));
        hotel.setName(request.getName());
        hotel.setStreet(request.getStreet());
        hotel.setPhone(request.getPhone());
        hotel.setDescription(request.getDescription());
        hotel.setUpdatedAt(Instant.now());
        return ApiResponse.ok("Updated", mapper.toHotelDto(hotels.save(hotel)));
    }

    @PutMapping("/owner/{id}")
    @PreAuthorize("hasRole('Owner')")
    ApiResponse<HotelDto> updateOwnerHotel(@PathVariable Integer id, @RequestBody Hotel request) {
        var hotel = hotels.findById(id).orElseThrow(() -> new IllegalArgumentException("Hotel not found"));
        if (hotel.getOwner() == null || !hotel.getOwner().getId().equals(currentUser.requireUserId())) {
            throw new IllegalArgumentException("Hotel not found");
        }
        hotel.setName(request.getName());
        hotel.setStreet(request.getStreet());
        hotel.setPhone(request.getPhone());
        hotel.setDescription(request.getDescription());
        hotel.setStatus(request.getStatus());
        hotel.setUpdatedAt(Instant.now());
        return ApiResponse.ok("Updated", mapper.toHotelDto(hotels.save(hotel)));
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('Admin')")
    @HasPermission("hotel.manage")
    ApiResponse<Void> delete(@PathVariable Integer id) {
        hotels.deleteById(id);
        return ApiResponse.ok("Deleted", null);
    }

    @GetMapping("/all-with-province")
    @Transactional(readOnly = true)
    ApiPagedResponse<HotelDto> allWithProvince(@RequestParam(defaultValue = "1") int pageIndex,
                                               @RequestParam(defaultValue = "20") int pageSize) {
        var page = hotels.findAll(PageRequest.of(Math.max(pageIndex, 1) - 1, Math.min(Math.max(pageSize, 1), 100)));
        return ApiPagedResponse.ok(page.getContent().stream().map(mapper::toHotelDto).toList(),
                pageIndex, pageSize, page.getTotalElements());
    }

    @GetMapping("/{id}/with-location")
    ApiResponse<HotelDto> withLocation(@PathVariable Integer id) {
        return ApiResponse.ok(hotels.findDetailedById(id).map(mapper::toHotelDto)
                .orElseThrow(() -> new IllegalArgumentException("Hotel not found")));
    }

    @GetMapping("/search")
    @Transactional(readOnly = true)
    ApiResponse<List<HotelDto>> search(@RequestParam(required = false) String hotelName,
                                       @RequestParam(required = false) String keyword) {
        var resolved = hotelName == null || hotelName.isBlank() ? keyword : hotelName;
        if (resolved == null || resolved.isBlank()) {
            throw new IllegalArgumentException("hotelName is required.");
        }
        return ApiResponse.ok(hotels.findByNameContainingIgnoreCase(resolved).stream().map(mapper::toHotelDto).toList());
    }

    @GetMapping("/by-province")
    ApiResponse<List<HotelDto>> byProvince(@RequestParam String province) {
        return ApiResponse.ok(hotels.findByWardProvinceNameContainingIgnoreCase(province).stream().map(mapper::toHotelDto).toList());
    }
}

@RestController
@RequestMapping("/api/hotels/{hotelId}/images")
class HotelImageController {
    private final HotelImageRepository images;
    private final HotelRepository hotels;
    private final ObjectStorageService storage;
    private final DtoMapper mapper;
    private final CurrentUserService currentUser;

    HotelImageController(HotelImageRepository repository, HotelRepository hotels, ObjectStorageService storage, DtoMapper mapper, CurrentUserService currentUser) {
        this.images = repository;
        this.hotels = hotels;
        this.storage = storage;
        this.mapper = mapper;
        this.currentUser = currentUser;
    }

    @PutMapping("/{id}")
    @PreAuthorize("hasAnyRole('Admin','Owner')")
    ApiResponse<HotelImageDto> update(@PathVariable Integer hotelId, @PathVariable Integer id, @RequestBody HotelImage request) {
        requireOwnedHotel(hotelId);
        var image = images.findById(id).orElseThrow(() -> new IllegalArgumentException("Hotel image not found"));
        if (image.getHotel() == null || !hotelId.equals(image.getHotel().getId())) {
            throw new IllegalArgumentException("Hotel image not found");
        }
        image.setImageUrl(request.getImageUrl());
        image.setObjectKey(request.getObjectKey());
        image.setPrimaryImage(request.isPrimaryImage());
        image.setSortOrder(request.getSortOrder());
        return ApiResponse.ok("Updated", mapper.toHotelImageDto(images.save(image)));
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasAnyRole('Admin','Owner')")
    ApiResponse<Void> delete(@PathVariable Integer hotelId, @PathVariable Integer id) {
        requireOwnedHotel(hotelId);
        var image = images.findById(id).orElseThrow(() -> new IllegalArgumentException("Hotel image not found"));
        if (image.getHotel() == null || !hotelId.equals(image.getHotel().getId())) {
            throw new IllegalArgumentException("Hotel image not found");
        }
        if (image.getObjectKey() != null && !image.getObjectKey().isBlank()) {
            storage.delete(image.getObjectKey());
        }
        images.delete(image);
        return ApiResponse.ok("Deleted", null);
    }

    @GetMapping
    public ApiResponse<List<HotelImageDto>> getImages(@PathVariable Integer hotelId) {
        return ApiResponse.ok(images.findByHotelIdOrderByPrimaryImageDescSortOrderAsc(hotelId).stream()
                .map(mapper::toHotelImageDto)
                .toList());
    }

    @GetMapping("/ordered")
    ApiResponse<List<HotelImageDto>> ordered(@PathVariable Integer hotelId) {
        return ApiResponse.ok(images.findByHotelIdOrderByPrimaryImageDescSortOrderAsc(hotelId).stream()
                .map(mapper::toHotelImageDto)
                .toList());
    }

    @PostMapping("/upload")
    @PreAuthorize("hasAnyRole('Admin','Owner')")
    ApiResponse<HotelImageDto> upload(@PathVariable Integer hotelId,
                                   @RequestParam("file") MultipartFile file,
                                   @RequestParam(defaultValue = "false") boolean primaryImage,
                                   @RequestParam(defaultValue = "0") int sortOrder) {
        requireOwnedHotel(hotelId);
        var uploaded = storage.upload(file, "hotels/" + hotelId);
        var hotel = new Hotel();
        hotel.setId(hotelId);
        var image = new HotelImage();
        image.setHotel(hotel);
        image.setObjectKey(uploaded.objectKey());
        image.setImageUrl(uploaded.url());
        image.setPrimaryImage(primaryImage);
        image.setSortOrder(sortOrder);
        image.setCreatedAt(Instant.now());
        return ApiResponse.ok("Uploaded", mapper.toHotelImageDto(images.save(image)));
    }

    private void requireOwnedHotel(Integer hotelId) {
        var hotel = hotels.findById(hotelId).orElseThrow(() -> new IllegalArgumentException("Hotel not found"));
        if (!isAdmin() && (hotel.getOwner() == null || !hotel.getOwner().getId().equals(currentUser.requireUserId()))) {
            throw new IllegalArgumentException("Hotel not found");
        }
    }

    private boolean isAdmin() {
        var authentication = SecurityContextHolder.getContext().getAuthentication();
        return authentication != null && authentication.getAuthorities().stream()
                .anyMatch(authority -> "ROLE_Admin".equals(authority.getAuthority()));
    }
}

@RestController
@RequestMapping("/api/favorites")
class FavoriteHotelController {
    private final FavoriteHotelRepository favorites;
    private final CurrentUserService currentUser;
    private final DtoMapper mapper;

    FavoriteHotelController(FavoriteHotelRepository repository, CurrentUserService currentUser, DtoMapper mapper) {
        this.favorites = repository;
        this.currentUser = currentUser;
        this.mapper = mapper;
    }

    @GetMapping
    ApiResponse<List<FavoriteHotelDto>> getAll() {
        return ApiResponse.ok(favorites.findAll().stream().map(mapper::toFavoriteHotelDto).toList());
    }

    @GetMapping("/{hotelId}/is-favorite")
    ApiResponse<Boolean> isFavorite(@PathVariable Integer hotelId) {
        return ApiResponse.ok(favorites.existsByUserIdAndHotelId(currentUser.requireUserId(), hotelId));
    }

    @GetMapping("/my-favorites")
    ApiResponse<List<FavoriteHotelDto>> myFavorites() {
        return ApiResponse.ok(favorites.findByUserId(currentUser.requireUserId()).stream()
                .map(mapper::toFavoriteHotelDto)
                .toList());
    }

    @PostMapping("/{hotelId}/toggle")
    ApiResponse<Boolean> toggle(@PathVariable Integer hotelId) {
        var userId = currentUser.requireUserId();
        var existing = favorites.findByUserIdAndHotelId(userId, hotelId);
        if (existing.isPresent()) {
            favorites.delete(existing.get());
            return ApiResponse.ok("Removed from favorites", false);
        }
        var favorite = new FavoriteHotel();
        var user = new User();
        user.setId(userId);
        var hotel = new Hotel();
        hotel.setId(hotelId);
        favorite.setUser(user);
        favorite.setHotel(hotel);
        favorite.setCreatedAt(Instant.now());
        favorites.save(favorite);
        return ApiResponse.ok("Added to favorites", true);
    }
}
