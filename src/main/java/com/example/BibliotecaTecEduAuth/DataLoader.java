package com.example.BibliotecaTecEduAuth;

import com.example.BibliotecaTecEduAuth.Model.*;
import com.example.BibliotecaTecEduAuth.Repository.*;
import net.datafaker.Faker;
import net.datafaker.providers.base.Internet;
import net.datafaker.providers.base.Text;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.CommandLineRunner;

import org.springframework.stereotype.Component;
import java.util.List;
import java.util.Random;



@Component
public class DataLoader implements CommandLineRunner {

    @Autowired
    private UserRepository userRepository;

    @Override
    public void run(String... args) throws Exception {
        Faker faker = new Faker();
        Random random = new Random();
        Role[] roles = Role.values();

        for (int i = 0; i < 50; i++) {
            User user = new User();
            user.setUsername(faker.internet().username());
            user.setPassword(faker.internet().password());
            user.setRole(roles[random.nextInt(roles.length)]);

            userRepository.save(user);
        }

        List<User> usuario = userRepository.findAll();
    }
}
