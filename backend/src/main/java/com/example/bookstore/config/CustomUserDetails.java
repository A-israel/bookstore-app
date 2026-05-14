package com.example.bookstore.config;

import com.example.bookstore.repositories.UserRepository;
import com.example.bookstore.tables.Users;
import org.springframework.security.core.userdetails.User;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;

@Service
public class CustomUserDetails implements UserDetailsService {
    private UserRepository urepo;

    public CustomUserDetails(UserRepository urepo){

        this.urepo = urepo;
    }
    @Override
    public UserDetails loadUserByUsername(String username) throws UsernameNotFoundException {
        if (username == null && username.trim().isEmpty()){

            throw new UsernameNotFoundException("Username not found!!!");

        }

        Users u = urepo.findUsersByEmail(username);

        if (u == null){
            throw new RuntimeException("Something is wrong");
        }

        UserDetails udetails = User.builder()
                .username(u.getEmail())
                .password(u.getPassword())
                .roles(u.getRole())
                .build();



        return udetails;
    }

}
