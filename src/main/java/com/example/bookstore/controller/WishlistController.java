package com.example.bookstore.controller;

import com.example.bookstore.tables.Wishlist;
import com.example.bookstore.tables.Books;
import com.example.bookstore.tables.Users;
import com.example.bookstore.repositories.WishlistRepository;
import com.example.bookstore.repositories.BookRepository;
import org.springframework.web.bind.annotation.*;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Map;
import java.util.Optional;

@RestController
@RequestMapping("/api/wishlist")
@CrossOrigin(origins = "*", allowedHeaders = "*")
public class WishlistController {

    private final WishlistRepository wishlistRepository;
    private final BookRepository bookRepository;

    public WishlistController(WishlistRepository wishlistRepository, BookRepository bookRepository) {
        this.wishlistRepository = wishlistRepository;
        this.bookRepository = bookRepository;
    }

    // ── GET USER WISHLIST ──
    @GetMapping
    public List<Wishlist> getWishlist() {
        // Using our placeholder dev user ID 1 to match our cart pattern setup
        return wishlistRepository.findByUsersUid(1);
    }

    // ── ADD TO WISHLIST ──
    @PostMapping("/add")
    public Wishlist addToWishlist(@RequestParam("bookId") Integer bookId) {
        Optional<Wishlist> existing = wishlistRepository.findByUsersUidAndBooksBid(1, bookId);
        if (existing.isPresent()) {
            return existing.get();
        }

        Books book = bookRepository.findById(bookId)
                .orElseThrow(() -> new RuntimeException("Book not found"));

        Users mockUser = new Users();
        mockUser.setUid(1);

        Wishlist wishlistEntry = new Wishlist();
        wishlistEntry.setBooks(book);
        wishlistEntry.setUsers(mockUser);

        return wishlistRepository.save(wishlistEntry);
    }

    // ── REMOVE FROM WISHLIST ──
    @DeleteMapping("/remove/{bookId}")
    @Transactional
    public Map<String, Boolean> removeFromWishlist(@PathVariable("bookId") int bookId) {
        wishlistRepository.deleteByUsersUidAndBooksBid(1, bookId);
        return Map.of("success", true);
    }
}