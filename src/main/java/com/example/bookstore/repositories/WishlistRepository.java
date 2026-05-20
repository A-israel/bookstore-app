package com.example.bookstore.repositories;

import com.example.bookstore.tables.Wishlist;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface WishlistRepository extends JpaRepository<Wishlist, Integer> {
    List<Wishlist> findByUsersUid(int userUid);
    Optional<Wishlist> findByUsersUidAndBooksBid(int userUid, int bookId);
    void deleteByUsersUidAndBooksBid(int userUid, int bookId);
}
