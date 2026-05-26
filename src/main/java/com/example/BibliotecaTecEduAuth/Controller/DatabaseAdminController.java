package com.example.BibliotecaTecEduAuth.Controller;

import org.flywaydb.core.Flyway;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/biblioteca/admin/db")
public class DatabaseAdminController {

    private final Flyway flyway;

    public DatabaseAdminController(Flyway flyway) {
        this.flyway = flyway;
    }

    @PostMapping("/repair")
    public String repairDatabase() {

        flyway.repair();
        return "Historial reparado. Ya puedes corregir tu script SQL y reiniciar el servidor.";
    }
}