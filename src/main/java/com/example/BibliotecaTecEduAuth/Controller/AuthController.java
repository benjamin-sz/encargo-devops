package com.example.BibliotecaTecEduAuth.Controller;

import com.example.BibliotecaTecEduAuth.Model.User;
import com.example.BibliotecaTecEduAuth.Security.JwtService;
import com.example.BibliotecaTecEduAuth.Service.UserService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.*;
import com.example.BibliotecaTecEduAuth.dto.AuthResponse;
import com.example.BibliotecaTecEduAuth.dto.LoginRequest;

import java.util.List;

@RestController
@RequestMapping("/api/v1/biblioteca/auth")
@Tag(name = "Seguridad", description = " Operaciones relacionadas con el registro e inicio de sesion de ususario")
public class AuthController {

    @Autowired
    private AuthenticationManager authenticationManager;

    @Autowired
    private UserService userService;

    @Autowired
    private JwtService jwtService;

    @PostMapping("/login")
    @Operation(summary = "inicio de sesion", description = "iniciar sesion con el usuario para recibir el token")
    public AuthResponse login(@RequestBody LoginRequest request) {
        authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(request.getUsername(), request.getPassword())
        );
        User user = userService.findByUsername(request.getUsername());
        String token = jwtService.generateToken(user);

        return new AuthResponse(token);
    }

    @PostMapping("/register")
    @Operation(summary = "registro de usuario", description = "agregar ususarios al sistema")
    public String register(@RequestBody User user) {
        userService.save(user);
        return "Usuario registrado exitosamente";
    }
    @GetMapping("/users")
    @Operation(summary = "Listar todos los usuarios", description = "Retorna una lista completa de los usuarios registrados")
    public List<User> getAllUsers() {
        return userService.findAllUsers();
    }
}