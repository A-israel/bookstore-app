package com.example.bookstore.tables;

import jakarta.persistence.*;

import java.time.LocalDateTime;

@Table(name = "wishlist")
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

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public Users getUsers() {
        return users;
    }

    public void setUsers(Users users) {
        this.users = users;
    }

    public Books getBooks() {
        return books;
    }

    public void setBooks(Books books) {
        this.books = books;
    }

    public LocalDateTime getAddedat() {
        return addedat;
    }

    public void setAddedat(LocalDateTime addedat) {
        this.addedat = addedat;
    }
}
