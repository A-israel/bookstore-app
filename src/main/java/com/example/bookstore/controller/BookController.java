package com.example.bookstore.controller;

import com.example.bookstore.tables.Books;
import com.example.bookstore.repositories.BookRepository;

import org.springframework.data.domain.Page;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import org.springframework.data.domain.Pageable;
import java.util.List;

@RestController
@RequestMapping("/api/books")
@CrossOrigin(origins = "http://localhost", allowedHeaders = "*")
public class BookController {

    private final BookRepository bookRepository;

    public BookController(BookRepository bookRepository) {
        this.bookRepository = bookRepository;
    }

    @GetMapping("/all")
    public List<Books> getBooks() {
        return bookRepository.findAll();
    }
    @GetMapping("/search")
    public ResponseEntity<List<Books>> searchBooks(@RequestParam("query") String query) {
        if (query == null || query.trim().isEmpty()) {
            // If search is empty, return all books or an empty list
            return ResponseEntity.ok(bookRepository.findAll());
        }

        // Custom search filtering both title and author fields
        List<Books> results = bookRepository.findByTitleContainingIgnoreCaseOrAuthorContainingIgnoreCaseOrderByGenre(query,query,query);
        return ResponseEntity.ok(results);
    }
}