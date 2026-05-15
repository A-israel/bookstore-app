package com.example.bookstore.repositories;

import com.example.bookstore.tables.Books;
import org.springframework.data.jpa.repository.JpaRepository;

public interface BookRepository extends JpaRepository<Books, Integer> {

}
