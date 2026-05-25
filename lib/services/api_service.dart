
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';


class ApiService {
  // Replace with your computer's IP if testing on a physical device
  static const String baseUrl = 'http://10.0.2.2:8080';

  static const _storage = FlutterSecureStorage();

  static Future<List<Map<String, dynamic>>> fetchBooks() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/books/all'));
      print("Spring Boot Response Code: ${response.statusCode}");
      print("Spring Boot Response Body: ${response.body}");
      if (response.statusCode == 200) {

        List<dynamic> data = json.decode(response.body);
        return data.map((book) => {
          'bid': book['bid'] ?? book['id'] ?? 0,
          'title': book['title'] ?? 'Untitled Book',
          'author': book['author'],
          'price': '₦${book['price']}',
          'ratings': ((book['ratings'] ?? 0.0) as num).toDouble(),
          'genre': book['genre'],

          'color': Color(int.parse(book['colorHex'] ?? '0xFF4F46E5')),
          'coverUrl': book['coverUrl'] ?? 'https://images.unsplash.com/photo-1543002588-bfa74002ed7e?w=400',

          'isBestseller': book['isBestseller'] ?? book['bestseller'] ?? false,
        }).toList();
      } else {
        throw Exception('Failed to load books');
      }
    } catch (e) {
      print("Error fetching books: $e");
      return []; // Return empty list on failure gracefully
    }
  }

  // ── SEARCH INVENTORY ENDPOINT ──
  static Future<List<Map<String, dynamic>>> searchBooks(String query) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/books/search?query=${Uri.encodeComponent(query)}'),
      );

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((book) => {
          'id': book['id'],
          'title': book['title'] ?? 'Untitled',
          'author': book['author'] ?? 'Unknown',
          'price': (book['price'] as num?)?.toInt() ?? 0,
          'coverUrl': book['coverUrl'] ?? '',
        }).toList();
      }
      return [];
    } catch (e) {
      print("Error executing database search sequence: $e");
      return [];
    }
  }

  static Future<List<Map<String, dynamic>>> fetchCart() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/cart'),
        headers: await getAuthHeaders(), // 👈 CRITICAL: Passes token to secure cart endpoint
      );

      print("🛒 Fetch Cart Status: ${response.statusCode}");
      print("🛒 Fetch Cart Body: ${response.body}");

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data);
      }
    } catch (e) {
      print("Error fetching cart items data context: $e");
    }
    return [];
  }

  // ── 🟢 FIXED REWORKED ADD TO CART METHOD ──
  static Future<bool> addToCart(int bookId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/cart/add?bookId=$bookId'),
        headers: await getAuthHeaders(), // 👈 Passes unified headers
      );

      print("🛒 Add to Cart Status Code: ${response.statusCode}");
      print("🛒 Add to Cart Response Body: ${response.body}");

      // Returns true if backend accepts operation as 200 OK or 201 Created
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print("Error adding item upstream: $e");
      return false;
    }
  }
  // ── UPDATE QUANTITY ──
  static Future<bool> updateCartQuantity(int cartItemId, int newQuantity) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/api/cart/update?cartItemId=$cartItemId&quantity=$newQuantity'),
      );
      return response.statusCode == 200;
    } catch (e) {
      print("Error executing update: $e");
      return false;
    }
  }

  // ── REMOVE ENTRY ──
  static Future<bool> removeFromCart(int cartItemId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/api/cart/delete/$cartItemId'),
      );
      return response.statusCode == 200;
    } catch (e) {
      print("Error executing deletion: $e");
      return false;
    }
  }


  // ── FETCH WISHLIST ITEMS ──
  static Future<List<Map<String, dynamic>>> fetchWishlist() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/wishlist'));

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((item) {
          final bookData = item['books'];
          return {
            'id': item['id'],
            'bid': bookData != null ? bookData['bid'] : 0,
            'title': bookData != null ? (bookData['title'] ?? 'Unknown Title') : 'Unknown Title',
            'author': bookData != null ? (bookData['author'] ?? 'Unknown Author') : 'Unknown Author',
            'price': bookData != null ? '₦${bookData['price']}' : '₦0',
            'coverUrl': bookData != null ? (bookData['coverUrl'] ?? '') : '',
          };
        }).toList();
      } else {
        throw Exception('Failed to load wishlist');
      }
    } catch (e) {
      print("Error fetching wishlist: $e");
      return [];
    }
  }

  // ── TOGGLE ADD TO WISHLIST ──
  static Future<bool> addToWishlist(int bookId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/wishlist/add?bookId=$bookId'),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print("Error adding to wishlist: $e");
      return false;
    }
  }

  // ── REMOVE FROM WISHLIST ──
  static Future<bool> removeFromWishlist(int bookId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/api/wishlist/remove/$bookId'),
      );
      return response.statusCode == 200;
    } catch (e) {
      print("Error removing from wishlist: $e");
      return false;
    }
  }
  // History payload deserializer parsing multi-relational arrays
  static Future<List<Map<String, dynamic>>> fetchOrders() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/orders/user'),
        headers: await getAuthHeaders(),
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data);
      }
    } catch (e) {
      print("Error tracking user timeline: $e");
    }
    return [];
  }
  // ── TRIGGER CHECKOUT SUBMISSION ──
  static Future<bool> executeCheckout() async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/orders/checkout'),
        headers: await getAuthHeaders(),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      return false;
    }

  }
  static Future<Map<String, String>> getAuthHeaders() async {

    const storage = FlutterSecureStorage();

    // 2. Read the exact key name saved during login: 'jwt_token'
    final String? token = await storage.read(key: 'jwt_token');

    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    // 3. Append the bearer token if it exists
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    } else {
      print("⚠️ WARNING: No JWT token found in FlutterSecureStorage for key 'jwt_token'.");
    }

    return headers;
  }
  // Fetch detailed map stats containing nested items array list metrics
  static Future<dynamic> fetchReviews(int bookId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/reviews/book/$bookId'),
        headers: await getAuthHeaders(),
      );
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
    } catch (e) {
      print("Exception reading repository route: $e");
    }
    return null;
  }

  // Post star rating feedback metrics array blocks securely downstream
  static Future<bool> submitReview(int bookId, int rating, String comment) async {
    final headers = await getAuthHeaders();
    print("Sending Headers: $headers");
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/reviews/add'),
        headers: headers,
        body: json.encode({
          'bid': bookId, // Matches backend mapping expectation index key name
          'rating': rating,
          'comments': comment,
        }),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        print("FAILED STATUS: ${response.statusCode}");
        print("FAILED BODY: ${response.body}");
        return false;
      }
    } catch (e) {
      print("Error uploading layout model data: $e");
      return false;
    }
  }
  static Future<List<Map<String, dynamic>>> fetchUserReviews() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/reviews/user'),
        headers: await getAuthHeaders(),
      );
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data);
      }
      return [];
    } catch (e) {
      print("Error fetching user reviews: $e");
      return [];
    }
  }
  // Fetch logged-in user profile details safely
  static Future<Map<String, dynamic>?> fetchUserProfile() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/auth/profile'),
        headers: await getAuthHeaders(),
      );

      if (response.statusCode == 200) {
        return Map<String, dynamic>.from(json.decode(response.body));
      } else {
        print("Profile endpoint returned error status: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Network exception encountered fetching profile map: $e");
      return null;
    }
  }
  static Future<bool> updateProfileData({
    required String fullname,
    required String shippingAddress,
    required String paymentMethod,
    required String password,
  }) async {
    try {
      // 🟢 Gather authorization tokens ('Authorization': 'Bearer ...')
      final headers = await getAuthHeaders();

      // 🟢 CRITICAL FIX: Explicitly add Content-Type so Spring Boot parses it correctly
      headers['Content-Type'] = 'application/json';

      final response = await http.put(
        Uri.parse('$baseUrl/api/auth/profile/update'),
        headers: headers, // Pass the combined headers map
        body: json.encode({
          'fullname': fullname,
          'shipping_address': shippingAddress,
          'payment_method': paymentMethod,
          'password': password,
          'email': '',
        }),
      );

      print("Profile Update Status Code: ${response.statusCode}");
      print("Profile Update Response Body: ${response.body}");
      return response.statusCode == 200;
    } catch (e) {
      print("Error executing profile update: $e");
      return false;
    }
  }

  static Future<List<dynamic>> fetchAllUsers() async {
    try {
      final token = await _storage.read(key: 'jwt_token');

      // 🛑 TRIPLE CHECK THIS PATH:
      // It must exactly match what your AdminController @RequestMapping specifies!
      final response = await http.get(
        Uri.parse('$baseUrl/api/admin/users'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      print("JWT TOKEN: $token");
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        // This is throwing your "Exception: Server returned status: 403"
        throw Exception('Server returned status: ${response.statusCode}');
      }
    } catch (e) {
      print("Error getting master user registry lists: $e");
      return [];
    }
  }
  static Future<List<dynamic>> fetchAllOrders() async {
    try {
      final token = await _storage.read(key: 'jwt_token');

      final response = await http.get(
        Uri.parse('$baseUrl/api/admin/orders'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Server returned status: ${response.statusCode}');
      }
    } catch (e) {
      print("Error getting master purchase lines: $e");
      return [];
    }
  }
  // ➕ Add Book API Call
  static Future<bool> addBook(Map<String, dynamic> bookData) async {
    try {
      final token = await _storage.read(key: 'jwt_token');
      final response = await http.post(
        Uri.parse('$baseUrl/api/admin/books/add'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(bookData),
      );
      return response.statusCode == 201;
    } catch (e) {
      print("Network error adding book: $e");
      return false;
    }
  }

  // 📝 Update Book API Call
  static Future<bool> updateBook(dynamic bookId, Map<String, dynamic> bookData) async {
    try {
      final token = await _storage.read(key: 'jwt_token');
      final response = await http.put(
        Uri.parse('$baseUrl/api/admin/books/$bookId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(bookData),
      );
      return response.statusCode == 200;
    } catch (e) {
      print("Network error updating book: $e");
      return false;
    }
  }

  // ❌ Delete Book API Call
  static Future<bool> deleteBook(dynamic bookId) async {
    try {
      final token = await _storage.read(key: 'jwt_token');
      final response = await http.delete(
        Uri.parse('$baseUrl/api/admin/books/delete/$bookId'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      return response.statusCode == 200;
    } catch (e) {
      print("Network error deleting book: $e");
      return false;
    }
  }
}