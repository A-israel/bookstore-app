package com.example.bookstore.repositories;

import com.example.bookstore.tables.Orders;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;

public interface OrderRepository extends JpaRepository<Orders, Integer> {
    // Finds all order instances by the user entity's primary unique ID (uid)
    List<Orders> findByUsersUid(int uid);
    List<Orders> findByUsersEmailOrderByDateDesc(String email);
    @Query("SELECT o FROM Orders o WHERE o.users.email = :email")
    List<Orders> findMyCustomOrders(@Param("email") String email);

}