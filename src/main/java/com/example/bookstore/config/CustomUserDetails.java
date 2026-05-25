package com.example.bookstore.config;

import com.example.bookstore.repositories.UserRepository;
import com.example.bookstore.tables.Users;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.User;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;

import java.util.Collections;

@Service
public class CustomUserDetails implements UserDetailsService {
    private final UserRepository urepo;

    public CustomUserDetails(UserRepository urepo) {
        this.urepo = urepo;
    }

    @Override
    public UserDetails loadUserByUsername(String username) throws UsernameNotFoundException {
        if (username == null || username.trim().isEmpty()) {
            throw new UsernameNotFoundException("Email input cannot be empty.");
        }

        Users u = urepo.findUsersByEmail(username);

        if (u == null) {
            throw new UsernameNotFoundException("No user found with email: " + username);
        }

        // ✅ CLEANED: Pass the database role column value directly to Spring's builder
        return User.builder()
                .username(u.getEmail())
                .password(u.getPassword())
                .authorities(new SimpleGrantedAuthority(u.getRole().toUpperCase()))
                .build();
    }
}