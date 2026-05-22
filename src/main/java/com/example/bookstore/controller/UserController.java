package com.example.bookstore.controller;

import com.example.bookstore.dto.request.LoginReq;
import com.example.bookstore.dto.request.UserReq;
import com.example.bookstore.repositories.UserRepository;
import com.example.bookstore.services.UserService;
import com.example.bookstore.tables.Users;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/auth") // Standardized for security config
@CrossOrigin("*")
public class UserController {

    private final UserService userservice;
    private final UserRepository urepo;

    public UserController(UserService uservice,UserRepository urepo) {
        this.userservice = uservice;
        this.urepo= urepo;
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
    // ── FETCH CURRENT LOGGED-IN USER PROFILE ──
    @GetMapping("/profile")
    public ResponseEntity<?> getUserProfile() {
        try {
            // 1. Extract email from validated JWT token context
            String email = SecurityContextHolder.getContext().getAuthentication().getName();

            if (email == null || email.equals("anonymousUser")) {
                return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("Unauthorized context profile request.");
            }

            // 2. Fetch user information from database
            Users user = urepo.findUsersByEmail(email); // Ensure findUsersByEmail is exposed in UserService
            if (user == null) {
                return ResponseEntity.status(HttpStatus.NOT_FOUND).body("User profile not found.");
            }

            // 3. Return user profile safely (excluding password hashes for security)
            Map<String, Object> profileData = new HashMap<>();
            profileData.put("fullname", user.getFullname()); //
            profileData.put("email", user.getEmail()); //
            profileData.put("shipping_address", user.getShipping_address()); //
            profileData.put("payment_method", user.getPayment_method()); //

            return ResponseEntity.ok(profileData);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("Error: " + e.getMessage());
        }
    }
}