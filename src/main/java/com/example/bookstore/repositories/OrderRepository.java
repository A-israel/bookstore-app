package com.example.bookstore.repositories;

import com.example.bookstore.tables.Orders;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface OrderRepository extends JpaRepository<Orders, Integer> {
    // Finds all order instances by the user entity's primary unique ID (uid)
    List<Orders> findByUsersUid(int uid);
}