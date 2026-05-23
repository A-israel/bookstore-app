package com.example.bookstore.controller;

import com.example.bookstore.repositories.UserRepository;
import com.example.bookstore.tables.Orders;
import com.example.bookstore.tables.OrderItems;
import com.example.bookstore.tables.CartItems; // Assumes your basket item table name
import com.example.bookstore.tables.Users;
import com.example.bookstore.tables.DeliveryStatus; // Explicitly map your status enum
import com.example.bookstore.repositories.OrderRepository;
import com.example.bookstore.repositories.CartRepository; // Assumes your repository name
import org.springframework.security.core.context.SecurityContextHolder;
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
    private final UserRepository userRepository;

    public OrderController(OrderRepository orderRepository, CartRepository cartRepository,UserRepository userRepository) {
        this.orderRepository = orderRepository;
        this.cartRepository = cartRepository;
        this.userRepository = userRepository;
    }

    // ── FETCH ORDERS SPECIFIC TO LOGGED-IN USER ──
    @GetMapping("/user")
    public ResponseEntity<?> getUserOrders() {
        try {
            // 1. Safely extract user email from the validated JWT token context
            String email = SecurityContextHolder.getContext().getAuthentication().getName();

            if (email == null || email.equals("anonymousUser")) {
                return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("Unauthorized: Please log in to view your orders.");
            }

            // 2. Fetch only the orders belonging to this email
            List<Orders> userOrders = orderRepository.findMyCustomOrders(email);

            // Log this to your Spring Boot console terminal to verify rows are found!
            System.out.println("📦 Found orders for " + email + ": " + userOrders.size());

            return ResponseEntity.ok(userOrders);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("Error fetching orders: " + e.getMessage());
        }
    }

    @PostMapping("/checkout")
    @Transactional
    public ResponseEntity<?> checkoutCart() {
        try {
            // 🟢 1. Safely extract user email from the validated JWT token context
            String email = SecurityContextHolder.getContext().getAuthentication().getName();

            if (email == null || email.equals("anonymousUser")) {
                return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("Unauthorized: Please log in to process your checkout.");
            }

            // 🟢 2. Fetch the logged-in user details to get their dynamic UID
            Users currentUser = userRepository.findUsersByEmail(email);
            if (currentUser == null) {
                // If your repository uses 'findUsersByEmail', keep that name but log a clear error:
                System.out.println("❌ CRITICAL: UserRepository returned null for email: " + email);
                return ResponseEntity.status(HttpStatus.NOT_FOUND).body("User context could not be resolved from DB.");
            }

            // 🟢 3. Pull cart contents belonging dynamically to this specific logged-in user ID
            List<CartItems> activeCart = cartRepository.findByUsersUid(currentUser.getUid());
            if (activeCart.isEmpty()) {
                return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                        .body("Cannot process checkout: your shopping cart basket is empty!");
            }

            // Calculate item totals handling double values safely
            double itemsSubtotal = 0.0;
            for (CartItems item : activeCart) {
                itemsSubtotal += item.getBooks().getPrice() * item.getQuantity();
            }

            // Add delivery logistics cost rule (e.g., ₦1,500)
            double overallTotal = itemsSubtotal + 1500.0;

            // Instantiate parent entity applying your exact field signatures
            Orders order = new Orders();
            order.setUsers(currentUser); // Maps 'uid' column dynamically
            order.setDate(LocalDateTime.now()); // Maps 'date'
            order.setStatus("Processing"); // Maps 'status'
            order.setTotal_price(overallTotal); // Maps exact 'total_price' double field
            order.setDelivery_status(DeliveryStatus.PENDING); // Maps enum constraint safely

            // 🟢 Dynamic fallback: use the user's specific registered shipping address if available
            String address = (currentUser.getShipping_address() != null && !currentUser.getShipping_address().isEmpty())
                    ? currentUser.getShipping_address()
                    : "Aptech Maryland";
            order.setShipping_address(address);

            order.setTracking_number("BKSTR-" + System.currentTimeMillis()); // Maps tracking string
            order.setEstimated_delivery_date(LocalDateTime.now().plusDays(4)); // Maps delivery date

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

            // 🟢 4. Wipe only THIS specific user's active basket lines cleanly using their dynamic UID
            cartRepository.deleteByUsersUid(currentUser.getUid());

            return ResponseEntity.status(HttpStatus.CREATED).body(completedOrder);

        } catch (Exception e) {
            System.err.println("CRITICAL SYSTEM CHECKOUT ERROR: " + e.getMessage());
            e.printStackTrace();
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body("Database entry assignment constraint failed: " + e.getMessage());
        }
    }
}