package com.example.bookstore.repositories;

import com.example.bookstore.tables.Books;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List; // 👈 INDICATED CHANGE: Added standard List import

public interface BookRepository extends JpaRepository<Books, Integer> {

    // 👈 INDICATED CHANGE: Changed return type from Page<Books> to List<Books>
    // and removed the 'Pageable pageable' parameter to match your unpaged architecture
    List<Books> findByTitleContainingIgnoreCaseOrAuthorContainingIgnoreCaseOrderByGenre(
            String titleKeyword,
            String authorKeyword,
            String genreKeyword
    );
}