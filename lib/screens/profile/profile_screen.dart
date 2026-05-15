import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../auth/login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  // menu items list — icon, label, color
  static const menuItems = [
    {'icon': Icons.location_on_outlined, 'label': 'Shipping Address'},
    {'icon': Icons.credit_card_outlined, 'label': 'Payment Methods'},
    {'icon': Icons.notifications_outlined, 'label': 'Notifications'},
    {'icon': Icons.lock_outlined, 'label': 'Change Password'},
    {'icon': Icons.help_outline, 'label': 'Help & Support'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        backgroundColor: const Color(0xFF4F46E5),
        foregroundColor: Colors.white,
        title: Text('My Profile',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildProfileCard(),
            const SizedBox(height: 16),
            _buildStatsRow(),
            const SizedBox(height: 16),
            _buildMenuSection(context),
            const SizedBox(height: 16),
            _buildLogoutButton(context),
          ],
        ),
      ),
    );
  }

  // ── PROFILE CARD (avatar + name + email) ──
  // shows user info at the top
  Widget _buildProfileCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          // avatar circle with initials
          Container(
            width: 60,
            height: 60,
            decoration: const BoxDecoration(
              color: Color(0xFF4F46E5),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text('JP',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  )),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('JAY P',
                    style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold, fontSize: 16)),
                Text('johnpaulochulor@gmail.com',
                    style: GoogleFonts.poppins(
                        color: Colors.grey, fontSize: 13)),
              ],
            ),
          ),
          // edit profile button
          IconButton(
            icon: const Icon(Icons.edit_outlined,
                color: Color(0xFF4F46E5)),
            onPressed: () {
              // TODO: navigate to edit profile screen
            },
          ),
        ],
      ),
    );
  }

  // ── STATS ROW (orders, wishlist, reviews count) ──
  Widget _buildStatsRow() {
    return Row(
      children: [
        _buildStat('12', 'Orders'),
        const SizedBox(width: 12),
        _buildStat('8', 'Wishlist'),
        const SizedBox(width: 12),
        _buildStat('5', 'Reviews'),
      ],
    );
  }

  Widget _buildStat(String number, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFEEF2FF),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(number,
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF4F46E5),
                )),
            Text(label,
                style: GoogleFonts.poppins(
                    fontSize: 12, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  // ── SETTINGS MENU ──
  Widget _buildMenuSection(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 12, 16, 4),
          ),
          ...List.generate(menuItems.length, (index) {
            final item = menuItems[index];
            return Column(
              children: [
                ListTile(
                  leading: Icon(
                    item['icon'] as IconData,
                    color: const Color(0xFF4F46E5),
                  ),
                  title: Text(item['label'] as String,
                      style: GoogleFonts.poppins(fontSize: 14)),
                  trailing: const Icon(Icons.chevron_right,
                      color: Colors.grey),
                  onTap: () {
                    // TODO: navigate to each settings screen
                  },
                ),
                if (index < menuItems.length - 1)
                  Divider(
                      height: 1,
                      indent: 56,
                      color: Colors.grey.shade100),
              ],
            );
          }),
        ],
      ),
    );
  }

  // ── LOGOUT BUTTON ──
  Widget _buildLogoutButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton.icon(
        icon: const Icon(Icons.logout, color: Colors.red),
        label: Text('Logout',
            style: GoogleFonts.poppins(
                color: Colors.red,
                fontWeight: FontWeight.w600,
                fontSize: 15)),
        onPressed: () {
          // clears navigation stack and goes back to login
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
          );
        },
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Colors.red),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}