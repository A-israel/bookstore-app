package com.example.bookstore.services;

import com.example.bookstore.config.JwtUserTokens;
import com.example.bookstore.config.PasswordHash;
import com.example.bookstore.dto.request.LoginReq;
import com.example.bookstore.dto.request.UserReq;
import com.example.bookstore.repositories.UserRepository;
import com.example.bookstore.tables.Users;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Service;

@Service
public class UserService {
    private final UserRepository rep;
    private final PasswordHash hash;
    private final JwtUserTokens jwtUtils;

    // Corrected Public Constructor
    public UserService(UserRepository rep, PasswordHash hash, JwtUserTokens jwtUtils) {
        this.rep = rep;
        this.hash = hash;
        this.jwtUtils = jwtUtils;
    }

    public boolean register(UserReq ureq) {
        Users u = new Users();
        u.setFirstname(ureq.getFirstname());
        u.setLastname(ureq.getLastname());
        u.setEmail(ureq.getEmail());
        // FIX: Pass the password from ureq into the hash
        u.setPassword(hash.getHashed(ureq.getPassword()));
        u.setShipping_address(ureq.getShipping_address());
        u.setRole("USER");
        return rep.save(u) != null;
    }

    public String login(LoginReq lreq) {
        Users user = rep.findUsersByEmail(lreq.getEmail());
        BCryptPasswordEncoder checker = new BCryptPasswordEncoder();
        if (user != null && checker.matches(lreq.getPassword(), user.getPassword())) {
            return jwtUtils.generateTokenUsername(user.getEmail());
        }
        return null;
    }

    // Refactored for Stateless JWT (No sessions)
    public boolean changeUser(UserReq ureq) {
        Users old = rep.findUsersByEmail(ureq.getEmail());
        if (old == null) return false;

        old.setFirstname(ureq.getFirstname());
        old.setLastname(ureq.getLastname());
        old.setShipping_address(ureq.getShipping_address());
        // Always hash passwords on update!
        old.setPassword(hash.getHashed(ureq.getPassword()));

        return rep.save(old) != null;
    }
}