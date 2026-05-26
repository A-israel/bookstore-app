import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/api_service.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Security & Loading State Check flags
  bool _isLoading = true;
  bool _isAuthorizedAdmin = false;

  // Runtime Dashboard Stats
  int _totalBooks = 0;
  int _totalUsers = 0;
  int _totalOrders = 0;
  double _totalRevenue = 0.0;

  Future<void> _refreshCatalog() async {
    final allBooks = await ApiService.fetchBooks();
    setState(() {
      books = List<Map<String, dynamic>>.from(allBooks);
      _totalBooks = books.length;
    });
  }

  List<Map<String, dynamic>> books = [];
  final List<Map<String, dynamic>> users = []; // Populated via dynamic account context fetch
  final List<Map<String, dynamic>> orders = []; // Populated via order mapping endpoints

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _verifyAccessAndLoadStats();
  }


  Future<void> _verifyAccessAndLoadStats() async {
    try {

      final profile = await ApiService.fetchUserProfile();

      String userRole = profile?['role']?.toString() ?? 'USER';
      String userEmail = profile?['email']?.toString() ?? '';

      print("ADMIN AUTH CHECK - Email: $userEmail, Role: $userRole");


      if (userRole.toUpperCase() == 'ADMIN' || userRole.toUpperCase() == 'ROLE_ADMIN') {
        print("🟢 Admin Access Granted via Email/Role validation!");

        final allBooks = await ApiService.fetchBooks();
        final allUsers = await ApiService.fetchAllUsers();
        final allOrders = await ApiService.fetchAllOrders();

        setState(() {
          _isAuthorizedAdmin = true;

          books = List<Map<String, dynamic>>.from(allBooks);
          _totalBooks = books.length;


          users.clear();
          users.addAll(List<Map<String, dynamic>>.from(allUsers));
          _totalUsers = users.length;
          orders.clear();
          orders.addAll(List<Map<String, dynamic>>.from(allOrders));
          _totalOrders = orders.length;

          _isLoading = false;
        });
      } else {
        print("🔴 Admin Access Denied for role: $userRole");
        setState(() {
          _isAuthorizedAdmin = false;
          _isLoading = false;
        });

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Access Denied: Admin role credentials required (Found: $userRole) 🛡️'),
                backgroundColor: Colors.redAccent,
              ),
            );
          }
        });
      }
    } catch (e) {
      print("Security interception error checking admin context: $e");
      setState(() {
        _isAuthorizedAdmin = false;
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF3F4F6),
        body: Center(child: CircularProgressIndicator(color: Color(0xFF4F46E5))),
      );
    }

    if (!_isAuthorizedAdmin) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.gpp_bad_outlined, color: Colors.redAccent, size: 80),
              const SizedBox(height: 24),
              Text(
                'Access Denied',
                style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const SizedBox(height: 12),
              Text(
                'Your account does not possess the administrator privileges required to view dashboard diagnostics data.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4F46E5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: Text('Go Back', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        backgroundColor: const Color(0xFF4F46E5),
        foregroundColor: Colors.white,
        title: Text('Admin Panel 🛡️', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          tabs: const [
            Tab(text: 'Catalog'),
            Tab(text: 'Users'),
            Tab(text: 'Orders'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildBooksTab(),
          _buildUsersTab(),
          _buildOrdersTab(),
        ],
      ),
    );
  }

  Widget _buildBooksTab() {
    return Column(
      children: [
        _buildStatsBar([
          {'label': 'Total Books', 'value': '$_totalBooks'},
          {'label': 'Total Users', 'value': '$_totalUsers'}, // ✅ Live summary user numbers
          {'label': 'Bestsellers', 'value': '${books.where((b) => b['isBestseller'] == true).length}'},
        ]),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _showAddBookSheet(context),
              icon: const Icon(Icons.add),
              label: Text('Add New Book', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4F46E5),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: books.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) => _buildBookCard(books[index], index),
          ),
        ),
      ],
    );
  }

  Widget _buildBookCard(Map<String, dynamic> book, int index) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 64,
            decoration: BoxDecoration(
              color: book['color'] ?? const Color(0xFF4F46E5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.menu_book, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(book['title'], style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13)),
                Text(book['author'] ?? 'Unknown Author', style: GoogleFonts.poppins(color: Colors.grey, fontSize: 11)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text('${book['price']}', style: GoogleFonts.poppins(color: const Color(0xFF4F46E5), fontWeight: FontWeight.bold, fontSize: 12)),
                    const SizedBox(width: 8),
                    if (book['isBestseller'] == true)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: Colors.amber.shade50, borderRadius: BorderRadius.circular(99)),
                        child: Text('Bestseller', style: GoogleFonts.poppins(fontSize: 10, color: Colors.amber.shade800, fontWeight: FontWeight.bold)),
                      ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            children: [
              IconButton(
                icon: const Icon(Icons.edit_outlined, color: Color(0xFF4F46E5), size: 20),
                onPressed: () => _showEditBookSheet(context, book, index),
              ),
              IconButton(
                icon: Icon(Icons.delete_outline, color: Colors.red.shade400, size: 20),
                onPressed: () => _confirmDelete(
                  context,
                  title: 'Delete "${book['title']}"?',
                  onConfirm: () async {

                    final dynamic bookId = book['bid'] ?? book['id'];
                    bool success = await ApiService.deleteBook(bookId);
                    if (success) {
                      _refreshCatalog();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Book deleted successfully! 🗑️'), backgroundColor: Colors.green),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Failed to delete book. Status 403/500'), backgroundColor: Colors.redAccent),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUsersTab() {
    return users.isEmpty
        ? Center(
      child: Text(
        'No users registered yet 👥',
        style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey),
      ),
    )
        : ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: users.length,
      itemBuilder: (context, index) {
        final client = users[index];

        final String name = client['fullname'] ?? client['fullName'] ?? 'Unknown User';
        final String email = client['email'] ?? 'No email bound';
        final String role = client['role'] ?? client['userRole'] ?? 'USER';
        final String address = client['shipping_address'] ?? client['address'] ?? 'No address registered';

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.shade100),
          ),
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: Row(
              children: [

                CircleAvatar(
                  backgroundColor: const Color(0xFF4F46E5).withOpacity(0.1),
                  child: Text(
                    name.isNotEmpty ? name[0].toUpperCase() : '👤',
                    style: GoogleFonts.poppins(color: const Color(0xFF4F46E5), fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 14),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              name,
                              style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),

                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: role.toUpperCase() == 'ADMIN' || role.toUpperCase() == 'ROLE_ADMIN'
                                  ? Colors.amber.shade50
                                  : Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              role.toUpperCase().replaceAll('ROLE_', ''),
                              style: GoogleFonts.poppins(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: role.toUpperCase() == 'ADMIN' || role.toUpperCase() == 'ROLE_ADMIN'
                                      ? Colors.amber.shade800
                                      : Colors.blue.shade800
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        email,
                        style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.location_on, size: 12, color: Colors.grey),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              address,
                              style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey.shade600),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildOrdersTab() {
    return orders.isEmpty
        ? Center(
      child: Text(
        'No checkout orders registered yet 📦',
        style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey),
      ),
    )
        : ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final package = orders[index];

        final String orderId = package['id']?.toString() ?? '#0000';
        final String tracking = package['tracking_number'] ?? 'No Tracking Assigned';
        final String total = package['total_price']?.toString() ?? '0.00';
        final String status = package['status'] ?? 'PENDING';
        final String address = package['shipping_address'] ?? 'No Address Provided';
        final String date = package['date'] ?? '';

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.shade100),
          ),
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Order ID: $orderId',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: const Color(0xFF4F46E5)),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: status.toUpperCase() == 'DELIVERED' || status.toUpperCase() == 'COMPLETED'
                            ? Colors.green.shade50
                            : Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        status.toUpperCase(),
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: status.toUpperCase() == 'DELIVERED' || status.toUpperCase() == 'COMPLETED'
                              ? Colors.green.shade700
                              : Colors.orange.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
                const Divider(height: 20),
                Text('Tracking: $tracking', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        address,
                        style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Date: $date', style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey)),
                    Text(
                      '₦$total',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87),
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
  Widget _buildStatsBar(List<Map<String, dynamic>> stats) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: stats.map((s) => Expanded(
          child: Column(
            children: [
              Text(s['value'], style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: const Color(0xFF4F46E5))),
              Text(s['label'], style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey)),
            ],
          ),
        )).toList(),
      ),
    );
  }

  void _showAddBookSheet(BuildContext context) {
    final titleController = TextEditingController();
    final authorController = TextEditingController();
    final priceController = TextEditingController();
    final descController = TextEditingController();
    final genreController = TextEditingController();
    bool isBestseller = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, top: 20, left: 20, right: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Add New Book 📚', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
              TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Title')),
              TextField(controller: authorController, decoration: const InputDecoration(labelText: 'Author')),

              TextField(
                controller: priceController,
                decoration: const InputDecoration(labelText: 'Price', hintText: 'e.g. 3500.00'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),

              TextField(controller: descController, decoration: const InputDecoration(labelText: 'Description')),
              TextField(controller: genreController, decoration: const InputDecoration(labelText: 'Genre')),
              CheckboxListTile(
                title: Text('Is Bestseller?', style: GoogleFonts.poppins(fontSize: 14)),
                value: isBestseller,
                onChanged: (val) => setModalState(() => isBestseller = val ?? false),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4F46E5), minimumSize: const Size(double.infinity, 45)),
                onPressed: () async {

                  String priceText = priceController.text
                      .replaceAll(RegExp(r'[^\d.]'), '')
                      .trim();

                  double finalPrice = double.tryParse(priceText) ?? 0.0;

                  final data = {
                    "title": titleController.text,
                    "author": authorController.text,
                    "price": finalPrice,
                    "description": descController.text,
                    "genre": genreController.text,
                    "bestseller": isBestseller,
                    "stock": 10,
                    "coverUrl": ""
                  };

                  bool success = await ApiService.addBook(data);
                  if (success) {
                    Navigator.pop(context);
                    _refreshCatalog();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('New book added to system catalog! 📚🎉'), backgroundColor: Colors.green),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Failed to save new book payload.'), backgroundColor: Colors.redAccent),
                    );
                  }
                },
                child: Text('Save Book', style: GoogleFonts.poppins(color: Colors.white)),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditBookSheet(BuildContext context, Map<String, dynamic> book, int index) {

    final titleController = TextEditingController(text: book['title']);
    final authorController = TextEditingController(text: book['author']);
    final priceController = TextEditingController(text: book['price']?.toString().trim());
    final descController = TextEditingController(text: book['description']);
    final genreController = TextEditingController(text: book['genre']);
    bool isBestseller = book['isBestseller'] ?? false;
    final dynamic bookId = book['bid'] ?? book['id'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, top: 20, left: 20, right: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Edit Book Details 📝', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
              TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Title')),
              TextField(controller: authorController, decoration: const InputDecoration(labelText: 'Author')),

              TextField(
                controller: priceController,
                decoration: const InputDecoration(labelText: 'Price', hintText: 'e.g. 4500.00'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),

              TextField(controller: descController, decoration: const InputDecoration(labelText: 'Description')),
              TextField(controller: genreController, decoration: const InputDecoration(labelText: 'Genre')),
              CheckboxListTile(
                title: Text('Is Bestseller?', style: GoogleFonts.poppins(fontSize: 14)),
                value: isBestseller,
                onChanged: (val) => setModalState(() => isBestseller = val ?? false),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4F46E5), minimumSize: const Size(double.infinity, 45)),
                onPressed: () async {

                  String priceText = priceController.text
                      .replaceAll(RegExp(r'[^\d.]'), '')
                      .trim();

                  double finalPrice = double.tryParse(priceText) ?? (book['price'] as double? ?? 0.0);

                  final data = {
                    "title": titleController.text,
                    "author": authorController.text,
                    "price": finalPrice,
                    "description": descController.text,
                    "genre": genreController.text,
                    "bestseller": isBestseller,
                    "stock": book['stock'] ?? 10,
                    "coverUrl": book['coverUrl'] ?? ""
                  };

                  bool success = await ApiService.updateBook(bookId, data);
                  if (success) {
                    Navigator.pop(context);
                    _refreshCatalog();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Book properties saved cleanly! 💾'), backgroundColor: Colors.green),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Could not sync details updates.'), backgroundColor: Colors.redAccent),
                    );
                  }
                },
                child: Text('Update Details', style: GoogleFonts.poppins(color: Colors.white)),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
  void _confirmDelete(BuildContext context, {required String title, required VoidCallback onConfirm}) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Confirm Delete', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: Text(title, style: GoogleFonts.poppins()),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel', style: GoogleFonts.poppins(color: Colors.grey))),
          ElevatedButton(
            onPressed: () { Navigator.pop(context); onConfirm(); },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Delete', style: GoogleFonts.poppins(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}