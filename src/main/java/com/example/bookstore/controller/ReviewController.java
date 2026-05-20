package com.example.bookstore.controller;

import com.example.bookstore.dto.request.ReviewReq;
import com.example.bookstore.tables.Reviews;
import com.example.bookstore.tables.Books;
import com.example.bookstore.tables.Users;
import com.example.bookstore.repositories.ReviewRepository;
import com.example.bookstore.repositories.BookRepository;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/reviews")
@CrossOrigin("*")
public class ReviewController {

    private final ReviewRepository reviewRepository;
    private final BookRepository bookRepository;

    public ReviewController(ReviewRepository reviewRepository, BookRepository bookRepository) {
        this.reviewRepository = reviewRepository;
        this.bookRepository = bookRepository;
    }

    // 1. Submit a brand new rating & comment
    @PostMapping("/add/{userId}")
    public ResponseEntity<?> addReview(@PathVariable("userId") int userId, @RequestBody ReviewReq req) {
        // Enforce basic validation rule boundary structures
        if (req.getRating() < 1 || req.getRating() > 5) {
            return ResponseEntity.badRequest().body("Rating metrics score must fall between 1 and 5 stars!");
        }

        if (reviewRepository.existsByUsersUidAndAndBooks_Bid(userId, req.getBookId())) {
            return ResponseEntity.badRequest().body("You have already submitted a review for this book!");
        }

        Books book = bookRepository.findById(req.getBookId())
                .orElseThrow(() -> new RuntimeException("Target Book node metadata index not found"));

        Reviews review = new Reviews();
        Users userRef = new Users();
        userRef.setUid(userId);

        review.setUsers(userRef);
        review.setBooks(book);
        review.setRating(req.getRating());
        review.setComments(req.getComment());
        review.setCreatedAt(LocalDateTime.now());

        Reviews savedReview = reviewRepository.save(review);
        return ResponseEntity.ok(savedReview);
    }

    // 2. Fetch all reviews and compile structural average calculations for item profile views
    @GetMapping("/book/{bookId}")
    public ResponseEntity<?> getBookReviews(@PathVariable("bookId") int bookId) {
        List<Reviews> reviews = reviewRepository.findByBooks_Bid(bookId);

        double totalRatingPoints = 0.0;
        for (Reviews r : reviews) {
            totalRatingPoints += r.getRating();
        }

        double averageRating = reviews.isEmpty() ? 0.0 : (totalRatingPoints / reviews.size());

        // Structure a map to present clean statistical aggregates alongside raw review text components
        Map<String, Object> statisticsResponse = new HashMap<>();
        statisticsResponse.put("reviewsCount", reviews.size());
        statisticsResponse.put("averageRating", Math.round(averageRating * 10.0) / 10.0); // Rounded to 1 decimal place
        statisticsResponse.put("reviewsList", reviews);

        return ResponseEntity.ok(statisticsResponse);
    }
}