package com.example.BibliotecaTecEduAuth.dto;

import com.example.BibliotecaTecEduAuth.Model.Role;
import lombok.Data;

@Data
public class UserDto {
    private String username;
    private Role role;
}