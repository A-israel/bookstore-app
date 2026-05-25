package com.example.bookstore.controller;

import com.example.bookstore.repositories.*;
import com.example.bookstore.tables.Books;
import jakarta.transaction.Transactional;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/admin")
@CrossOrigin("*")
public class AdminController {


    private final BookRepository bookRepository;
    private final OrderRepository orderRepository;
    private final OrderItemsRepository oiRepository;
    private final UserRepository userRepository;
    private final CartRepository cartRepository;
    private final WishlistRepository wishRepository;
    private final ReviewRepository reviewRepository;

    public AdminController(BookRepository bookRepository,OrderItemsRepository oiRepository, ReviewRepository reviewRepository, OrderRepository orderRepository, UserRepository userRepository,CartRepository cartRepository,WishlistRepository wishRepository) {
        this.bookRepository = bookRepository;
        this.orderRepository = orderRepository;
        this.userRepository = userRepository;
        this.cartRepository = cartRepository;
        this.wishRepository = wishRepository;
        this.reviewRepository = reviewRepository;
        this.oiRepository = oiRepository;
    }

    @GetMapping("/dashboard-stats")
    public ResponseEntity<?> getDashboardStats() {
        long totalBooks = bookRepository.count();
        long totalOrders = orderRepository.count();
        long totalUsers = userRepository.count();

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

    @GetMapping("/users")
    public ResponseEntity<?> getAllUsers() {
        try {
            java.util.List<Map<String, Object>> safeUsers = userRepository.findAll().stream().map(user -> {
                org.springframework.security.core.Authentication auth =
                        org.springframework.security.core.context.SecurityContextHolder.getContext().getAuthentication();
                System.out.println("Active Username connecting: " + auth.getName());
                System.out.println("Authorities assigned to token session: " + auth.getAuthorities());
                Map<String, Object> map = new HashMap<>();
                map.put("uid", user.getUid());
                map.put("fullname", user.getFullname());
                map.put("email", user.getEmail());
                map.put("role", user.getRole());
                map.put("shipping_address", user.getShipping_address());
                return map;
            }).toList();
            return ResponseEntity.ok(safeUsers);
        } catch (Exception e) {
            return ResponseEntity.badRequest().body("Failed to retrieve directory: " + e.getMessage());
        }
    }

    @GetMapping("/orders")
    public ResponseEntity<?> getAllSystemOrders() {
        try {
            org.springframework.security.core.Authentication auth =
                    org.springframework.security.core.context.SecurityContextHolder.getContext().getAuthentication();
            System.out.println("Active Username connecting: " + auth.getName());
            System.out.println("Authorities assigned to token session: " + auth.getAuthorities());
            java.util.List<Map<String, Object>> safeOrders = orderRepository.findAll().stream().map(order -> {
                Map<String, Object> map = new HashMap<>();
                map.put("id", order.getId());
                map.put("tracking_number", order.getTracking_number());
                map.put("total_price", order.getTotal_price());
                map.put("status", order.getStatus());
                map.put("shipping_address", order.getShipping_address());
                return map;
            }).toList();
            return ResponseEntity.ok(safeOrders);
        } catch (Exception e) {
            return ResponseEntity.badRequest().body("Failed to retrieve system order context lines: " + e.getMessage());
        }
    }

    @PostMapping("/books/add")
    public ResponseEntity<?> addBook(@RequestBody Books book) {
        try {
           Books savedBook = bookRepository.save(book);
            return ResponseEntity.status(201).body(savedBook);
        } catch (Exception e) {
            return ResponseEntity.badRequest().body("Failed to add book: " + e.getMessage());
        }
    }

    @Transactional
    @PutMapping("/books/{id}")
    public ResponseEntity<Books> updateBook(@PathVariable("id") int id, @RequestBody Books bookDetails) {
        Books book = bookRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Book entry target not found"));

        System.out.println("Updating Book ID: " + id);
        System.out.println("Incoming Title: " + bookDetails.getTitle());
        System.out.println("Incoming Bestseller Status: " + bookDetails.isBestseller());

        book.setTitle(bookDetails.getTitle());
        book.setAuthor(bookDetails.getAuthor());
        book.setPrice(bookDetails.getPrice());
        book.setDescription(bookDetails.getDescription());
        book.setGenre(bookDetails.getGenre());
        book.setStock(bookDetails.getStock());
        book.setCoverUrl(bookDetails.getCoverUrl());
        book.setBestseller(bookDetails.isBestseller());

        Books updatedBook = bookRepository.save(book);
        return ResponseEntity.ok(updatedBook);
    }

    @DeleteMapping("/books/delete/{id}")
    public ResponseEntity<?> deleteBook(@PathVariable("id") int id) {
        if (!bookRepository.existsById(id)) {
            return ResponseEntity.notFound().build();
        }

        try {

             cartRepository.deleteByBooks_Bid(id);

            bookRepository.clearCartReferences(id);
            bookRepository.clearOrderItemReferences(id);
            bookRepository.clearReviewReferences(id);
            bookRepository.clearWishlistReferences(id);

            bookRepository.deleteById(id);

            return ResponseEntity.ok("Book and all associated dependencies deleted successfully! ✅");
        } catch (Exception e) {
            return ResponseEntity.status(500).body("Failed to delete book entry: " + e.getMessage());
        }
    }
}
