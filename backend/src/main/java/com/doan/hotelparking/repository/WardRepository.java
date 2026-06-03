package com.doan.hotelparking.repository;

import com.doan.hotelparking.domain.entity.Ward;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface WardRepository extends JpaRepository<Ward, Integer> {
    List<Ward> findByProvinceId(Integer provinceId);
}
