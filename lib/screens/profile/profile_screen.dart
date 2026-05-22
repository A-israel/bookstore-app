import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/api_service.dart'; // Ensure this matches your project directory path
import '../auth/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? _profileData;
  bool _isLoading = true;

  // Static menu items checklist config array
  static const menuItems = [
    {'icon': Icons.location_on_outlined, 'label': 'Shipping Address'},
    {'icon': Icons.credit_card_outlined, 'label': 'Payment Methods'},
    {'icon': Icons.notifications_outlined, 'label': 'Notifications'},
    {'icon': Icons.lock_outlined, 'label': 'Change Password'},
    {'icon': Icons.help_outline, 'label': 'Help & Support'},
  ];

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  // Executes asynchronous fetch over the network connection
  Future<void> _loadUserProfile() async {
    try {
      final data = await ApiService.fetchUserProfile();
      setState(() {
        _profileData = data;
        _isLoading = false;
      });
    } catch (e) {
      print("Error loading user profile context into UI: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6), //
      appBar: AppBar(
        backgroundColor: const Color(0xFF4F46E5), //
        foregroundColor: Colors.white, //
        title: Text('My Profile',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600)), //
        elevation: 0, //
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() => _isLoading = true);
              _loadUserProfile();
            },
          )
        ],
      ),
      body: _isLoading
          ? const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4F46E5)),
        ),
      )
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16), //
        child: Column(
          children: [
            _buildProfileCard(),
            const SizedBox(height: 16), //
            _buildStatsRow(),
            const SizedBox(height: 16), //
            _buildMenuOptions(),
            const SizedBox(height: 24),
            _buildLogoutButton(context),
          ],
        ),
      ),
    );
  }

  // ── 👤 CARD DISPLAYER (Populated with live backend parameters) ──
  Widget _buildProfileCard() {
    // Safely extract names and configurations
    final String fullName = _profileData?['fullname'] ?? 'User Profile';
    final String emailStr = _profileData?['email'] ?? 'No email bound';
    final String initialAvatar = fullName.trim().isEmpty ? 'U' : fullName.trim()[0].toUpperCase();

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 36,
              backgroundColor: const Color(0xFF4F46E5).withOpacity(0.1),
              child: Text(
                initialAvatar,
                style: GoogleFonts.poppins(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF4F46E5),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    fullName,
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    emailStr,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── 📊 METRIC COUNTER PLACEHOLDERS ──
  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(child: _buildStatCard('Orders', '12')),
        const SizedBox(width: 12),
        Expanded(child: _buildStatCard('Wishlist', '5')),
        const SizedBox(width: 12),
        Expanded(child: _buildStatCard('Reviews', '3')),
      ],
    );
  }

  Widget _buildStatCard(String label, String value) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          children: [
            Text(value,
                style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF4F46E5))),
            const SizedBox(height: 4),
            Text(label,
                style: GoogleFonts.poppins(
                    fontSize: 12, color: Colors.grey.shade500)),
          ],
        ),
      ),
    );
  }

  // ── ⚙️ SETTINGS SLOTS (Displaying Shipping/Payment dynamically) ──
  Widget _buildMenuOptions() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white,
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: menuItems.length,
        itemBuilder: (context, index) {
          final item = menuItems[index];
          String? subtext;

          // Dynamically embed database details inside descriptions
          if (item['label'] == 'Shipping Address') {
            subtext = _profileData?['shipping_address'] ?? 'No address registered';
          } else if (item['label'] == 'Payment Methods') {
            subtext = _profileData?['payment_method'] ?? 'No payment linked';
          }

          return Column(
            children: [
              ListTile(
                leading: Icon(item['icon'] as IconData, color: const Color(0xFF4F46E5)),
                title: Text(item['label'] as String,
                    style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500)),
                subtitle: subtext != null
                    ? Text(
                  subtext,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
                )
                    : null,
                trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                onTap: () {
                  // Ready for modal dialog or profile editing layouts later!
                },
              ),
              if (index < menuItems.length - 1)
                Divider(height: 1, indent: 56, color: Colors.grey.shade100), //
            ],
          );
        },
      ),
    );
  }

  // ── 🚪 LOGOUT UTILITY BUTTON ──
  Widget _buildLogoutButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52, //
      child: OutlinedButton.icon(
        icon: const Icon(Icons.logout, color: Colors.red), //
        label: Text('Logout',
            style: GoogleFonts.poppins(
                color: Colors.red, //
                fontWeight: FontWeight.w600, //
                fontSize: 15)), //
        onPressed: () {
          // Clears navigation stack and goes back to login
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const LoginScreen()), //
                (route) => false, //
          );
        },
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Colors.red), //
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)), //
        ),
      ),
    );
  }
}