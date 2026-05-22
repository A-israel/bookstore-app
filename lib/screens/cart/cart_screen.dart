import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/api_service.dart';
import '../orders/orders_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  List<Map<String, dynamic>> cartItems = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCartData();
  }

  Future<void> _loadCartData() async {
    setState(() => isLoading = true);
    final fetchedItems = await ApiService.fetchCart();
    setState(() {
      cartItems = fetchedItems;
      isLoading = false;
    });
  }

  // Pure state mathematical properties
  int get subtotal => cartItems.fold(
      0, (sum, item) => sum + ((item['price'] as num).toInt() * (item['quantity'] as int)));

  int get delivery => subtotal > 0 ? 1500 : 0;
  int get total => subtotal + delivery;

  String _formatCurrency(int amount) {
    return '₦${amount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        backgroundColor: const Color(0xFF4F46E5),
        foregroundColor: Colors.white,
        title: Text('My Cart 🛒', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF4F46E5)))
          : cartItems.isEmpty
          ? _buildEmptyCart()
          : Column(
        children: [
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: cartItems.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) => _buildCartItem(index),
            ),
          ),
          _buildCheckoutSummary(),
        ],
      ),
    );
  }

  Widget _buildCartItem(int index) {
    final item = cartItems[index];
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          // Dynamic Cover Network Streamer
          Container(
            width: 56,
            height: 72,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                item['coverUrl'] ?? '',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: const Color(0xFF4F46E5),
                  child: const Icon(Icons.menu_book, color: Colors.white, size: 24),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Book Meta
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item['title'] ?? 'Unknown Title',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14)),
                Text(item['author'] ?? 'Unknown Author',
                    style: GoogleFonts.poppins(color: Colors.grey, fontSize: 11)),
                const SizedBox(height: 6),
                Text(
                  _formatCurrency((item['price'] as num).toInt()),
                  style: GoogleFonts.poppins(color: const Color(0xFF4F46E5), fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ],
            ),
          ),

          // Interactivity Counters
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.remove_circle_outline, color: Colors.grey, size: 20),
                onPressed: () async {
                  if (item['quantity'] > 1) {
                    bool success = await ApiService.updateCartQuantity(item['id'], item['quantity'] - 1);
                    if (success) _loadCartData();
                  } else {
                    bool success = await ApiService.removeFromCart(item['id']);
                    if (success) _loadCartData();
                  }
                },
              ),
              Text('${item['quantity']}', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
              IconButton(
                icon: const Icon(Icons.add_circle_outline, color: Color(0xFF4F46E5), size: 20),
                onPressed: () async {
                  bool success = await ApiService.updateCartQuantity(item['id'], item['quantity'] + 1);
                  if (success) _loadCartData();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCheckoutSummary() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -2))],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _summaryRow('Subtotal', _formatCurrency(subtotal)),
            const SizedBox(height: 8),
            _summaryRow('Delivery Fee', _formatCurrency(delivery)),
            const Divider(height: 24),
            _summaryRow('Total Amount', _formatCurrency(total), isBold: true),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () async {
                  if (cartItems.isEmpty) return;

                  setState(() => isLoading = true);
                  // Passing a delivery address matching your Spring Boot string model mapping
                  bool success = await ApiService.executeCheckout();

                  if (mounted) {
                    setState(() => isLoading = false);
                    if (success) {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const OrdersScreen()));

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Order placed successfully! 🚀 Check your history.', style: GoogleFonts.poppins()),
                          backgroundColor: Colors.green,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                      _loadCartData(); // Clears view locally since DB records migrated
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Checkout failed. Inspect backend data constraints ❌', style: GoogleFonts.poppins()),
                          backgroundColor: Colors.redAccent,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4F46E5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text('Proceed to Checkout 🚀',
                    style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.poppins(fontSize: 14, color: isBold ? Colors.black : Colors.grey, fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
        Text(value, style: GoogleFonts.poppins(fontSize: 14, color: isBold ? const Color(0xFF4F46E5) : Colors.black, fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
      ],
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey),
          const SizedBox(height: 16),
          Text('Your cart is empty', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.grey)),
          const SizedBox(height: 8),
          Text('Find some amazing books to read!', style: GoogleFonts.poppins(color: Colors.grey)),
        ],
      ),
    );
  }
}