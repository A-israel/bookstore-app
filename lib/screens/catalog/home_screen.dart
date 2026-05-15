import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../cart/cart_screen.dart';
import '../orders/orders_screen.dart';
import '../profile/profile_screen.dart';
import '../wishlist/wishlist_screen.dart';
import '../reviews/reviews_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentIndex = 0;
  String selectedGenre = 'All';

  final List<String> genres = [
    'All', 'Fiction', 'Sci-Fi', 'Romance', 'Self-Help', 'History'
  ];

  final List<Map<String, dynamic>> books = [
    {
      'title': 'Atomic Habits',
      'author': 'James Clear',
      'price': '₦4,500',
      'rating': 4.9,
      'genre': 'Self-Help',
      'color': Color(0xFF6366F1),
      'isBestseller': true,
    },
    {
      'title': 'The Alchemist',
      'author': 'Paulo Coelho',
      'price': '₦3,200',
      'rating': 4.7,
      'genre': 'Fiction',
      'color': Color(0xFFF59E0B),
      'isBestseller': true,
    },
    {
      'title': 'Fourth Wing',
      'author': 'Rebecca Yarros',
      'price': '₦5,000',
      'rating': 4.8,
      'genre': 'Romance',
      'color': Color(0xFF10B981),
      'isBestseller': false,
    },
    {
      'title': 'Dune',
      'author': 'Frank Herbert',
      'price': '₦4,000',
      'rating': 4.6,
      'genre': 'Sci-Fi',
      'color': Color(0xFFEF4444),
      'isBestseller': false,
    },
    {
      'title': 'Sapiens',
      'author': 'Yuval Noah Harari',
      'price': '₦3,800',
      'rating': 4.5,
      'genre': 'History',
      'color': Color(0xFF8B5CF6),
      'isBestseller': true,
    },
    {
      'title': 'It Ends with Us',
      'author': 'Colleen Hoover',
      'price': '₦3,500',
      'rating': 4.6,
      'genre': 'Romance',
      'color': Color(0xFFEC4899),
      'isBestseller': false,
    },
  ];

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
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
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
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // ── TOP BAR ──
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
                  style: GoogleFonts.poppins(
                      color: Colors.white70, fontSize: 12)),
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
            icon: const Icon(Icons.shopping_cart_outlined,
                color: Colors.white),
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const CartScreen())),
          ),
        ],
      ),
    );
  }

  // ── SEARCH BAR ──
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
                hintStyle: GoogleFonts.poppins(
                    color: Colors.grey, fontSize: 14),
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── GENRE CHIPS ──
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
              padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF4F46E5)
                    : Colors.white,
                borderRadius: BorderRadius.circular(99),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF4F46E5)
                      : Colors.grey.shade300,
                ),
              ),
              child: Text(
                genre,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isSelected
                      ? Colors.white
                      : Colors.grey.shade700,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ── BESTSELLER HORIZONTAL ROW ──
  // tapping any bestseller card opens the Reviews screen
  Widget _buildBestsellerRow() {
    return SizedBox(
      height: 200,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: bestsellers.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
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
              width: 140,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade100),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 90,
                    decoration: BoxDecoration(
                      color: book['color'],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: Icon(Icons.menu_book,
                          color: Colors.white, size: 36),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(book['title'],
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600, fontSize: 12)),
                  Text(book['author'],
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                          color: Colors.grey, fontSize: 10)),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(book['price'],
                          style: GoogleFonts.poppins(
                            color: const Color(0xFF4F46E5),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          )),
                      Row(children: [
                        const Icon(Icons.star,
                            color: Color(0xFFF59E0B), size: 12),
                        Text('${book['rating']}',
                            style: GoogleFonts.poppins(fontSize: 10)),
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

  // ── ALL BOOKS GRID ──
  // tapping any book card opens the Reviews screen
  Widget _buildAllBooksGrid() {
    final books = filteredBooks;
    if (books.isEmpty) {
      return Center(
        child: Text('No books in this genre yet',
            style: GoogleFonts.poppins(color: Colors.grey)),
      );
    }
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: books.length,
      itemBuilder: (context, index) {
        final book = books[index];
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
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade100),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: book['color'],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: Icon(Icons.menu_book,
                          color: Colors.white, size: 40),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(book['title'],
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600, fontSize: 12)),
                Text(book['author'],
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                        color: Colors.grey, fontSize: 10)),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(book['price'],
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF4F46E5),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        )),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4F46E5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.add,
                          color: Colors.white, size: 14),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── SECTION TITLE ──
  Widget _buildSectionTitle(String title) {
    return Text(title,
        style: GoogleFonts.poppins(
            fontSize: 16, fontWeight: FontWeight.bold));
  }

  // ── BOTTOM NAV BAR ──
  Widget _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (index) {
        setState(() => currentIndex = index);
        switch (index) {
          case 1:
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const CartScreen()));
            break;
          case 2:
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const OrdersScreen()));
            break;
          case 3:
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()));
            break;
        }
      },
      selectedItemColor: const Color(0xFF4F46E5),
      unselectedItemColor: Colors.grey,
      type: BottomNavigationBarType.fixed,
      selectedLabelStyle: GoogleFonts.poppins(fontSize: 11),
      unselectedLabelStyle: GoogleFonts.poppins(fontSize: 11),
      items: const [
        BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined), label: 'Home'),
        BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart_outlined), label: 'Cart'),
        BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_outlined), label: 'Orders'),
        BottomNavigationBarItem(
            icon: Icon(Icons.person_outline), label: 'Profile'),
      ],
    );
  }
}