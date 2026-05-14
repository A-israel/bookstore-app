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
    private final String secret = "this-is-israel-and-jayp's-project";
    private final  long jwtExpiration = 24 * 60 * 60 * 1000;//Meaning in 24 hours time


    private SecretKey getSigningKey(){
        return Keys.hmacShaKeyFor(secret.getBytes());
    }

    public String generateToken(Authentication authentication){
        UserDetails userDetails = (UserDetails)authentication.getPrincipal();
        Date nownow = new Date();
        Date expired = new Date(nownow.getTime() + jwtExpiration);
        return Jwts.builder()
                .subject(userDetails.getUsername())
                .issuedAt(nownow)
                .expiration(expired)
                //This is way of securing out token
                .signWith(getSigningKey())
                .compact();


    }

    public String generateTokenUsername(String username){
        Date nownow = new Date();
        Date expired = new Date(nownow.getTime() + jwtExpiration);
        return Jwts.builder()
                .subject(username)
                .issuedAt(nownow)
                .expiration(expired)
                .signWith(getSigningKey())
                .compact();

    }
    public String getUsernameFromTokens(String token) {
        try {

            if (token == null || token.trim().isEmpty()){
                return null;
            }
            Claims claims = Jwts.parser()
                    .verifyWith(getSigningKey())
                    .build()
                    .parseSignedClaims(token)
                    .getPayload();
            return  claims.getSubject();
        }
        catch (Exception ex){
            return null;
        }
    }



    public boolean validateToken(String token){
        try{

            if(token == null || token.trim().isEmpty()){
                return false;
            }
            Jwts.parser()
                    .verifyWith(getSigningKey())
                    .build()
                    .parseSignedClaims(token);
            return true;
        }
        catch (Exception ex){
            return false;
        }

    }

}
