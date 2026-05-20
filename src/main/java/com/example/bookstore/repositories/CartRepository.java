package com.example.bookstore.repositories;

import com.example.bookstore.tables.CartItems;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;
import java.util.Optional;

public interface CartRepository extends JpaRepository<CartItems, Integer> {

    // Target the 'id' property nested inside the 'users' entity object
    List<CartItems> findByUsersUid(int userUid);

    // Target the 'id' property of users, and the 'bid' property of books
    Optional<CartItems> findByUsersUidAndBooksBid(int userId, int bookId);
    Optional<CartItems> findByBooks_Bid(int bookId);

    // Clear cart contents targeting user relationship ID
    void deleteByUsersUid(int userId);
}