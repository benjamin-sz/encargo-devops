package com.example.BibliotecaTecEduAuth.Controller;

import com.example.BibliotecaTecEduAuth.Assemblers.AuthModelAssembler;
import com.example.BibliotecaTecEduAuth.Model.User;
import com.example.BibliotecaTecEduAuth.Security.JwtService;
import com.example.BibliotecaTecEduAuth.Service.UserService;
import com.example.BibliotecaTecEduAuth.dto.AuthResponse;
import com.example.BibliotecaTecEduAuth.dto.LoginRequest;
import com.example.BibliotecaTecEduAuth.dto.UserDto;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.hateoas.CollectionModel;
import org.springframework.hateoas.EntityModel;
import org.springframework.hateoas.MediaTypes;
import org.springframework.http.ResponseEntity;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.stream.Collectors;

import static org.springframework.hateoas.server.mvc.WebMvcLinkBuilder.*;

@RestController
@RequestMapping("/api/v2/biblioteca/auth")
@Tag(name = "Seguridad v2", description = "Operaciones de seguridad y gestión de usuarios")
public class AuthControllerV2 {

    @Autowired
    private AuthenticationManager authenticationManager;

    @Autowired
    private UserService userService;

    @Autowired
    private JwtService jwtService;

    @Autowired
    private AuthModelAssembler assembler;

    @PostMapping("/login")
    @Operation(summary = "inicio de sesion")
    public AuthResponse login(@RequestBody LoginRequest request) {
        authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(request.getUsername(), request.getPassword())
        );
        User user = userService.findByUsername(request.getUsername());
        String token = jwtService.generateToken(user);
        return new AuthResponse(token);
    }

    @PostMapping("/register")
    @Operation(summary = "registro de usuario")
    // Cambiado de EntityModel<User> a EntityModel<UserDto>
    public ResponseEntity<EntityModel<UserDto>> register(@RequestBody User user) {
        User newUser = userService.save(user);
        return ResponseEntity
                .created(linkTo(methodOn(AuthControllerV2.class).getUserByUsername(newUser.getUsername())).toUri())
                .body(assembler.toModel(newUser)); // El assembler se encargará de pasarlo a DTO
    }

    @GetMapping(value = "/users", produces = MediaTypes.HAL_JSON_VALUE)
    @Operation(summary = "Listar todos los usuarios")
    // Cambiado de CollectionModel<EntityModel<User>> a CollectionModel<EntityModel<UserDto>>
    public CollectionModel<EntityModel<UserDto>> getAllUsers() {
        List<EntityModel<UserDto>> users = userService.findAllUsers().stream()
                .map(assembler::toModel) // Ahora mapea a DTO con links
                .collect(Collectors.toList());

        return CollectionModel.of(users,
                linkTo(methodOn(AuthControllerV2.class).getAllUsers()).withSelfRel());
    }

    @GetMapping(value = "/users/{username}", produces = MediaTypes.HAL_JSON_VALUE)
    @Operation(summary = "Obtener usuario por username")
    // Cambiado de EntityModel<User> a EntityModel<UserDto>
    public EntityModel<UserDto> getUserByUsername(@PathVariable String username) {
        User user = userService.findByUsername(username);
        return assembler.toModel(user);
    }
}