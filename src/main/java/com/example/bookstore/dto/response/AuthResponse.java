package com.example.bookstore.dto.response;

public class AuthResponse {
    private String token;
    private int userId;
    private String name;

    public AuthResponse(String token, int userId, String name) {
        this.token = token;
        this.userId = userId;
        this.name = name;
    }

    // Getters
    public String getToken() { return token; }
    public int getUserId() { return userId; }
    public String getName() { return name; }
}