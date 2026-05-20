package com.example.bookstore.dto.request;

public class CartReq {
    private int books;
    private int quantity;

    public int getBookId() {
        return books;
    }

    public void setBookId(int bookId) {
        this.books = bookId;
    }

    public int getQuantity() {
        return quantity;
    }

    public void setQuantity(int quantity) {
        this.quantity = quantity;
    }
}