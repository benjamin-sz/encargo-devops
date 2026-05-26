package com.example.BibliotecaTecEduAuth.Controller;

import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/v1/biblioteca/auth/admin")
public class AdminController {

    @GetMapping("/test")
    @PreAuthorize("hasRole('ADMIN')")
    public String admin() {
        return "Conexión exitosa: Tienes privilegios de ADMINISTRADOR";
    }
}