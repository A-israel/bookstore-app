import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  // wishlist items — backend dev replaces with real API
  List<Map<String, dynamic>> wishlist = [
    {
      'title': 'Atomic Habits',
      'author': 'James Clear',
      'price': 4500,
      'color': Color(0xFF6366F1),
    },
    {
      'title': 'The Alchemist',
      'author': 'Paulo Coelho',
      'price': 3200,
      'color': Color(0xFFF59E0B),
    },
    {
      'title': 'Dune',
      'author': 'Frank Herbert',
      'price': 4000,
      'color': Color(0xFFEF4444),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        backgroundColor: const Color(0xFF4F46E5),
        foregroundColor: Colors.white,
        title: Text('My Wishlist',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        elevation: 0,
      ),
      body: wishlist.isEmpty
          ? _buildEmpty()
          : ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: wishlist.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) => _buildWishCard(index),
      ),
    );
  }

  Widget _buildWishCard(int index) {
    final item = wishlist[index];
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          // book cover
          Container(
            width: 56,
            height: 72,
            decoration: BoxDecoration(
              color: item['color'],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.menu_book,
                color: Colors.white, size: 28),
          ),
          const SizedBox(width: 12),

          // book info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item['title'],
                    style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600, fontSize: 13)),
                Text(item['author'],
                    style: GoogleFonts.poppins(
                        color: Colors.grey, fontSize: 11)),
                const SizedBox(height: 6),
                Text('₦${item['price']}',
                    style: GoogleFonts.poppins(
                      color: const Color(0xFF4F46E5),
                      fontWeight: FontWeight.bold,
                    )),
              ],
            ),
          ),

          // action buttons
          Column(
            children: [
              // add to cart
              ElevatedButton(
                onPressed: () {
                  // TODO: add to cart API
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Added to cart! 🛒',
                          style: GoogleFonts.poppins()),
                      backgroundColor: const Color(0xFF4F46E5),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4F46E5),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text('Add to Cart',
                    style: GoogleFonts.poppins(fontSize: 11)),
              ),
              const SizedBox(height: 6),
              // remove from wishlist
              OutlinedButton(
                onPressed: () {
                  setState(() => wishlist.removeAt(index));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Removed from wishlist',
                          style: GoogleFonts.poppins()),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text('Remove',
                    style: GoogleFonts.poppins(fontSize: 11)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.favorite_border, size: 80, color: Colors.grey),
          const SizedBox(height: 16),
          Text('Your wishlist is empty',
              style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey)),
          const SizedBox(height: 8),
          Text('Save books you love here',
              style: GoogleFonts.poppins(color: Colors.grey)),
        ],
      ),
    );
  }
}