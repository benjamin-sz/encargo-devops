package com.example.BibliotecaTecEduAuth.Service;


import com.example.BibliotecaTecEduAuth.Model.User;
import com.example.BibliotecaTecEduAuth.Repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class UserService {

    @Autowired
    private UserRepository repository;

    @Autowired
    private PasswordEncoder passwordEncoder;

    public User findByUsername(String username) {
        return repository.findByUsername(username).orElse(null);
    }

    public User save(User user) {
        // Solo encriptamos si la contraseña no parece estar ya encriptada (opcional pero recomendado)
        if (!user.getPassword().startsWith("$2a$")) {
            user.setPassword(passwordEncoder.encode(user.getPassword()));
        }
        return repository.save(user);
    }
    public List<User> findAllUsers() {
        return repository.findAll();
    }
}
