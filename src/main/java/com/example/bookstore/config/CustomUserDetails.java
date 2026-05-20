package com.example.bookstore.config;

import com.example.bookstore.repositories.UserRepository;
import com.example.bookstore.tables.Users;
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
        // Fix the logical bug to handle empty/null text transfers correctly
        if (username == null || username.trim().isEmpty()) {
            throw new UsernameNotFoundException("Email input cannot be empty.");
        }

        Users u = urepo.findUsersByEmail(username);

        // Throw a Spring-compliant exception instead of a generic RuntimeException
        if (u == null) {
            throw new UsernameNotFoundException("No user found with email: " + username);
        }

        // Build the authenticated principal profile using your system parameters
        return User.builder()
                .username(u.getEmail())
                .password(u.getPassword())
                .roles(u.getRole()) // Checks against values like "USER" or "ADMIN"
                .build();
    }
}