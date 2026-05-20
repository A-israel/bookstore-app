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
    final history = await ApiService.fetchOrders();
    setState(() {
      orders = history;
      isLoading = false;
    });
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
        child: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: orders.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) => _buildOrderCard(index),
        ),
      ),
    );
  }

  Widget _buildOrderCard(int index) {
    final order = orders[index];
    final Color statusColor = _getStatusColor(order['status']);

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Order #${order['id']}', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 15)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  order['status'].toUpperCase(),
                  style: GoogleFonts.poppins(color: statusColor, fontWeight: FontWeight.bold, fontSize: 10),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text('Tracking: ${order['tracking']}', style: GoogleFonts.poppins(color: Colors.grey, fontSize: 11)),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Date Placed', style: GoogleFonts.poppins(color: Colors.grey, fontSize: 11)),
                  const SizedBox(height: 2),
                  Text(order['date'], style: GoogleFonts.poppins(fontWeight: FontWeight.w500, fontSize: 13)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('${order['count']} item(s)', style: GoogleFonts.poppins(color: Colors.grey, fontSize: 11)),
                  const SizedBox(height: 2),
                  Text(
                    _formatCurrency(order['amount']),
                    style: GoogleFonts.poppins(color: const Color(0xFF4F46E5), fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ],
              )
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