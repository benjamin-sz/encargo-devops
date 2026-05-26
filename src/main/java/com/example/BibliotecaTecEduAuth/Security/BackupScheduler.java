package com.example.BibliotecaTecEduAuth.Security;

import com.example.BibliotecaTecEduAuth.Service.BackupService;
import org.springframework.context.annotation.Configuration;
import org.springframework.scheduling.annotation.EnableScheduling;
import org.springframework.scheduling.annotation.Scheduled;

@Configuration
@EnableScheduling
public class BackupScheduler {

    private final BackupService backupService;

    public BackupScheduler(BackupService backupService) {
        this.backupService = backupService;
    }

    // Se ejecuta a las 12:00 AM todos los días (formato cron)
    @Scheduled(cron = "0 0 0 * * ?")
    public void scheduleBackup() {
        backupService.createBackup();
    }
}