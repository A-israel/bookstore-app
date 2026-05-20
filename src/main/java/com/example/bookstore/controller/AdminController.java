package com.example.bookstore.controller;

import com.example.bookstore.tables.Books;
import com.example.bookstore.repositories.BookRepository;
import com.example.bookstore.repositories.OrderRepository;
import com.example.bookstore.repositories.UserRepository;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/admin")
@CrossOrigin("*")
public class AdminController {

    private final BookRepository bookRepository;
    private final OrderRepository orderRepository;
    private final UserRepository userRepository;

    public AdminController(BookRepository bookRepository, OrderRepository orderRepository, UserRepository userRepository) {
        this.bookRepository = bookRepository;
        this.orderRepository = orderRepository;
        this.userRepository = userRepository;
    }

    // 1. Fetch high-level analytical matrix blocks for dashboard cards
    @GetMapping("/dashboard-stats")
    public ResponseEntity<?> getDashboardStats() {
        long totalBooks = bookRepository.count();
        long totalOrders = orderRepository.count();
        long totalUsers = userRepository.count();

        // Calculate total gross revenue across all system order rows
        double totalRevenue = orderRepository.findAll().stream()
                .mapToDouble(order -> order.getTotal_price())
                .sum();

        Map<String, Object> stats = new HashMap<>();
        stats.put("totalBooks", totalBooks);
        stats.put("totalOrders", totalOrders);
        stats.put("totalUsers", totalUsers);
        stats.put("totalRevenue", Math.round(totalRevenue * 100.0) / 100.0);

        return ResponseEntity.ok(stats);
    }

    // 2. Add a new book to the catalog (Create)
    @PostMapping("/books")
    public ResponseEntity<Books> addBook(@RequestBody Books book) {
        Books savedBook = bookRepository.save(book);
        return ResponseEntity.ok(savedBook);
    }

    // 3. Modify details of an existing catalog book (Update)
    @PutMapping("/books/{id}")
    public ResponseEntity<Books> updateBook(@PathVariable("id") int id, @RequestBody Books bookDetails) {
        Books book = bookRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Book entry target not found"));

        book.setTitle(bookDetails.getTitle());
        book.setAuthor(bookDetails.getAuthor());
        book.setPrice(bookDetails.getPrice());
        book.setStock(bookDetails.getStock());
        // Add any other specific model setter mutations here if necessary

        Books updatedBook = bookRepository.save(book);
        return ResponseEntity.ok(updatedBook);
    }

    // 4. Delete a book entirely from the store catalog (Delete)
    @DeleteMapping("/books/{id}")
    public ResponseEntity<?> deleteBook(@PathVariable("id") int id) {
        bookRepository.deleteById(id);
        return ResponseEntity.ok("Book deleted successfully from inventory registries.");
    }
}