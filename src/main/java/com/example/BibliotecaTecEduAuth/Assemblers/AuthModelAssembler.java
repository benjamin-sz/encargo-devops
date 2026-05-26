package com.example.BibliotecaTecEduAuth.Assemblers;

import com.example.BibliotecaTecEduAuth.Controller.AuthControllerV2;
import com.example.BibliotecaTecEduAuth.Model.User;
import com.example.BibliotecaTecEduAuth.dto.UserDto;
import org.springframework.hateoas.EntityModel;
import org.springframework.hateoas.server.RepresentationModelAssembler;
import org.springframework.stereotype.Component;

import static org.springframework.hateoas.server.mvc.WebMvcLinkBuilder.*;

@Component
public class AuthModelAssembler implements RepresentationModelAssembler<User, EntityModel<UserDto>> {

    @Override
    public EntityModel<UserDto> toModel(User user) {

        UserDto dto = new UserDto();
        dto.setUsername(user.getUsername());
        dto.setRole(user.getRole());


        return EntityModel.of(dto,
                linkTo(methodOn(AuthControllerV2.class).getUserByUsername(user.getUsername())).withSelfRel(),
                linkTo(methodOn(AuthControllerV2.class).getAllUsers()).withRel("all_users"));
    }
}