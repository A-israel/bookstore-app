import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  String selectedTab = 'All';
  final List<String> tabs = ['All', 'Active', 'Delivered'];

  final List<Map<String, dynamic>> orders = [
    {
      'id': '#ORD-2031',
      'books': 'Atomic Habits × 1 · The Alchemist × 2',
      'total': '₦10,900',
      'status': 'Shipped',
      'date': 'Est. May 17',
      'tracking': 'In transit · Lagos Hub',
    },
    {
      'id': '#ORD-2028',
      'books': 'Fourth Wing × 1',
      'total': '₦5,500',
      'status': 'Delivered',
      'date': 'Delivered May 8',
      'tracking': null,
    },
    {
      'id': '#ORD-2025',
      'books': 'Dune × 1 · Sapiens × 1',
      'total': '₦7,800',
      'status': 'Delivered',
      'date': 'Delivered May 2',
      'tracking': null,
    },
    {
      'id': '#ORD-2034',
      'books': 'It Ends with Us × 2',
      'total': '₦7,000',
      'status': 'Pending',
      'date': 'Placed May 14',
      'tracking': 'Awaiting confirmation',
    },
  ];

  // filters orders based on selected tab
  List<Map<String, dynamic>> get filteredOrders {
    if (selectedTab == 'All') return orders;
    if (selectedTab == 'Active') {
      return orders
          .where((o) => o['status'] == 'Shipped' || o['status'] == 'Pending')
          .toList();
    }
    return orders.where((o) => o['status'] == 'Delivered').toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        backgroundColor: const Color(0xFF4F46E5),
        foregroundColor: Colors.white,
        title: Text('My Orders',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildTabs(),
          Expanded(
            child: filteredOrders.isEmpty
                ? _buildEmpty()
                : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: filteredOrders.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) =>
                  _buildOrderCard(filteredOrders[index]),
            ),
          ),
        ],
      ),
    );
  }

  // ── TABS (All / Active / Delivered) ──
  Widget _buildTabs() {
    return Container(
      color: Colors.white,
      child: Row(
        children: tabs.map((tab) {
          final isSelected = selectedTab == tab;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => selectedTab = tab),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: isSelected
                          ? const Color(0xFF4F46E5)
                          : Colors.transparent,
                      width: 2.5,
                    ),
                  ),
                ),
                child: Text(
                  tab,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: isSelected
                        ? FontWeight.w600
                        : FontWeight.normal,
                    color: isSelected
                        ? const Color(0xFF4F46E5)
                        : Colors.grey,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── ORDER CARD ──
  Widget _buildOrderCard(Map<String, dynamic> order) {
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
          // order id + status badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(order['id'],
                  style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold, fontSize: 14)),
              _buildStatusBadge(order['status']),
            ],
          ),
          const SizedBox(height: 8),

          // books in order
          Text(order['books'],
              style: GoogleFonts.poppins(
                  color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 8),

          // total price
          Text(order['total'],
              style: GoogleFonts.poppins(
                color: const Color(0xFF4F46E5),
                fontWeight: FontWeight.bold,
                fontSize: 15,
              )),
          const SizedBox(height: 8),

          const Divider(height: 1),
          const SizedBox(height: 8),

          // date + tracking info
          Row(
            children: [
              Icon(
                order['status'] == 'Delivered'
                    ? Icons.check_circle_outline
                    : order['status'] == 'Shipped'
                    ? Icons.local_shipping_outlined
                    : Icons.access_time,
                size: 14,
                color: _statusColor(order['status']),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  order['tracking'] != null
                      ? '${order['tracking']} · ${order['date']}'
                      : order['date'],
                  style: GoogleFonts.poppins(
                      fontSize: 11, color: Colors.grey),
                ),
              ),
              // track order button for active orders
              if (order['status'] == 'Shipped')
                GestureDetector(
                  onTap: () => _showTrackingSheet(context, order),
                  child: Text('Track Order',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: const Color(0xFF4F46E5),
                        fontWeight: FontWeight.w600,
                      )),
                ),
            ],
          ),
        ],
      ),
    );
  }

  // ── STATUS BADGE ──
  Widget _buildStatusBadge(String status) {
    Color bg;
    Color text;
    switch (status) {
      case 'Delivered':
        bg = const Color(0xFFD1FAE5);
        text = const Color(0xFF065F46);
        break;
      case 'Shipped':
        bg = const Color(0xFFDBEAFE);
        text = const Color(0xFF1E40AF);
        break;
      case 'Pending':
        bg = const Color(0xFFFEF3C7);
        text = const Color(0xFF92400E);
        break;
      default:
        bg = Colors.grey.shade100;
        text = Colors.grey;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(status,
          style: GoogleFonts.poppins(
              fontSize: 11, fontWeight: FontWeight.w600, color: text)),
    );
  }

  // ── STATUS COLOR ──
  Color _statusColor(String status) {
    switch (status) {
      case 'Delivered':
        return const Color(0xFF10B981);
      case 'Shipped':
        return const Color(0xFF3B82F6);
      default:
        return const Color(0xFFF59E0B);
    }
  }

  // ── TRACKING BOTTOM SHEET ──
  void _showTrackingSheet(BuildContext context, Map<String, dynamic> order) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tracking ${order['id']}',
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 20),
            _trackStep('Order Placed', true, Icons.check_circle),
            _trackStep('Processing', true, Icons.check_circle),
            _trackStep('Shipped · Lagos Hub', true, Icons.check_circle),
            _trackStep('Out for Delivery', false, Icons.radio_button_unchecked),
            _trackStep('Delivered', false, Icons.radio_button_unchecked),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // ── TRACKING STEP ──
  Widget _trackStep(String label, bool done, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(icon,
              color: done
                  ? const Color(0xFF4F46E5)
                  : Colors.grey.shade300,
              size: 22),
          const SizedBox(width: 12),
          Text(label,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: done ? Colors.black : Colors.grey,
                fontWeight:
                done ? FontWeight.w500 : FontWeight.normal,
              )),
        ],
      ),
    );
  }

  // ── EMPTY STATE ──
  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.receipt_long_outlined,
              size: 80, color: Colors.grey),
          const SizedBox(height: 16),
          Text('No orders yet',
              style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey)),
          const SizedBox(height: 8),
          Text('Your order history will appear here',
              style: GoogleFonts.poppins(color: Colors.grey)),
        ],
      ),
    );
  }
}