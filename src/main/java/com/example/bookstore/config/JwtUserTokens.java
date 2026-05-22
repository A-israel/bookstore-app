package com.example.bookstore.config;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.security.Keys;

import org.springframework.security.core.Authentication;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.stereotype.Component;

import javax.crypto.SecretKey;
import java.util.Date;

@Component
public class JwtUserTokens {

    private final String secret =
            "this-is-israel-and-jayp's-project";

    // 24 hours
    private final long jwtExpiration =
            24 * 60 * 60 * 1000;

    // Generate signing key
    private SecretKey getSigningKey() {
        return Keys.hmacShaKeyFor(secret.getBytes());
    }

    // Generate JWT during login
    public String generateToken(String email) {
        return Jwts.builder()
                .setSubject(email)
                .setIssuedAt(new Date())
                .setExpiration(new Date(System.currentTimeMillis() + 1000 * 60 * 60))
                .signWith(getSigningKey())
                .compact();
    }
    // Extract email/username from token
    public String getUsernameFromTokens(String token) {

        try {

            if (token == null || token.trim().isEmpty()) {
                return null;
            }

            Claims claims = Jwts.parser()
                    .verifyWith(getSigningKey())
                    .build()
                    .parseSignedClaims(token)
                    .getPayload();

            return claims.getSubject();

        } catch (Exception ex) {
            return null;
        }
    }

    // Validate JWT
    public boolean validateToken(
            String token,
            UserDetails userDetails
    ) {

        try {

            if (token == null || token.trim().isEmpty()) {
                return false;
            }

            String username =
                    getUsernameFromTokens(token);

            if (username == null) {
                return false;
            }

            // Parse token to ensure signature is valid
            Jwts.parser()
                    .verifyWith(getSigningKey())
                    .build()
                    .parseSignedClaims(token);

            return username.equals(userDetails.getUsername());

        } catch (Exception ex) {
            return false;
        }
    }
}