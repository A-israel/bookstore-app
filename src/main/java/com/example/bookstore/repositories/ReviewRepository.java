package com.example.bookstore.repositories;

import com.example.bookstore.tables.Reviews;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface ReviewRepository extends JpaRepository<Reviews, Integer> {
    List<Reviews> findByBooks_Bid(int bid);
    boolean existsByUsersUidAndAndBooks_Bid(int userId, int bookId);
    List<Reviews> findByBooksBidOrderByCreatedAtDesc(Integer bid);
}
