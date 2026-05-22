package com.example.bookstore.controller;

import com.example.bookstore.tables.Orders;
import com.example.bookstore.tables.DeliveryStatus;
import com.example.bookstore.repositories.OrderRepository;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/api/delivery")
@CrossOrigin("*")
public class DeliveryController {

    private final OrderRepository orderRepository;

    public DeliveryController(OrderRepository orderRepository) {
        this.orderRepository = orderRepository;
    }

    // 1. Get real-time delivery status for a specific invoice
    @GetMapping("/track/{orderId}")
    public ResponseEntity<?> getTrackingDetails(@PathVariable("orderId") int orderId) {
        Orders order = orderRepository.findById(orderId)
                .orElseThrow(() -> new RuntimeException("Order not found"));
        return ResponseEntity.ok(order);
    }

    // 2. Mock Admin Endpoint: Transition delivery phases & assign tracking numbers
    @PutMapping("/update-status/{orderId}")
    public ResponseEntity<?> updateDeliveryStatus(
            @PathVariable("orderId") int orderId,
            @RequestBody Map<String, String> payload) {

        Orders order = orderRepository.findById(orderId)
                .orElseThrow(() -> new RuntimeException("Order not found"));

        try {
            // Read status string from JSON body payload and map to stable Enum values
            DeliveryStatus newStatus = DeliveryStatus.valueOf(payload.get("status").toUpperCase());
            order.setDelivery_status(newStatus);

            // Automatically generate a tracking number if status advances to SHIPPED
            if (newStatus == DeliveryStatus.SHIPPED && (order.getTracking_number() == null || order.getTracking_number().isEmpty())) {
                order.setTracking_number("BKSTR-" + UUID.randomUUID().toString().substring(0, 8).toUpperCase());
                order.setEstimated_delivery_date(LocalDateTime.now().plusDays(4)); // 4-day shipping target estimation
            }

            Orders updatedOrder = orderRepository.save(order);
            return ResponseEntity.ok(updatedOrder);

        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().body("Invalid status code value provided!");
        }
    }
}