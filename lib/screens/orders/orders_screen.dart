import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/api_service.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  List<Map<String, dynamic>> orders = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadOrdersData();
  }

  Future<void> _loadOrdersData() async {
    setState(() => isLoading = true);
    try {
      final history = await ApiService.fetchOrders();
      setState(() {
        orders = history;
        isLoading = false;
      });
    } catch (e) {
      print("UI parsing error loading orders: $e");
      setState(() {
        orders = [];
        isLoading = false;
      });
    }
  }

  String _formatCurrency(int amount) {
    return '₦${amount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}';
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'delivered':
        return Colors.green;
      case 'processing':
      case 'pending':
        return Colors.orange;
      case 'cancelled':
        return Colors.redAccent;
      default:
        return const Color(0xFF4F46E5);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        backgroundColor: const Color(0xFF4F46E5),
        foregroundColor: Colors.white,
        title: Text('My Orders 📦', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF4F46E5)))
          : orders.isEmpty
          ? _buildEmptyOrders()
          : RefreshIndicator(
        onRefresh: _loadOrdersData,
        color: const Color(0xFF4F46E5),
        child: ListView.builder(
          itemCount: orders.length,
          padding: const EdgeInsets.all(12),
          itemBuilder: (context, index) {
            final Map<String, dynamic> currentOrder = orders[index];
            return _buildOrderCard(currentOrder);
          },
        ),
      ),
    );
  }
  Widget _buildOrderCard(Map<String, dynamic> order) {
    final String orderId = (order['oid'] ?? order['id'] ?? order['orderId'] ?? 'N/A').toString();
    final String status = order['status'] ?? 'Pending';
    final String orderDate = order['createdAt'] ?? order['orderDate'] ?? order['date'] ?? 'Recent';

    // 1. Get the list of nested order items safely
    final List<dynamic> orderItemsList = order['orderItems'] ?? [];
    final int itemCount = orderItemsList.isNotEmpty ? orderItemsList.length : ((order['count'] ?? order['itemCount'] ?? 1) as int);

    // 2. 🟢 DYNAMIC SUM calculation fallback loop
    int itemAmount = 0;
    if (orderItemsList.isNotEmpty) {
      // If orderItems exist, manually sum up: priceAtPurchase * quantity
      for (var item in orderItemsList) {
        final book = item['books'] as Map<String, dynamic>?;
        final int qty = (item['quantity'] ?? 1) as int;
        final double snapshotPrice = ((item['priceAtPurchase'] ?? book?['price'] ?? 0.0) as num).toDouble();

        itemAmount += (snapshotPrice * qty).toInt();
      }
    } else {
      // Fallback if the backend does pass a top-level field somewhere
      itemAmount = ((order['amount'] ?? order['totalPrice'] ?? order['price'] ?? order['total'] ?? 0.0) as num).toInt();
    }

    // 3. Add delivery cost context if applicable (e.g., matching your 1,500 delivery rule)
    // If your backend amount already includes shipping, remove the '+ 1500' line below!
    if (itemAmount > 0) {
      itemAmount += 1500;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Order number and Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Order #$orderId', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 15)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStatusColor(status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status.toUpperCase(),
                  style: GoogleFonts.poppins(color: _getStatusColor(status), fontWeight: FontWeight.bold, fontSize: 11),
                ),
              )
            ],
          ),

          const SizedBox(height: 4),
          Text(orderDate, style: GoogleFonts.poppins(color: Colors.grey, fontSize: 11)),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(height: 1, color: Color(0xFFF3F4F6)),
          ),

          // Render line items summary block
          if (orderItemsList.isNotEmpty) ...[
            Text('Items Summary:', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey.shade700)),
            const SizedBox(height: 8),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: orderItemsList.length,
              itemBuilder: (context, itemIndex) {
                final item = orderItemsList[itemIndex] as Map<String, dynamic>;
                final book = item['books'] as Map<String, dynamic>?;

                final String bookTitle = book?['title'] ?? 'Unknown Title';
                final int qty = (item['quantity'] ?? 1) as int;
                final int purchasePrice = ((item['priceAtPurchase'] ?? book?['price'] ?? 0.0) as num).toInt();

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          '$bookTitle × $qty',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(fontSize: 13, color: Colors.black87),
                        ),
                      ),
                      Text(
                        _formatCurrency(purchasePrice * qty),
                        style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                );
              },
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Divider(height: 1, color: Color(0xFFF3F4F6)),
            ),
          ],

          // Footer: Total Summary section displays itemAmount dynamically calculated above
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total Summary (inc. Delivery)', style: GoogleFonts.poppins(color: Colors.grey, fontSize: 12)),
              Text(
                _formatCurrency(itemAmount),
                style: GoogleFonts.poppins(color: const Color(0xFF4F46E5), fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyOrders() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.receipt_long_outlined, size: 80, color: Colors.grey),
          const SizedBox(height: 16),
          Text('No orders yet', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.grey)),
          const SizedBox(height: 8),
          Text('Your purchased receipt history will appear here.', style: GoogleFonts.poppins(color: Colors.grey)),
        ],
      ),
    );
  }
}