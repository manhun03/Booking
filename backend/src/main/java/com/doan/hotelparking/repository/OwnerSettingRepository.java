package com.doan.hotelparking.repository;

import com.doan.hotelparking.domain.entity.OwnerSetting;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface OwnerSettingRepository extends JpaRepository<OwnerSetting, Integer> {
    Optional<OwnerSetting> findByOwnerId(Integer ownerId);
}
