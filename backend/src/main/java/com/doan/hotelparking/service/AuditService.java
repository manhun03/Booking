package com.doan.hotelparking.service;

import com.doan.hotelparking.domain.entity.AuditLog;
import com.doan.hotelparking.repository.AuditLogRepository;
import org.springframework.stereotype.Service;

@Service
public class AuditService {
    private final AuditLogRepository logs;

    public AuditService(AuditLogRepository logs) {
        this.logs = logs;
    }

    public void record(Integer actorId, String action, String targetTable, Integer targetId, String detail) {
        var log = new AuditLog();
        log.setActorId(actorId);
        log.setAction(action);
        log.setTargetTable(targetTable);
        log.setTargetId(targetId);
        log.setDetail(detail);
        logs.save(log);
    }
}
