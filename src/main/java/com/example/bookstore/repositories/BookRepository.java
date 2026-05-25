package com.example.bookstore.repositories;

import com.example.bookstore.tables.Books;
import jakarta.transaction.Transactional;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List; // 👈 INDICATED CHANGE: Added standard List import

public interface BookRepository extends JpaRepository<Books, Integer> {

    // 👈 INDICATED CHANGE: Changed return type from Page<Books> to List<Books>
    // and removed the 'Pageable pageable' parameter to match your unpaged architecture
    List<Books> findByTitleContainingIgnoreCaseOrAuthorContainingIgnoreCaseOrderByGenre(
            String titleKeyword,
            String authorKeyword,
            String genreKeyword
    );

    @Modifying
    @Transactional
    @Query(value = "DELETE FROM cart WHERE bid = :bid", nativeQuery = true)
    void clearCartReferences(@Param("bid") int bid);

    @Modifying
    @Transactional
    @Query(value = "DELETE FROM order_items WHERE bid = :bid", nativeQuery = true)
    void clearOrderItemReferences(@Param("bid") int bid);

    @Modifying
    @Transactional
    @Query(value = "DELETE FROM reviews WHERE bid = :bid", nativeQuery = true)
    void clearReviewReferences(@Param("bid") int bid);
}