package com.example.bookstore.controller;

import com.example.bookstore.tables.CartItems;
import com.example.bookstore.tables.Books;
import com.example.bookstore.repositories.CartRepository;
import com.example.bookstore.repositories.BookRepository;
import com.example.bookstore.tables.Users;
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

    public CartController(CartRepository cartRepository, BookRepository bookRepository) {
        this.cartRepository = cartRepository;
        this.bookRepository = bookRepository;
    }

    // ── GET CART ITEMS ──
    @GetMapping
    public List<CartItems> getCartItems() {
        return cartRepository.findAll();
    }

    // ── ADD ITEMS WITH REQ PARAM ──
    @PostMapping("/add")
    public CartItems addToCart(@RequestParam("bookId") Integer bookId) {
        Optional<CartItems> existingCartItem = cartRepository.findByBooks_Bid(bookId);

        if (existingCartItem.isPresent()) {
            CartItems cartItem = existingCartItem.get();
            cartItem.setQuantity(cartItem.getQuantity() + 1);
            return cartRepository.save(cartItem);
        } else {
            Books book = bookRepository.findById(bookId)
                    .orElseThrow(() -> new RuntimeException("Book not found with ID: " + bookId));
            CartItems newCartItem = new CartItems();
            newCartItem.setBooks(book);
            newCartItem.setQuantity(1);
            Users mockUser = new Users();
            mockUser.setUid(1);
            newCartItem.setUsers(mockUser);
            return cartRepository.save(newCartItem);
        }
    }

    // ── UPDATE QUANTITY ENDPOINT (FOR + / - BUTTONS) ──
    @PutMapping("/update")
    public CartItems updateQuantity(@RequestParam("cartItemId") int cartItemId, @RequestParam("quantity") int quantity) {
        CartItems item = cartRepository.findById(cartItemId)
                .orElseThrow(() -> new RuntimeException("Cart item not found"));
        item.setQuantity(quantity);
        return cartRepository.save(item);
    }

    // ── DELETE ENTRY ENDPOINT ──
    @DeleteMapping("/delete/{id}")
    public Map<String, Boolean> deleteItem(@PathVariable("id") int id) {
        CartItems item = cartRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Cart item not found"));
        cartRepository.delete(item);
        return Map.of("success", true);
    }
}