package com.example.bookstore.controller;

import com.example.bookstore.tables.Reviews;
import com.example.bookstore.tables.Books;
import com.example.bookstore.tables.Users;
import com.example.bookstore.repositories.ReviewRepository;
import com.example.bookstore.repositories.BookRepository;
import com.example.bookstore.repositories.UserRepository;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/reviews")
@CrossOrigin("*")
public class ReviewController {

    private final ReviewRepository reviewRepository;
    private final BookRepository bookRepository;
    private final UserRepository userRepository;

    public ReviewController(ReviewRepository reviewRepository, BookRepository bookRepository, UserRepository userRepository) {
        this.reviewRepository = reviewRepository;
        this.bookRepository = bookRepository;
        this.userRepository = userRepository;
    }

    @GetMapping("/book/{bid}")
    public ResponseEntity<?> getBookReviews(@PathVariable("bid") Integer bid) {
        List<Reviews> reviews = reviewRepository.findByBooksBidOrderByCreatedAtDesc(bid);

        // Compute running rating math safely
        double totalRatingPoints = 0.0;
        for (Reviews r : reviews) {
            totalRatingPoints += r.getRating();
        }
        double averageRating = reviews.isEmpty() ? 0.0 : (totalRatingPoints / reviews.size());

        // Find parent book info to extract the image string paths
        Books book = bookRepository.findById(bid).orElse(null);

        // Create the composite JSON response structure
        Map<String, Object> dataResponse = new HashMap<>();
        dataResponse.put("reviewsCount", reviews.size());
        dataResponse.put("averageRating", Math.round(averageRating * 10.0) / 10.0);
        dataResponse.put("reviewsList", reviews);
        dataResponse.put("bookDetails", book); // Adds book properties including coverUrl to root layout object

        return ResponseEntity.ok(dataResponse);
    }

    // ── POST A NEW REVIEW ──
    @PostMapping("/add")
    public ResponseEntity<?> addReview(@RequestBody Map<String, Object> payload) {
        try {
            Integer bid = (Integer) payload.get("bid");
            Integer rating = (Integer) payload.get("rating");
            String comment = (String) payload.get("comments");

            String email = SecurityContextHolder.getContext().getAuthentication().getName();
            if (email == null || email.equals("anonymousUser")) {
                return ResponseEntity.status(401).body("Error: User authentication context is missing or invalid. Please re-login. ❌");
            }

            Users user = userRepository.findUsersByEmail(email);
            if (user == null) {
                return ResponseEntity.status(404).body("Error: No registered user found matching account email: " + email + " ❌");
            }
            Books book = bookRepository.findById(bid).orElseThrow(() -> new RuntimeException("Book details target missing"));

            Reviews review = new Reviews();
            review.setUsers(user);
            review.setBooks(book);
            review.setRating(rating);
            review.setComments(comment);

            return ResponseEntity.ok(reviewRepository.save(review));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body("Error posting entry: " + e.getMessage());
        }
    }

    @GetMapping("/user")
    public List<Reviews> getUserReviews() {

        int userId = 1;

        // Extracting user via the established email authentication strategy used in your working addReview endpoint
        String email = SecurityContextHolder.getContext().getAuthentication().getName();

        if (email != null && !email.equals("anonymousUser")) {
            Users user = userRepository.findUsersByEmail(email);
            if (user != null) {
                userId = user.getUid();
            }
        }

        return reviewRepository.findByUsersUid(userId);
    }
}