package com.example.bookstore.config;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.lang.NonNull;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.web.authentication.WebAuthenticationDetailsSource;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;
import org.springframework.util.StringUtils;

import java.io.IOException;

@Component
public class JwtFilter extends OncePerRequestFilter { // Fixed: Extends OncePerRequestFilter

    private final CustomUserDetails cdetails;
    private final JwtUserTokens utokens;

    public JwtFilter(CustomUserDetails cdetails, JwtUserTokens utokens) {
        this.cdetails = cdetails;
        this.utokens = utokens;
    }

    @Override
    protected void doFilterInternal(
            @NonNull HttpServletRequest request,
            @NonNull HttpServletResponse response,
            @NonNull FilterChain filterChain
    ) throws ServletException, IOException {

        // 1. Get the JWT Token from Header
        String token = getJwtFromRequest(request);

        // 2. Validate Token and Authenticate
        if (StringUtils.hasText(token) && utokens.validateToken(token)) {
            String username = utokens.getUsernameFromTokens(token);

            if (username != null && SecurityContextHolder.getContext().getAuthentication() == null) {
                // 3. Load UserDetails from database
                UserDetails userDetails = cdetails.loadUserByUsername(username);

                // 4. Create Authentication Token
                UsernamePasswordAuthenticationToken authentication = new UsernamePasswordAuthenticationToken(
                        userDetails,
                        null,
                        userDetails.getAuthorities()
                );

                // Link request details to authentication
                authentication.setDetails(new WebAuthenticationDetailsSource().buildDetails(request));

                // 5. Set Security Context
                SecurityContextHolder.getContext().setAuthentication(authentication);
            }
        }

        // 6. Continue the filter chain
        filterChain.doFilter(request, response);
    }

    private String getJwtFromRequest(HttpServletRequest request) {
        String bearerToken = request.getHeader("Authorization");
        if (StringUtils.hasText(bearerToken) && bearerToken.startsWith("Bearer ")) {
            return bearerToken.substring(7);
        }
        return null;
    }
}