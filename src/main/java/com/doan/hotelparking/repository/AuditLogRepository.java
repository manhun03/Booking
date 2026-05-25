package com.doan.hotelparking.repository;

import com.doan.hotelparking.domain.entity.AuditLog;
import org.springframework.data.jpa.repository.JpaRepository;

public interface AuditLogRepository extends JpaRepository<AuditLog, Integer> {
}
