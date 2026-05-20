// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../cart/cart_screen.dart';
import '../orders/orders_screen.dart';
import '../profile/profile_screen.dart';
import '../wishlist/wishlist_screen.dart';
import '../reviews/reviews_screen.dart';
import '../../services/api_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentIndex = 0;
  String selectedGenre = 'All';
  bool isLoading = true;
  List<Map<String, dynamic>> books = [];
  List<String> genres = ['All'];

  @override
  void initState() {
    super.initState();
    _loadBooksData();
  }

  Future<void> _loadBooksData() async {
    final fetchedBooks = await ApiService.fetchBooks();

    // Extract unique genres directly from the database response payload
    final uniqueGenres = fetchedBooks
        .map((book) => book['genre']?.toString() ?? 'General')
        .where((genre) => genre.trim().isNotEmpty)
        .toSet()
        .toList();

    uniqueGenres.sort();

    setState(() {
      books = fetchedBooks;
      // 👈 FIXED: Safely builds the chip items ensuring 'All' sits cleanly at index 0
      genres = ['All', ...uniqueGenres];
      isLoading = false;
    });
  }

  // 👈 FIXED: Filtering strategy maps case-sensitivity cleanly
  List<Map<String, dynamic>> get filteredBooks {
    if (selectedGenre == 'All') return books;
    return books.where((b) => b['genre'] == selectedGenre).toList();
  }

  List<Map<String, dynamic>> get bestsellers =>
      books.where((b) => b['isBestseller'] == true).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFF4F46E5)))
                  : RefreshIndicator(
                onRefresh: _loadBooksData,
                color: const Color(0xFF4F46E5),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSearchBar(),
                      const SizedBox(height: 16),
                      _buildGenreChips(),
                      const SizedBox(height: 20),
                      _buildSectionTitle('🔥 Bestsellers'),
                      const SizedBox(height: 12),
                      _buildBestsellerRow(),
                      const SizedBox(height: 20),
                      _buildSectionTitle('📚 All Books'),
                      const SizedBox(height: 12),
                      _buildAllBooksGrid(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildTopBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: const Color(0xFF4F46E5),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Welcome back! 👋',
                  style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12)),
              Text('BookStore',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  )),
            ],
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.favorite_border, color: Colors.white),
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const WishlistScreen())),
          ),
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined, color: Colors.white),
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const CartScreen())),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          const Icon(Icons.search, color: Color(0xFF4F46E5)),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search books, authors...',
                hintStyle: GoogleFonts.poppins(color: Colors.grey, fontSize: 14),
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenreChips() {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: genres.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final genre = genres[index];
          final isSelected = selectedGenre == genre;
          return GestureDetector(
            onTap: () => setState(() => selectedGenre = genre),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF4F46E5) : Colors.white,
                borderRadius: BorderRadius.circular(99),
                border: Border.all(
                  color: isSelected ? const Color(0xFF4F46E5) : Colors.grey.shade300,
                ),
              ),
              child: Text(
                genre,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isSelected ? Colors.white : Colors.grey.shade700,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ── BESTSELLER ROW (COMPACT) ──
  Widget _buildBestsellerRow() {
    if (bestsellers.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Text('No bestsellers available', style: GoogleFonts.poppins(color: Colors.grey, fontSize: 13)),
        ),
      );
    }
    return SizedBox(
      height: 140,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: bestsellers.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final book = bestsellers[index];
          return GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ReviewsScreen(
                  bookTitle: book['title'],
                  bookAuthor: book['author'],
                  bookColor: book['color'],
                ),
              ),
            ),
            child: Container(
              width: 95,
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade100),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 70,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Image.network(
                        book['coverUrl'],
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: book['color'],
                          child: const Center(child: Icon(Icons.menu_book, color: Colors.white, size: 20)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(book['title'],
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 10)),
                  Text(book['author'],
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(color: Colors.grey, fontSize: 8)),
                  const SizedBox(height: 2),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(book['price'],
                          style: GoogleFonts.poppins(
                            color: const Color(0xFF4F46E5),
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          )),
                      Row(children: [
                        const Icon(Icons.star, color: Color(0xFFF59E0B), size: 10),
                        Text('${book['ratings']}', style: GoogleFonts.poppins(fontSize: 8)),
                      ]),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ── ALL BOOKS GRID (COMPACT 4 IN A ROW) ──
  Widget _buildAllBooksGrid() {
    final booksList = filteredBooks;
    if (booksList.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40),
          child: Text('No books in this genre yet', style: GoogleFonts.poppins(color: Colors.grey)),
        ),
      );
    }
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 0.62,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: booksList.length,
      itemBuilder: (context, index) {
        final book = booksList[index];
        return GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ReviewsScreen(
                bookTitle: book['title'],
                bookAuthor: book['author'],
                bookColor: book['color'],
              ),
            ),
          ),
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade100),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Image.network(
                        book['coverUrl'],
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: book['color'],
                          child: const Center(child: Icon(Icons.menu_book, color: Colors.white, size: 20)),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  book['title'],
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 10),
                ),
                Text(
                  book['author'],
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(color: Colors.grey, fontSize: 8),
                ),
                const SizedBox(height: 2),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      book['price'],
                      style: GoogleFonts.poppins(
                        color: const Color(0xFF4F46E5),
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                    // Inside your book card layout or details view row:
                    IconButton(
                      icon: const Icon(Icons.favorite_border, color: Colors.redAccent), // Or use conditional formatting for filled hearts
                      onPressed: () async {
                        // 1. Extract the secure book ID safely
                        final int bookId = book['bid'] ?? 0;
                        final String bookTitle = book['title'] ?? 'This book';

                        if (bookId == 0) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Error: Invalid Book ID ❌')),
                          );
                          return;
                        }

                        // 2. Call the API layer to save the item to your MySQL wishlist table
                        bool success = await ApiService.addToWishlist(bookId);

                        // 3. Notify the user with a clean floating snackbar
                        if (mounted && success) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('$bookTitle added to wishlist! ❤️', style: GoogleFonts.poppins(fontSize: 12)),
                              duration: const Duration(seconds: 2),
                              behavior: SnackBarBehavior.floating,
                              backgroundColor: Colors.green,
                            ),
                          );
                        } else if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Could not add to wishlist. Check connection or backend login context ❌'),
                              behavior: SnackBarBehavior.floating,
                              backgroundColor: Colors.redAccent,
                            ),
                          );
                        }
                      },
                    ),
                    GestureDetector(
                      onTap: () async {
                        // 👈 1. Pass the integer ID ('bid') instead of a string title
                        final int bookId = book['bid'] ?? 0;
                        final String bookTitle = book['title'] ?? 'Book';

                        if (bookId == 0) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Error: Invalid Book ID')),
                          );
                          return;
                        }

                        bool success = await ApiService.addToCart(bookId);

                        if (mounted && success) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              // 👈 2. Clean fallback ensures this interpolation never handles a 'Null' type
                              content: Text('$bookTitle added to cart! 🛒', style: GoogleFonts.poppins(fontSize: 12)),
                              duration: const Duration(seconds: 1),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        } else if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Failed to add item to backend cart ❌')),
                          );
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4F46E5),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(Icons.add, color: Colors.white, size: 10),
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold));
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (index) {
        setState(() => currentIndex = index);
        switch (index) {
          case 1:
            Navigator.push(context, MaterialPageRoute(builder: (_) => const CartScreen())).then((_) => _loadBooksData());
            break;
          case 2:
            Navigator.push(context, MaterialPageRoute(builder: (_) => const OrdersScreen()));
            break;
          case 3:
            Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
            break;
        }
      },
      selectedItemColor: const Color(0xFF4F46E5),
      unselectedItemColor: Colors.grey,
      type: BottomNavigationBarType.fixed,
      selectedLabelStyle: GoogleFonts.poppins(fontSize: 11),
      unselectedLabelStyle: GoogleFonts.poppins(fontSize: 11),
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.shopping_cart_outlined), label: 'Cart'),
        BottomNavigationBarItem(icon: Icon(Icons.receipt_long_outlined), label: 'Orders'),
        BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
      ],
    );
  }
}