package com.example.bookstore.config;

import com.example.bookstore.repositories.BookRepository;
import com.example.bookstore.services.BookImportService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Configuration;

@Configuration
public class DataLoader implements CommandLineRunner {
    private final BookImportService bimp;
    private final BookRepository repository;

    public DataLoader(BookImportService bimp, BookRepository repository) {
        this.bimp = bimp;
        this.repository = repository;
    }

    @Override
    public void run(String... args) {
        if (repository.count() == 0) {

            bimp.importBooksBySubject("romance");
            bimp.importBooksBySubject("fantasy");
            bimp.importBooksBySubject("thriller");
            bimp.importBooksBySubject("action");
            bimp.importBooksBySubject("sci-fi");
            bimp.importBooksBySubject("adventure");
            bimp.importBooksBySubject("poetry");
            bimp.importBooksBySubject("horror");
            bimp.importBooksBySubject("gospel");
            bimp.importBooksBySubject("education");



        }
    }
}