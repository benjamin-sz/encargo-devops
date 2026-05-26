package com.example.BibliotecaTecEduAuth;

import com.example.BibliotecaTecEduAuth.Service.UserService;
import com.example.BibliotecaTecEduAuth.Model.User;
import com.example.BibliotecaTecEduAuth.Model.Role;
import org.springframework.boot.CommandLineRunner;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.Bean;

@SpringBootApplication
public class BibliotecaTecEduAuthApplication {

	public static void main(String[] args) {
		SpringApplication.run(BibliotecaTecEduAuthApplication.class, args);
	}

	@Bean
	CommandLineRunner init(UserService userService) {
		return args -> {

			if (userService.findByUsername("admin") == null) {
				User admin = new User();
				admin.setUsername("admin");
				admin.setPassword("1234");
				admin.setRole(Role.ROLE_ADMIN);
				userService.save(admin);
				System.out.println("Usuario admin creado con éxito.");
			} else {
				System.out.println("El usuario admin ya existe.");
			}
		};
	}
}
