package com.example.bookstore.repositories;

import com.example.bookstore.tables.Users;
import org.springframework.data.jpa.repository.JpaRepository;

public interface UserRepository extends JpaRepository<Users, Integer> {
    Users findUsersByEmail(String email);
}
