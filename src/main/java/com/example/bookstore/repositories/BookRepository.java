package com.example.bookstore.repositories;

import com.example.bookstore.tables.Books;
import org.springframework.data.domain.Page;
import org.springframework.data.jpa.repository.JpaRepository;

import java.awt.print.Pageable;

public interface BookRepository extends JpaRepository<Books, Integer> {


}
