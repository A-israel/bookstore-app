package com.example.bookstore.tables;

import jakarta.persistence.*;

import java.time.LocalDateTime;

@Table(name = "reviews")
@Entity
public class Wishlist {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private int id;
    @ManyToOne
    @JoinColumn(name = "uid")
    private Users users;
    @ManyToOne
    @JoinColumn(name = "bid")
    private Books books;
    private LocalDateTime addedat;


}
