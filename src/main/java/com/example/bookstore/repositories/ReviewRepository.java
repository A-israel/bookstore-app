package com.example.bookstore.repositories;

import com.example.bookstore.tables.Reviews;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface ReviewRepository extends JpaRepository<Reviews, Integer> {
    List<Reviews> findByUsersUid(int uid);
    List<Reviews> findByBooksBidOrderByCreatedAtDesc(Integer bid);

}
