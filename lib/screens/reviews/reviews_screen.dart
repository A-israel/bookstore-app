import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class ReviewsScreen extends StatefulWidget {
  // receives book info from whichever card was tapped
  final String bookTitle;
  final String bookAuthor;
  final Color bookColor;

  const ReviewsScreen({
    super.key,
    required this.bookTitle,
    required this.bookAuthor,
    required this.bookColor,
  });

  @override
  State<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen> {
  final reviewController = TextEditingController();
  double userRating = 0;

  final List<Map<String, dynamic>> reviews = [
    {
      'name': 'Ada K.',
      'initials': 'AK',
      'rating': 5.0,
      'comment':
      'Absolutely life-changing book! Changed my perspective completely.',
      'date': 'May 10',
      'likes': 24,
    },
    {
      'name': 'Emeka T.',
      'initials': 'ET',
      'rating': 4.0,
      'comment':
      'Great read. Very practical advice I could apply immediately.',
      'date': 'May 6',
      'likes': 18,
    },
    {
      'name': 'Fatima B.',
      'initials': 'FB',
      'rating': 5.0,
      'comment':
      'One of the best books I have ever read. Highly recommended!',
      'date': 'April 28',
      'likes': 31,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        backgroundColor: const Color(0xFF4F46E5),
        foregroundColor: Colors.white,
        title: Text('Ratings & Reviews',
            style:
            GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // shows which book's reviews we're viewing
            _buildBookHeader(),
            const SizedBox(height: 16),
            _buildOverallRating(),
            const SizedBox(height: 20),
            _buildWriteReview(context),
            const SizedBox(height: 20),
            Text('All Reviews',
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            ...reviews.map((r) => _buildReviewCard(r)).toList(),
          ],
        ),
      ),
    );
  }

  // ── BOOK HEADER (shows which book you're reviewing) ──
  Widget _buildBookHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 68,
            decoration: BoxDecoration(
              color: widget.bookColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.menu_book,
                color: Colors.white, size: 28),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.bookTitle,
                  style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold, fontSize: 15)),
              Text(widget.bookAuthor,
                  style: GoogleFonts.poppins(
                      color: Colors.grey, fontSize: 13)),
            ],
          ),
        ],
      ),
    );
  }

  // ── OVERALL RATING SUMMARY ──
  Widget _buildOverallRating() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          Column(
            children: [
              Text('4.8',
                  style: GoogleFonts.poppins(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF4F46E5),
                  )),
              RatingBarIndicator(
                rating: 4.8,
                itemBuilder: (context, _) =>
                const Icon(Icons.star, color: Color(0xFFF59E0B)),
                itemCount: 5,
                itemSize: 18,
              ),
              const SizedBox(height: 4),
              Text('2,418 reviews',
                  style: GoogleFonts.poppins(
                      color: Colors.grey, fontSize: 12)),
            ],
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              children: [5, 4, 3, 2, 1].map((star) {
                final widths = [0.8, 0.6, 0.2, 0.1, 0.05];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Row(
                    children: [
                      Text('$star',
                          style: GoogleFonts.poppins(
                              fontSize: 11, color: Colors.grey)),
                      const SizedBox(width: 6),
                      const Icon(Icons.star,
                          color: Color(0xFFF59E0B), size: 12),
                      const SizedBox(width: 6),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: widths[5 - star],
                            backgroundColor: Colors.grey.shade200,
                            color: const Color(0xFF4F46E5),
                            minHeight: 6,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // ── WRITE A REVIEW ──
  Widget _buildWriteReview(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Write a Review',
              style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 12),
          Center(
            child: RatingBar.builder(
              initialRating: userRating,
              minRating: 1,
              itemBuilder: (context, _) =>
              const Icon(Icons.star, color: Color(0xFFF59E0B)),
              onRatingUpdate: (r) => setState(() => userRating = r),
              itemSize: 36,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: reviewController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Share your thoughts about this book...',
              hintStyle: GoogleFonts.poppins(
                  color: Colors.grey, fontSize: 13),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                    color: Color(0xFF4F46E5), width: 2),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // TODO: submit review to backend API
                reviewController.clear();
                setState(() => userRating = 0);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Review submitted! ⭐',
                        style: GoogleFonts.poppins()),
                    backgroundColor: const Color(0xFF4F46E5),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4F46E5),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: Text('Submit Review',
                  style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }

  // ── SINGLE REVIEW CARD ──
  Widget _buildReviewCard(Map<String, dynamic> review) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  color: Color(0xFF4F46E5),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(review['initials'],
                      style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(review['name'],
                        style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            fontSize: 13)),
                    Text(review['date'],
                        style: GoogleFonts.poppins(
                            color: Colors.grey, fontSize: 11)),
                  ],
                ),
              ),
              RatingBarIndicator(
                rating: review['rating'],
                itemBuilder: (context, _) =>
                const Icon(Icons.star, color: Color(0xFFF59E0B)),
                itemCount: 5,
                itemSize: 14,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(review['comment'],
              style: GoogleFonts.poppins(
                  fontSize: 13, color: Colors.grey.shade700)),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: () {
              setState(() => review['likes']++);
            },
            child: Row(
              children: [
                const Icon(Icons.thumb_up_outlined,
                    size: 16, color: Colors.grey),
                const SizedBox(width: 6),
                Text('${review['likes']} helpful',
                    style: GoogleFonts.poppins(
                        color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}