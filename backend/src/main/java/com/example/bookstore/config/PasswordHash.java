package com.example.bookstore.config;

import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Component;

//this is a class based bean using @Component, services, repositories
@Component
public class PasswordHash {
    //we create a method GetHashed then used the Bcrypt to hash plainpassword which is what we want to hash and hashed password is what we have hashed what we will call
    public String getHashed(String plainpassword){
        BCryptPasswordEncoder encoder = new BCryptPasswordEncoder(16);
        String hashedpassword = encoder.encode(plainpassword);
        return hashedpassword;
    }
}
