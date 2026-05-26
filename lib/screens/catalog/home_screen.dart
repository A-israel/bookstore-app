// lib/screens/home_screen.dart
import 'dart:async';
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
  List<Map<String, dynamic>> searchedBooks = [];
  List<String> genres = ['All'];

  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _loadBooksData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadBooksData() async {
    final fetchedBooks = await ApiService.fetchBooks();

    final uniqueGenres = fetchedBooks
        .map((book) => book['genre']?.toString() ?? 'General')
        .where((genre) => genre.trim().isNotEmpty)
        .toSet()
        .toList();

    uniqueGenres.sort();

    setState(() {
      books = fetchedBooks;
      searchedBooks = fetchedBooks;
      genres = ['All', ...uniqueGenres];
      isLoading = false;
    });
  }

  void _onSearchChanged(String query) {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();

    _debounceTimer = Timer(const Duration(milliseconds: 420), () async {
      if (query.trim().isEmpty) {
        setState(() => searchedBooks = books);
        return;
      }

      setState(() => isLoading = true);
      final searchResults = await ApiService.searchBooks(query);

      setState(() {
        searchedBooks = searchResults;
        isLoading = false;
      });
    });
  }

  List<Map<String, dynamic>> get filteredBooks {
    if (selectedGenre == 'All') return searchedBooks;
    return searchedBooks.where((b) => b['genre'] == selectedGenre).toList();
  }

  List<Map<String, dynamic>> get bestsellers {
    if (_searchController.text.isNotEmpty) return [];
    return books.where((b) => b['isBestseller'] == true).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator(color: Color(0xFF4F46E5)))
            : RefreshIndicator(
          onRefresh: _loadBooksData,
          color: const Color(0xFF4F46E5),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTopBar(),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSearchBar(),
                      const SizedBox(height: 16),
                      _buildSectionTitle('📚 Browse Genres'),
                      const SizedBox(height: 10),
                      _buildGenreChips(),
                      const SizedBox(height: 20),

                      if (bestsellers.isNotEmpty) ...[
                        _buildSectionTitle('🔥 Bestsellers'),
                        const SizedBox(height: 12),
                        _buildBestsellerRow(),
                        const SizedBox(height: 20),
                      ],

                      _buildSectionTitle(_searchController.text.isEmpty ? '✨ All Books' : '🔍 Search Results'),
                      const SizedBox(height: 12),
                      _buildAllBooksGrid(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildTopBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
              controller: _searchController,
              onChanged: _onSearchChanged,
              style: GoogleFonts.poppins(fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Search books, authors...',
                hintStyle: GoogleFonts.poppins(color: Colors.grey, fontSize: 14),
                border: InputBorder.none,
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear, color: Colors.grey, size: 18),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => searchedBooks = books);
                  },
                )
                    : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenreChips() {
    return SizedBox(
      height: 38,
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
              child: Center(
                child: Text(
                  genre,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isSelected ? Colors.white : Colors.grey.shade700,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBestsellerRow() {
    return SizedBox(
      height: 155,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: bestsellers.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final book = bestsellers[index];
          return GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ReviewsScreen(
                  bookId: book['bid'] ?? 0,
                  bookTitle: book['title'] ?? 'Untitled',
                  bookAuthor: book['author'] ?? 'Unknown Author',
                  bookColor: book['color'] ?? const Color(0xFF4F46E5),
                ),
              ),
            ),
            child: Container(
              width: 110,
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
                    height: 80,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: book['coverUrl'] != null && book['coverUrl'].toString().isNotEmpty
                          ? Image.network(
                        book['coverUrl'],
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: book['color'] ?? const Color(0xFF4F46E5),
                          child: const Center(child: Icon(Icons.menu_book, color: Colors.white, size: 20)),
                        ),
                      )
                          : Container(
                        color: book['color'] ?? const Color(0xFF4F46E5),
                        child: const Center(child: Icon(Icons.menu_book, color: Colors.white, size: 20)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(book['title'] ?? 'Untitled',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 10)),
                  Text(book['author'] ?? 'Unknown Author',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(color: Colors.grey, fontSize: 8)),
                  const SizedBox(height: 2),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        book['price'] != null ? '₦${book['price']}' : '₦0',
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF4F46E5),
                          fontWeight: FontWeight.bold,
                          fontSize: 9,
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Color(0xFFF59E0B), size: 10),
                          Text('${book['ratings'] ?? 0.0}', style: GoogleFonts.poppins(fontSize: 8)),
                        ],
                      ),
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

  Widget _buildAllBooksGrid() {
    final booksList = filteredBooks;
    if (booksList.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40),
          child: Text(
            _searchController.text.isEmpty ? 'No books in this genre yet' : 'No books match your search',
            style: GoogleFonts.poppins(color: Colors.grey),
          ),
        ),
      );
    }
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // Changed to 2 for optimal visibility layout dimensions on mobile emulators
        childAspectRatio: 0.72,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: booksList.length,
      itemBuilder: (context, index) {
        final book = booksList[index];
        return GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ReviewsScreen(
                bookId: book['bid'] ?? 0,
                bookTitle: book['title'] ?? 'Untitled',
                bookAuthor: book['author'] ?? 'Unknown Author',
                bookColor: book['color'] ?? const Color(0xFF4F46E5),
              ),
            ),
          ),
          child: Container(
            padding: const EdgeInsets.all(8),
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
                      child: book['coverUrl'] != null && book['coverUrl'].toString().isNotEmpty
                          ? Image.network(
                        book['coverUrl'],
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: book['color'] ?? const Color(0xFF4F46E5),
                          child: const Center(child: Icon(Icons.menu_book, color: Colors.white, size: 24)),
                        ),
                      )
                          : Container(
                        color: book['color'] ?? const Color(0xFF4F46E5),
                        child: const Center(child: Icon(Icons.menu_book, color: Colors.white, size: 24)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  book['title'] ?? 'Untitled',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 12),
                ),
                Text(
                  book['author'] ?? 'Unknown Author',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(color: Colors.grey, fontSize: 10),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        book['price'] != null ? '₦${book['price']}' : '₦0',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF4F46E5),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.favorite_border, color: Colors.redAccent, size: 18),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () async {
                        final int bookId = book['bid'] ?? 0;
                        final String bookTitle = book['title'] ?? 'This book';

                        if (bookId == 0) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Error: Invalid Book ID ❌')),
                          );
                          return;
                        }

                        bool success = await ApiService.addToWishlist(bookId);

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
                              content: Text('Could not add to wishlist. Check login context ❌'),
                              behavior: SnackBarBehavior.floating,
                              backgroundColor: Colors.redAccent,
                            ),
                          );
                        }
                      },
                    ),
                    const SizedBox(width: 6),
                    GestureDetector(
                      onTap: () async {
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
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4F46E5),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(Icons.add, color: Colors.white, size: 18),
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
    return Text(title, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF1F2937)));
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (index) {
        setState(() => currentIndex = index);

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;

          switch (index) {
            case 1:
              Navigator.push(context, MaterialPageRoute(builder: (_) => const CartScreen()))
                  .then((_) => _loadBooksData());
              break;
            case 2:
              Navigator.push(context, MaterialPageRoute(builder: (_) => const OrdersScreen()));
              break;
            case 3:
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()))
                  .then((_) {
                if (mounted) setState(() => currentIndex = 0);
              });
              break;
          }
        });
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