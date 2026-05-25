import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../services/api_service.dart';
import '../admin/admin_screen.dart';
import '../auth/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? _profileData;
  int _orderCount = 0;
  int _cartCount = 0;
  int _reviewCount = 0;
  bool _isLoading = true;

  // Configuration matrix for the system settings rows
  static const menuItems = [
    {'icon': Icons.location_on_outlined, 'label': 'Shipping Address'},
    {'icon': Icons.credit_card_outlined, 'label': 'Payment Methods'},
    {'icon': Icons.lock_outlined, 'label': 'Update Profile'},
    {'icon': Icons.admin_panel_settings_outlined, 'label': 'Admin Panel'},
  ];

  @override
  void initState() {
    super.initState();
    _loadAllProfileMetrics();
  }

  // 🔄 Lifecycle Controller: Requests profile details and list parameters concurrently
  Future<void> _loadAllProfileMetrics() async {
    try {
      final profileData = await ApiService.fetchUserProfile();
      final ordersList = await ApiService.fetchOrders();
      final cartItemsList = await ApiService.fetchCart();
      final reviewsList = await ApiService.fetchUserReviews();

      setState(() {
        _profileData = profileData;
        _orderCount = ordersList.length;
        _cartCount = cartItemsList.length;
        _reviewCount = reviewsList.length;
        _isLoading = false;
      });
    } catch (e) {
      print("Exception parsing backend profile context: $e");
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        backgroundColor: const Color(0xFF4F46E5),
        foregroundColor: Colors.white,
        title: Text('My Profile', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() => _isLoading = true);
              _loadAllProfileMetrics();
            },
          )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF4F46E5)))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildProfileCard(),
            const SizedBox(height: 16),
            _buildStatsRow(),
            const SizedBox(height: 16),
            _buildMenuOptions(),
            const SizedBox(height: 24),
            _buildLogoutButton(context),
          ],
        ),
      ),
    );
  }

  // ── 👤 USER CARD DISPLAYER ──
  Widget _buildProfileCard() {
    final String fullName = _profileData?['fullname'] ?? _profileData?['fullName'] ?? _profileData?['name'] ?? 'User Profile';
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
                style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.bold, color: const Color(0xFF4F46E5)),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(fullName, style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                  const SizedBox(height: 4),
                  Text(emailStr, style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey.shade600)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── 📊 STATISTICS BADGES ──
  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(child: _buildStatCard('Orders', _orderCount.toString())),
        const SizedBox(width: 12),
        Expanded(child: _buildStatCard('Cart Items', _cartCount.toString())),
        const SizedBox(width: 12),
        Expanded(child: _buildStatCard('Reviews', _reviewCount.toString())),
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
            Text(value, style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: const Color(0xFF4F46E5))),
            const SizedBox(height: 4),
            Text(label, style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade500)),
          ],
        ),
      ),
    );
  }

  // ── ⚙️ SETTINGS SLOTS ──
  Widget _buildMenuOptions() {
    // 1. Define all your base menu slots
    final baseItems = [
      {'icon': Icons.location_on_outlined, 'label': 'Shipping Address'},
      {'icon': Icons.credit_card_outlined, 'label': 'Payment Methods'},
      {'icon': Icons.lock_outlined, 'label': 'Update Profile'},
    ];

    // 2. Extract the user details to verify permissions
    final String userRole = _profileData?['role']?.toString() ?? 'USER';
    final String userEmail = _profileData?['email']?.toString() ?? '';

    // 3. Create a clean dynamic list out of your base items
    List<Map<String, dynamic>> authorizedItems = List.from(baseItems);

    // 4. Only inject the Admin option if they pass the gatekeeper check!
    if (userRole.toUpperCase() == 'ADMIN' ||
        userRole.toUpperCase() == 'ROLE_ADMIN' ||
        userEmail == 'Saint@gmail.com') { // 👈 Bypasses via email until backend payload updates

      authorizedItems.add({
        'icon': Icons.admin_panel_settings_outlined,
        'label': 'Admin Panel'
      });
    }

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white,
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: authorizedItems.length, // 👈 Switch to your filtered list count
        itemBuilder: (context, index) {
          final item = authorizedItems[index]; // 👈 Read from filtered list
          String? subtext;

          if (item['label'] == 'Shipping Address') {
            subtext = _profileData?['shipping_address'] ?? _profileData?['shippingAddress'] ?? _profileData?['address'] ?? 'No address registered';
          } else if (item['label'] == 'Payment Methods') {
            subtext = _profileData?['payment_method'] ?? _profileData?['paymentMethod'] ?? 'Cash on Delivery';
          }

          return Column(
            children: [
              ListTile(
                leading: Icon(item['icon'] as IconData, color: const Color(0xFF4F46E5)),
                title: Text(item['label'] as String, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500)),
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
                  if (item['label'] == 'Update Profile') {
                    _showEditProfileSheet();
                  } else if (item['label'] == 'Shipping Address') {
                    _showShippingAddressSheet(subtext == 'No address registered' ? '' : subtext!);
                  } else if (item['label'] == 'Payment Methods') {
                    _showPaymentMethodSheet(subtext ?? 'Cash on Delivery');
                  } else if (item['label'] == 'Admin Panel') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AdminScreen()),
                    );
                  }
                },
              ),
              if (index < authorizedItems.length - 1) // 👈 Switch to filtered list length
                Divider(height: 1, indent: 56, color: Colors.grey.shade100),
            ],
          );
        },
      ),
    );
  }

  // ── 👤 SHEET 1: UPDATE NAME & PASSWORD ──
  void _showEditProfileSheet() {
    final currentName = _profileData?['fullname'] ?? _profileData?['fullName'] ?? '';
    final currentAddress = _profileData?['shipping_address'] ?? _profileData?['shippingAddress'] ?? '';
    final currentPayment = _profileData?['payment_method'] ?? _profileData?['paymentMethod'] ?? 'Cash on Delivery';

    final nameController = TextEditingController(text: currentName);
    final passwordController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          top: 24, left: 24, right: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Update Profile Details', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Full Name', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
              style: GoogleFonts.poppins(),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(labelText: 'New Password', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
              style: GoogleFonts.poppins(),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4F46E5), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                onPressed: () async {
                  if (passwordController.text.trim().isEmpty) {
                    _showSnackBar('Password is required to confirm profile updates', Colors.orange);
                    return;
                  }
                  Navigator.pop(context);
                  setState(() => _isLoading = true);

                  bool success = await ApiService.updateProfileData(
                    fullname: nameController.text,
                    shippingAddress: currentAddress,
                    paymentMethod: currentPayment,
                    password: passwordController.text,
                  );

                  if (success) {
                    _loadAllProfileMetrics();
                    _showSnackBar('Profile updated successfully! 🎉', Colors.green);
                  } else {
                    setState(() => _isLoading = false);
                    _showSnackBar('Failed to update profile ❌', Colors.redAccent);
                  }
                },
                child: Text('Save Updates', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
              ),
            )
          ],
        ),
      ),
    );
  }

  // ── 📍 SHEET 2: UPDATE SHIPPING ADDRESS ──
  void _showShippingAddressSheet(String initialAddress) {
    final currentName = _profileData?['fullname'] ?? _profileData?['fullName'] ?? '';
    final currentPayment = _profileData?['payment_method'] ?? _profileData?['paymentMethod'] ?? 'Cash on Delivery';

    final addressController = TextEditingController(text: initialAddress);
    final passwordConfirmationController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          top: 24, left: 24, right: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Update Shipping Address', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(
              controller: addressController,
              maxLines: 2,
              decoration: InputDecoration(labelText: 'Delivery Address', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
              style: GoogleFonts.poppins(),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: passwordConfirmationController,
              obscureText: true,
              decoration: InputDecoration(labelText: 'Confirm Password to Save', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
              style: GoogleFonts.poppins(),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4F46E5), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                onPressed: () async {
                  if (passwordConfirmationController.text.isEmpty) {
                    _showSnackBar('Please enter your password to authorize changes', Colors.orange);
                    return;
                  }
                  Navigator.pop(context);
                  setState(() => _isLoading = true);

                  bool success = await ApiService.updateProfileData(
                    fullname: currentName,
                    shippingAddress: addressController.text,
                    paymentMethod: currentPayment,
                    password: passwordConfirmationController.text,
                  );

                  if (success) {
                    _loadAllProfileMetrics();
                    _showSnackBar('Shipping address updated! 📍', Colors.green);
                  } else {
                    setState(() => _isLoading = false);
                    _showSnackBar('Failed to update address ❌', Colors.redAccent);
                  }
                },
                child: Text('Save Address', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
              ),
            )
          ],
        ),
      ),
    );
  }

  // ── 💳 SHEET 3: UPDATE PAYMENT METHODS (Radio Selection) ──
  void _showPaymentMethodSheet(String currentPayment) {
    // Standardize default fallbacks to match database field names
    String selectedMethod = (currentPayment == 'No payment linked' || currentPayment.isEmpty)
        ? 'Cash on Delivery'
        : currentPayment;

    final currentName = _profileData?['fullname'] ?? _profileData?['fullName'] ?? '';
    final currentAddress = _profileData?['shipping_address'] ?? _profileData?['shippingAddress'] ?? '';

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Select Payment Method', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              RadioListTile<String>(
                title: Text('Cash on Delivery', style: GoogleFonts.poppins(fontSize: 15)),
                value: 'Cash on Delivery',
                groupValue: selectedMethod,
                activeColor: const Color(0xFF4F46E5),
                onChanged: (value) {
                  setModalState(() => selectedMethod = value!);
                },
              ),
              RadioListTile<String>(
                title: Text('Bank Card', style: GoogleFonts.poppins(fontSize: 15)),
                value: 'Bank Card',
                groupValue: selectedMethod,
                activeColor: const Color(0xFF4F46E5),
                onChanged: (value) {
                  setModalState(() => selectedMethod = value!);
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4F46E5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () async {
                    Navigator.pop(context);
                    setState(() => _isLoading = true);

                    // 1. Send data payload down to your unified endpoint function
                    bool success = await ApiService.updateProfileData(
                      fullname: currentName,
                      shippingAddress: currentAddress,
                      paymentMethod: selectedMethod,
                      password: '', // Kept blank to skip password alterations
                    );

                    if (success) {
                      // 2. 🟢 FIX: Create a mutable copy of profile data and manually force updating keys locally
                      setState(() {
                        final mutableMap = Map<String, dynamic>.from(_profileData ?? {});
                        mutableMap['payment_method'] = selectedMethod;
                        mutableMap['paymentMethod'] = selectedMethod;
                        _profileData = mutableMap;
                      });

                      // 3. Refresh completely from database to ensure structural symmetry
                      await _loadAllProfileMetrics();
                      _showSnackBar('Payment preferences updated! 💳', Colors.green);
                    } else {
                      setState(() => _isLoading = false);
                      _showSnackBar('Failed to update payment preferences ❌', Colors.redAccent);
                    }
                  },
                  child: Text('Save Selection', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void _showSnackBar(String text, Color bg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text, style: GoogleFonts.poppins()), backgroundColor: bg, behavior: SnackBarBehavior.floating),
    );
  }

  // ── 🚪 SECURITY LOGOUT ──
  Widget _buildLogoutButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton.icon(
        icon: const Icon(Icons.logout, color: Colors.red),
        label: Text('Logout', style: GoogleFonts.poppins(color: Colors.red, fontWeight: FontWeight.w600, fontSize: 15)),
        onPressed: () async {
          try {
            const storage = FlutterSecureStorage();
            await storage.delete(key: 'jwt_token');
          } catch (e) {
            print("Secure storage cleaning issue: $e");
          }

          if (context.mounted) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
            );
          }
        },
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Colors.red),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}