package com.example.bookstore.controller;

import com.example.bookstore.tables.Orders;
import com.example.bookstore.tables.OrderItems;
import com.example.bookstore.tables.CartItems; // Assumes your basket item table name
import com.example.bookstore.tables.Users;
import com.example.bookstore.tables.DeliveryStatus; // Explicitly map your status enum
import com.example.bookstore.repositories.OrderRepository;
import com.example.bookstore.repositories.CartRepository; // Assumes your repository name
import org.springframework.web.bind.annotation.*;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.http.ResponseEntity;
import org.springframework.http.HttpStatus;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@RestController
@RequestMapping("/api/orders")
@CrossOrigin(origins = "*", allowedHeaders = "*")
public class OrderController {

    private final OrderRepository orderRepository;
    private final CartRepository cartRepository;

    public OrderController(OrderRepository orderRepository, CartRepository cartRepository) {
        this.orderRepository = orderRepository;
        this.cartRepository = cartRepository;
    }

    // ── 1. GET ORDERS HISTORY FOR ACTIVE USER ──
    @GetMapping
    public ResponseEntity<List<Orders>> getOrderHistory() {
        // Change the '1' to your active dynamic user context ID if needed
        List<Orders> userHistory = orderRepository.findByUsersUid(1);
        return ResponseEntity.ok(userHistory);
    }

    // ── 2. TRANSACTIONAL CHECKOUT OPERATION ──
    @PostMapping("/checkout")
    @Transactional
    public ResponseEntity<?> checkoutCart(@RequestParam("shippingAddress") String shippingAddress) {
        try {
            // Pull all cart contents belonging to the current active profile user (ID: 1)
            List<CartItems> activeCart = cartRepository.findByUsersUid(1);
            if (activeCart.isEmpty()) {
                return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                        .body("Cannot process checkout: your shopping cart basket is empty!");
            }

            // Extract user reference context from the active cart sequence
            Users currentUser = activeCart.get(0).getUsers();

            // Calculate item totals handling double values safely
            double itemsSubtotal = 0.0;
            for (CartItems item : activeCart) {
                itemsSubtotal += item.getBooks().getPrice() * item.getQuantity();
            }

            // Add delivery logistics cost rule (e.g., ₦1,500)
            double overallTotal = itemsSubtotal + 1500.0;

            // Instantiate parent entity applying your exact field signatures
            Orders order = new Orders();
            order.setUsers(currentUser); // Maps 'uid' column
            order.setDate(LocalDateTime.now()); // Maps 'date'
            order.setStatus("Processing"); // Maps 'status'
            order.setTotal_price(overallTotal); // Maps exact 'total_price' double field
            order.setDeliveryStatus(DeliveryStatus.PENDING); // Maps enum constraint safely
            order.setShippingAddress(shippingAddress); // Maps address property
            order.setTrackingNumber("BKSTR-" + System.currentTimeMillis()); // Maps tracking string
            order.setEstimatedDeliveryDate(LocalDateTime.now().plusDays(4)); // Maps delivery date

            // Transform each temporary item row into a historical snapshot record
            List<OrderItems> processingItems = new ArrayList<>();
            for (CartItems cartItem : activeCart) {
                OrderItems orderItem = new OrderItems();
                orderItem.setOrder(order); // Core bi-directional parent reference link
                orderItem.setBooks(cartItem.getBooks()); // Maps books 'bid' column
                orderItem.setQuantity(cartItem.getQuantity()); // Maps quantity integer
                orderItem.setPriceAtPurchase(cartItem.getBooks().getPrice()); // Maps price snapshot double
                processingItems.add(orderItem);
            }

            // Bind the sub-item records back into parent order instance list block
            order.setOrderItems(processingItems); // Maps 'orderItems'

            // Commit transaction directly to MySQL layout
            Orders completedOrder = orderRepository.save(order);

            // Wipe active user basket lines cleanly so they can shop again
            cartRepository.deleteByUsersUid(1);

            return ResponseEntity.status(HttpStatus.CREATED).body(completedOrder);

        } catch (Exception e) {
            // Print the exact underlying database error message directly to the console terminal
            System.err.println("CRITICAL SYSTEM CHECKOUT ERROR: " + e.getMessage());
            e.printStackTrace();
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body("Database entry assignment constraint failed: " + e.getMessage());
        }
    }
}