package com.example.bookstore.controller;

import com.example.bookstore.repositories.UserRepository;
import com.example.bookstore.tables.CartItems;
import com.example.bookstore.tables.Books;
import com.example.bookstore.repositories.CartRepository;
import com.example.bookstore.repositories.BookRepository;
import com.example.bookstore.tables.Users;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.http.ResponseEntity;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;
import java.util.Optional;

@RestController
@RequestMapping("/api/cart")
@CrossOrigin(origins = "*", allowedHeaders = "*")
public class CartController {

    private final CartRepository cartRepository;
    private final BookRepository bookRepository;
    private final UserRepository userRepository;

    public CartController(CartRepository cartRepository, BookRepository bookRepository, UserRepository userRepository) {
        this.cartRepository = cartRepository;
        this.bookRepository = bookRepository;
        this.userRepository = userRepository;
    }

    // ── 1. GET CART ITEMS FOR THE SPECIFIC LOGGED-IN USER ──
    @GetMapping
    public ResponseEntity<?> getCartItems() {
        try {
            String email = SecurityContextHolder.getContext().getAuthentication().getName();
            if (email == null || email.equals("anonymousUser")) {
                return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("Login required to view cart.");
            }

            Users currentUser = userRepository.findUsersByEmail(email);
            if (currentUser == null) {
                return ResponseEntity.status(HttpStatus.NOT_FOUND).body("User profile not found.");
            }

            // 🟢 Fetches items ONLY belonging to this user
            List<CartItems> userCart = cartRepository.findByUsersUid(currentUser.getUid());
            return ResponseEntity.ok(userCart);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("Error: " + e.getMessage());
        }
    }

    // ── 2. DYNAMIC ADD TO CART BY AUTHENTICATED USER ──
    @PostMapping("/add")
    public ResponseEntity<?> addToCart(@RequestParam("bookId") Integer bookId) {
        try {
            // Get user email from token context
            String email = SecurityContextHolder.getContext().getAuthentication().getName();
            if (email == null || email.equals("anonymousUser")) {
                return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("Please log in to add items.");
            }

            Users currentUser = userRepository.findUsersByEmail(email);
            if (currentUser == null) {
                return ResponseEntity.status(HttpStatus.NOT_FOUND).body("User account not found.");
            }

            // 🟢 Crucial: Check if THIS specific user already has this book in their cart
            Optional<CartItems> existingCartItem = cartRepository.findByUsersUidAndBooksBid(currentUser.getUid(), bookId);

            if (existingCartItem.isPresent()) {
                CartItems cartItem = existingCartItem.get();
                cartItem.setQuantity(cartItem.getQuantity() + 1);
                CartItems updatedItem = cartRepository.save(cartItem);
                return ResponseEntity.ok(updatedItem);
            } else {
                Books book = bookRepository.findById(bookId)
                        .orElseThrow(() -> new RuntimeException("Book not found with ID: " + bookId));

                CartItems newCartItem = new CartItems();
                newCartItem.setBooks(book);
                newCartItem.setQuantity(1);
                newCartItem.setUsers(currentUser); // 🟢 Dynamically applies the logged-in user's true UID!

                CartItems savedItem = cartRepository.save(newCartItem);
                return ResponseEntity.status(HttpStatus.CREATED).body(savedItem);
            }
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("Cart operation failed: " + e.getMessage());
        }
    }

    // ── 3. UPDATE QUANTITY ENDPOINT ──
    @PutMapping("/update")
    public ResponseEntity<?> updateQuantity(@RequestParam("cartItemId") int cartItemId, @RequestParam("quantity") int quantity) {
        try {
            CartItems item = cartRepository.findById(cartItemId)
                    .orElseThrow(() -> new RuntimeException("Cart item not found"));
            item.setQuantity(quantity);
            CartItems updatedItem = cartRepository.save(item);
            return ResponseEntity.ok(updatedItem);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(e.getMessage());
        }
    }

    // ── 4. DELETE ENTRY ENDPOINT ──
    @DeleteMapping("/delete/{id}")
    public ResponseEntity<?> deleteItem(@PathVariable("id") int id) {
        try {
            CartItems item = cartRepository.findById(id)
                    .orElseThrow(() -> new RuntimeException("Cart item not found"));
            cartRepository.delete(item);
            return ResponseEntity.ok(Map.of("success", true));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(e.getMessage());
        }
    }
}