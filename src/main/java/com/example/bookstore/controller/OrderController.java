package com.example.bookstore.controller;

import com.example.bookstore.tables.*;
import com.example.bookstore.repositories.*;
import org.springframework.http.ResponseEntity;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@RestController
@RequestMapping("/api/orders")
@CrossOrigin("*")
public class OrderController {

    private final OrderRepository orderRepository;
    private final CartRepository cartRepository;

    public OrderController(OrderRepository orderRepository, CartRepository cartRepository) {
        this.orderRepository = orderRepository;
        this.cartRepository = cartRepository;
    }

    // 1. Process Checkout / Place a new Order
    @PostMapping("/checkout/{userId}")
    @Transactional // Ensures database rollbacks if cart clearing or saving drops/fails midway
    public ResponseEntity<?> checkout(@PathVariable("userId") int userId) {

        // Step A: Pull active cart items for the user
        List<CartItems> cartItems = cartRepository.findByUsersUid(userId);
        if (cartItems.isEmpty()) {
            return ResponseEntity.badRequest().body("Cannot checkout an empty shopping cart!");
        }

        // Step B: Initialize our parent Order transaction envelope
        Orders order = new Orders();
        Users userRef = new Users();
        userRef.setUid(userId);
        order.setUsers(userRef);
        order.setDate(LocalDateTime.now());
        order.setStatus("COMPLETED");

        double calculatedTotal = 0.0;
        List<OrderItems> orderItemsList = new ArrayList<>();

        // Step C: Translate cart records into historical line items
        for (CartItems cartItem : cartItems) {
            OrderItems orderItem = new OrderItems();
            orderItem.setOrder(order);
            orderItem.setBooks(cartItem.getBooks());
            orderItem.setQuantity(cartItem.getQuantity());

            // Assuming your Books entity contains a 'getPrice()' double property
            double bookPrice = cartItem.getBooks().getPrice();
            orderItem.setPriceAtPurchase(bookPrice);

            // Accumulate financial matrix calculations
            calculatedTotal += (bookPrice * cartItem.getQuantity());
            orderItemsList.add(orderItem);
        }

        // Step D: Map aggregated details to the transaction parent layout
        order.setTotal_price(calculatedTotal);
        order.setOrderItems(orderItemsList);

        // Step E: Save order details down to database schemas
        Orders completedOrder = orderRepository.save(order);

        // Step F: Obliterate the old cart items so their dashboard view zeroes out
        cartRepository.deleteByUsersUid(userId);

        return ResponseEntity.ok(completedOrder);
    }

    // 2. Fetch order histories for profile overview tracking pages
    @GetMapping("/history/{userId}")
    public List<Orders> getOrderHistory(@PathVariable("userId") int userId) {
        return orderRepository.findByUsersUid(userId);
    }
}