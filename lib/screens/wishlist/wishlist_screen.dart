import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/api_service.dart';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  List<Map<String, dynamic>> wishlistItems = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadWishlistData();
  }

  Future<void> _loadWishlistData() async {
    setState(() => isLoading = true);
    final items = await ApiService.fetchWishlist();
    setState(() {
      wishlistItems = items;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        backgroundColor: const Color(0xFF4F46E5),
        foregroundColor: Colors.white,
        title: Text('My Wishlist ️', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF4F46E5)))
          : wishlistItems.isEmpty
          ? _buildEmptyWishlist()
          : RefreshIndicator(
        onRefresh: _loadWishlistData,
        color: const Color(0xFF4F46E5),
        child: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: wishlistItems.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) => _buildWishlistItem(index),
        ),
      ),
    );
  }

  Widget _buildWishlistItem(int index) {
    final item = wishlistItems[index];
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          // Book Cover
          Container(
            width: 50,
            height: 65,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                item['coverUrl'],
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: const Color(0xFF4F46E5),
                  child: const Icon(Icons.menu_book, color: Colors.white, size: 20),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Book Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item['title'], style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14)),
                Text(item['author'], style: GoogleFonts.poppins(color: Colors.grey, fontSize: 11)),
                const SizedBox(height: 4),
                Text(
                  item['price'],
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF4F46E5),
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),

          // Action Buttons: Add to Cart & Delete Item
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart_outlined, color: Color(0xFF4F46E5), size: 22),
                onPressed: () async {
                  bool success = await ApiService.addToCart(item['bid']);
                  if (mounted && success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${item['title']} moved to Cart! 🛒', style: GoogleFonts.poppins(fontSize: 12)),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 22),
                onPressed: () async {
                  bool success = await ApiService.removeFromWishlist(item['bid']);
                  if (success) _loadWishlistData();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyWishlist() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.favorite_border, size: 80, color: Colors.grey),
          const SizedBox(height: 16),
          Text('Your wishlist is empty',
              style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.grey)),
          const SizedBox(height: 8),
          Text('Tap the heart icon on books to save them here!', style: GoogleFonts.poppins(color: Colors.grey)),
        ],
      ),
    );
  }
}