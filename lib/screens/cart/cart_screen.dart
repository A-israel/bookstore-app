import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  // sample cart items — backend dev will replace with real API data
  List<Map<String, dynamic>> cartItems = [
    {
      'title': 'Atomic Habits',
      'author': 'James Clear',
      'price': 4500,
      'quantity': 1,
      'color': Color(0xFF6366F1),
    },
    {
      'title': 'The Alchemist',
      'author': 'Paulo Coelho',
      'price': 3200,
      'quantity': 2,
      'color': Color(0xFFF59E0B),
    },
    {
      'title': 'Fourth Wing',
      'author': 'Rebecca Yarros',
      'price': 5000,
      'quantity': 1,
      'color': Color(0xFF10B981),
    },
  ];

  // calculates total price of all items
  int get subtotal => cartItems.fold(
      0, (sum, item) => sum + (item['price'] * item['quantity'] as int));

  int get deliveryFee => 500;
  int get total => subtotal + deliveryFee;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        backgroundColor: const Color(0xFF4F46E5),
        foregroundColor: Colors.white,
        title: Text(
          'My Cart (${cartItems.length})',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        elevation: 0,
      ),
      body: cartItems.isEmpty
          ? _buildEmptyCart()
          : Column(
        children: [
          // scrollable list of cart items
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: cartItems.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) =>
                  _buildCartItem(index),
            ),
          ),
          // order summary at the bottom
          _buildOrderSummary(),
        ],
      ),
    );
  }

  // ── SINGLE CART ITEM CARD ──
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
          // book cover
          Container(
            width: 56,
            height: 72,
            decoration: BoxDecoration(
              color: item['color'],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.menu_book, color: Colors.white, size: 28),
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
                Text(
                  '₦${item['price'].toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}',
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF4F46E5),
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),

          // quantity controls + delete
          Column(
            children: [
              // delete button
              GestureDetector(
                onTap: () => setState(() => cartItems.removeAt(index)),
                child: const Icon(Icons.delete_outline,
                    color: Colors.red, size: 20),
              ),
              const SizedBox(height: 8),
              // qty - / number / +
              Row(
                children: [
                  _qtyButton(
                    icon: Icons.remove,
                    onTap: () {
                      setState(() {
                        if (item['quantity'] > 1) {
                          cartItems[index]['quantity']--;
                        } else {
                          cartItems.removeAt(index);
                        }
                      });
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text('${item['quantity']}',
                        style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold, fontSize: 14)),
                  ),
                  _qtyButton(
                    icon: Icons.add,
                    onTap: () => setState(
                            () => cartItems[index]['quantity']++),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── QTY BUTTON (- and +) ──
  Widget _qtyButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: const Color(0xFFEEF2FF),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(icon, size: 16, color: const Color(0xFF4F46E5)),
      ),
    );
  }

  // ── ORDER SUMMARY ──
  Widget _buildOrderSummary() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        children: [
          _summaryRow('Subtotal', '₦$subtotal'),
          const SizedBox(height: 8),
          _summaryRow('Delivery Fee', '₦$deliveryFee'),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(),
          ),
          _summaryRow('Total', '₦$total', isBold: true),
          const SizedBox(height: 16),
          // checkout button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () {
                // TODO: connect to backend checkout API
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Order placed successfully! 🎉',
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
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text('Proceed to Checkout',
                  style: GoogleFonts.poppins(
                      fontSize: 16, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }

  // ── SUMMARY ROW ──
  Widget _summaryRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: isBold ? Colors.black : Colors.grey,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            )),
        Text(value,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: isBold ? const Color(0xFF4F46E5) : Colors.black,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            )),
      ],
    );
  }

  // ── EMPTY CART STATE ──
  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.shopping_cart_outlined,
              size: 80, color: Colors.grey),
          const SizedBox(height: 16),
          Text('Your cart is empty',
              style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey)),
          const SizedBox(height: 8),
          Text('Add some books to get started!',
              style: GoogleFonts.poppins(color: Colors.grey)),
        ],
      ),
    );
  }
}