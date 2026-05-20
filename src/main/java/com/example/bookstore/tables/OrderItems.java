package com.example.bookstore.tables;

import com.fasterxml.jackson.annotation.JsonBackReference;
import jakarta.persistence.*;

@Table(name = "order_items")
@Entity
public class OrderItems {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private int id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "order_id", nullable = false)
    @JsonBackReference // 👈 Stops child loop from rendering the parent order details back again
    private Orders order;

    @ManyToOne
    @JoinColumn(name = "bid", nullable = false)
    private Books books;

    private int quantity;
    private double priceAtPurchase; // Captures value history snapshot

    // Getters and Setters
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    public Orders getOrder() { return order; }
    public void setOrder(Orders order) { this.order = order; }
    public Books getBooks() { return books; }
    public void setBooks(Books books) { this.books = books; }
    public int getQuantity() { return quantity; }
    public void setQuantity(int quantity) { this.quantity = quantity; }
    public double getPriceAtPurchase() { return priceAtPurchase; }
    public void setPriceAtPurchase(double priceAtPurchase) { this.priceAtPurchase = priceAtPurchase; }
}