package com.example.BibliotecaTecEduAuth.Service;

import org.springframework.stereotype.Service;
import java.io.File;

@Service
public class BackupService {

    public void createBackup() {
        // 1. Configura las rutas (Ajusta 'mysql-8.0.30-winx64' a tu versión real en Laragon)
        String dumpPath = "C:/laragon/bin/mysql/mysql-8.0.30-winx64/bin/mysqldump";
        String dbName = "db_bibliotecateceduauth";
        String dbUser = "root";
        String dbPass = "";


        String saveDir = "C:/backups";
        new File(saveDir).mkdirs();
        String savePath = saveDir + "/backup_auth_service.sql";


        String command = String.format("%s -u %s %s --databases %s -r %s",
                dumpPath, dbUser, dbPass.isEmpty() ? "" : "-p" + dbPass, dbName, savePath);

        try {
            Process process = Runtime.getRuntime().exec(command);
            int processComplete = process.waitFor();
            if (processComplete == 0) {
                System.out.println("Backup creado con éxito en: " + savePath);
            } else {
                System.err.println("Fallo al crear el backup. Revisa las rutas.");
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}