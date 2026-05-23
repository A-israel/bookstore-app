import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../../services/api_service.dart';

class ReviewsScreen extends StatefulWidget {
  final int bookId;
  final String bookTitle;
  final String bookAuthor;
  final Color bookColor;

  const ReviewsScreen({
    super.key,
    required this.bookId,
    required this.bookTitle,
    required this.bookAuthor,
    required this.bookColor,
  });

  @override
  State<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen> {
  final reviewController = TextEditingController();
  double userRating = 5.0;

  bool isLoading = true;
  int totalReviewsCount = 0;
  double averageRatingCalculated = 0.0;
  List<dynamic> communityReviewsList = [];
  String? backendBookCoverUrl;

  @override
  void initState() {
    super.initState();
    _refreshScreenData();
  }

  @override
  void dispose() {
    reviewController.dispose();
    super.dispose();
  }

  Future<void> _refreshScreenData() async {
    setState(() => isLoading = true);
    final dynamic dataPayload = await ApiService.fetchReviews(widget.bookId);

    if (dataPayload != null && dataPayload is Map) {
      setState(() {
        totalReviewsCount = dataPayload['reviewsCount'] as int? ?? 0;
        averageRatingCalculated = (dataPayload['averageRating'] as num?)?.toDouble() ?? 0.0;
        communityReviewsList = dataPayload['reviewsList'] as List<dynamic>? ?? [];

        // Dynamic book meta collection mapping extraction
        if (dataPayload['bookDetails'] != null) {
          backendBookCoverUrl = dataPayload['bookDetails']['coverUrl'] as String?;
        }
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
    }
  }

  Future<void> _handleReviewSubmission() async {
    final commentText = reviewController.text.trim();
    if (commentText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please share your thoughts before hitting submit! ✍️')),
      );
      return;
    }

    setState(() => isLoading = true);
    bool success = await ApiService.submitReview(widget.bookId, userRating.toInt(), commentText);

    if (mounted) {
      if (success) {
        reviewController.clear();
        setState(() => userRating = 5.0);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Review submitted! ⭐', style: GoogleFonts.poppins()),
            backgroundColor: const Color(0xFF4F46E5),
            behavior: SnackBarBehavior.floating,
          ),
        );
        _refreshScreenData();
      } else {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to post review data block securely. Please try again later.'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        backgroundColor: const Color(0xFF4F46E5),
        foregroundColor: Colors.white,
        title: Text('Ratings & Reviews', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16)),
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF4F46E5)))
          : RefreshIndicator(
        onRefresh: _refreshScreenData,
        color: const Color(0xFF4F46E5),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBookHeader(),
              const SizedBox(height: 16),
              _buildOverallRating(),
              const SizedBox(height: 20),
              _buildWriteReview(),
              const SizedBox(height: 20),
              Text('All Reviews', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16, color: const Color(0xFF1F2937))),
              const SizedBox(height: 12),
              if (communityReviewsList.isEmpty)
                _buildEmptyPlaceholder()
              else
                ...communityReviewsList.map((r) => _buildReviewCard(r)).toList(),
            ],
          ),
        ),
      ),
    );
  }

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
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: 52,
              height: 68,
              color: widget.bookColor,
              child: (backendBookCoverUrl != null &&
                  backendBookCoverUrl!.trim().isNotEmpty &&
                  backendBookCoverUrl!.startsWith('http'))
                  ? Image.network(
                backendBookCoverUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const Center(
                  child: Icon(Icons.broken_image_outlined, color: Colors.white, size: 24),
                ),
              )
                  : const Center(
                child: Icon(Icons.menu_book, color: Colors.white, size: 24),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.bookTitle, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 15, color: const Color(0xFF1F2937))),
                Text(widget.bookAuthor, style: GoogleFonts.poppins(color: Colors.grey.shade500, fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }

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
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(averageRatingCalculated.toStringAsFixed(1),
                  style: GoogleFonts.poppins(fontSize: 44, fontWeight: FontWeight.bold, color: const Color(0xFF4F46E5))),
              RatingBarIndicator(
                rating: averageRatingCalculated,
                itemBuilder: (context, _) => const Icon(Icons.star_rounded, color: Color(0xFFF59E0B)),
                itemCount: 5,
                itemSize: 18,
              ),
              const SizedBox(height: 6),
              Text('$totalReviewsCount reviews', style: GoogleFonts.poppins(color: Colors.grey.shade400, fontSize: 11)),
            ],
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              children: [5, 4, 3, 2, 1].map((star) {
                int matchingCount = communityReviewsList.where((element) {
                  if (element is Map) {
                    return (element['rating'] as num? ?? 5).toInt() == star;
                  }
                  return false;
                }).length;

                double ratioDistribution = totalReviewsCount == 0 ? 0.0 : (matchingCount / totalReviewsCount);

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2.5),
                  child: Row(
                    children: [
                      Text('$star', style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey.shade600, fontWeight: FontWeight.w500)),
                      const SizedBox(width: 4),
                      const Icon(Icons.star_rounded, color: Color(0xFFF59E0B), size: 13),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: ratioDistribution,
                            backgroundColor: Colors.grey.shade100,
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

  Widget _buildWriteReview() {
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
          Text('Write a Review', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14, color: const Color(0xFF1F2937))),
          const SizedBox(height: 12),
          Center(
            child: RatingBar.builder(
              initialRating: userRating,
              minRating: 1,
              direction: Axis.horizontal,
              allowHalfRating: false,
              itemCount: 5,
              itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
              itemBuilder: (context, _) => const Icon(Icons.star_rounded, color: Color(0xFFF59E0B)),
              onRatingUpdate: (rating) => setState(() => userRating = rating),
              itemSize: 32,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: reviewController,
            maxLines: 3,
            style: GoogleFonts.poppins(fontSize: 13),
            decoration: InputDecoration(
              hintText: 'Share your thoughts about this book...',
              hintStyle: GoogleFonts.poppins(color: Colors.grey.shade400, fontSize: 13),
              contentPadding: const EdgeInsets.all(12),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF4F46E5), width: 1.5),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _handleReviewSubmission,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4F46E5),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text('Submit Review', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewCard(dynamic reviewElement) {
    if (reviewElement is! Map) return const SizedBox.shrink();

    // 1. Cleanly check for the user's name across nested objects or root-level keys
    String reviewerName = 'Anonymous';

    if (reviewElement['users'] != null) {
      // If it's a nested Hibernate object relationship
      final Map<dynamic, dynamic> userMap = reviewElement['users'];
      reviewerName = userMap['fullname'] ?? userMap['fullName'] ?? 'Anonymous';
    } else if (reviewElement['fullname'] != null || reviewElement['fullName'] != null) {

      reviewerName = reviewElement['fullname'] ?? reviewElement['fullName'] ?? 'Anonymous';
    }

    final String reviewCommentText = reviewElement['comments'] ?? reviewElement['comments'] ?? 'No comment provided';
    final String initialChar = reviewerName.trim().isEmpty ? 'A' : reviewerName.trim()[0].toUpperCase();
    final double ratingGiven = (reviewElement['rating'] as num? ?? 5.0).toDouble();

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
                decoration: const BoxDecoration(color: Color(0xFFE0E7FF), shape: BoxShape.circle),
                child: Center(
                  child: Text(initialChar, style: GoogleFonts.poppins(color: const Color(0xFF4F46E5), fontSize: 13, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(reviewerName, style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13, color: const Color(0xFF1F2937))),
                    Text('Verified Reader', style: GoogleFonts.poppins(color: Colors.grey.shade400, fontSize: 10)),
                  ],
                ),
              ),
              RatingBarIndicator(
                rating: ratingGiven,
                itemBuilder: (context, _) => const Icon(Icons.star_rounded, color: Color(0xFFF59E0B)),
                itemCount: 5,
                itemSize: 14,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(reviewCommentText, style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey.shade700, height: 1.45)),
        ],
      ),
    );
  }

  Widget _buildEmptyPlaceholder() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.rate_review_outlined, size: 40, color: Colors.grey.shade300),
            const SizedBox(height: 8),
            Text('No reviews posted yet', style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}