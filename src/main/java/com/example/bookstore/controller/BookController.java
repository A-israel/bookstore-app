package com.example.bookstore.controller;

import com.example.bookstore.tables.Books;
import com.example.bookstore.repositories.BookRepository;

import org.springframework.data.domain.Page;
import org.springframework.web.bind.annotation.*;

import org.springframework.data.domain.Pageable;
import java.util.List;

@RestController
@RequestMapping("/api/books")
@CrossOrigin("*")
public class BookController {

    private final BookRepository bookRepository;

    public BookController(BookRepository bookRepository) {
        this.bookRepository = bookRepository;
    }

    @GetMapping
    public Page<Books> getBooks(Pageable pageable) {
        return bookRepository.findAll(pageable);
    }
}