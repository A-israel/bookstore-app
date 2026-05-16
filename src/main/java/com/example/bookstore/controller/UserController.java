package com.example.bookstore.controller;

import com.example.bookstore.dto.request.LoginReq;
import com.example.bookstore.dto.request.UserReq;
import com.example.bookstore.services.UserService;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/auth") // Standardized for security config
@CrossOrigin("*")
public class UserController {

    private final UserService userservice;

    public UserController(UserService uservice) {
        this.userservice = uservice;
    }

    @PostMapping("/register")
    public ResponseEntity<?> register(@RequestBody UserReq ureq) {
        boolean success = userservice.register(ureq);
        if (success) {
            return ResponseEntity.status(HttpStatus.CREATED).body("User registered successfully");
        }
        return ResponseEntity.badRequest().body("Registration failed: Email might already exist");
    }

    @PostMapping("/login")
    public ResponseEntity<?> login(@RequestBody LoginReq lreq) {
        String token = userservice.login(lreq);
        if (token != null) {
            Map<String, String> response = new HashMap<>();
            response.put("token", token);
            return ResponseEntity.ok(response);
        }
        return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("Invalid email or password");
    }

    @PutMapping("/update")
    public ResponseEntity<?> updateProfile(@RequestBody UserReq ureq) {
        // Identify the user by the email in the request body
        boolean updated = userservice.changeUser(ureq);
        if (updated) {
            return ResponseEntity.ok("Profile updated successfully");
        }
        return ResponseEntity.status(HttpStatus.NOT_FOUND).body("User not found");
    }


    @DeleteMapping("/delete/{email}")
    public ResponseEntity<?> deleteUser(@PathVariable String email) {
        boolean isDeleted = userservice.deleteUser(email);

        if (isDeleted) {
            return ResponseEntity.ok("User account with email " + email + " has been deleted.");
        }

        return ResponseEntity.status(HttpStatus.NOT_FOUND).body("User not found.");
    }
}