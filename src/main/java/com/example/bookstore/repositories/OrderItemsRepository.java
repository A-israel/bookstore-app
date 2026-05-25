package com.example.bookstore.repositories;

import com.example.bookstore.tables.OrderItems;
import jakarta.transaction.Transactional;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface OrderItemsRepository extends JpaRepository<OrderItems, Integer> {
    @Modifying
    @Transactional
    @Query("UPDATE OrderItems o SET o.books = null WHERE o.books.bid = :bid")
    void nullifyBookReferences(@Param("bid") int bid);
}
