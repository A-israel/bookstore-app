
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';


class ApiService {
  // Replace with your computer's IP if testing on a physical device
  static const String baseUrl = 'http://10.93.190.4:8080/api';

  // Fetch all books from Spring Boot
  static Future<List<Map<String, dynamic>>> fetchBooks() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/books/all'));
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
        Uri.parse('$baseUrl/books/search?query=${Uri.encodeComponent(query)}'),
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
      final response = await http.get(Uri.parse('$baseUrl/cart'));
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((item) {
          final bookData = item['books'];
          return {
            'id': item['id'],
            'title': bookData != null ? (bookData['title'] ?? 'Untitled') : 'Untitled',
            'author': bookData != null ? (bookData['author'] ?? 'Unknown') : 'Unknown',
            'price': bookData != null ? (bookData['price'] as num).toInt() : 0,
            'quantity': item['quantity'] ?? 1,
            'coverUrl': bookData != null ? bookData['coverUrl'] : '',
          };
        }).toList();
      }
       else {
        print("Server returned unexpected failure error status: ${response.statusCode}");
        throw Exception('Failed to load cart items');
      }
    } catch (e) {
      print("Error fetching cart: $e");
      return [];
    }
  }
  // Add a book to the backend cart
  static Future<bool> addToCart(int bookId) async {
    try {
      // This matches: @PostMapping("/add") public CartItems addToCart(@RequestParam("bookId") Integer bookId)
      final response = await http.post(
        Uri.parse('$baseUrl/cart/add?bookId=$bookId'),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print("Error adding to cart: $e");
      return false;
    }
  }

  // ── UPDATE QUANTITY ──
  static Future<bool> updateCartQuantity(int cartItemId, int newQuantity) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/cart/update?cartItemId=$cartItemId&quantity=$newQuantity'),
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
        Uri.parse('$baseUrl/cart/delete/$cartItemId'),
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
      final response = await http.get(Uri.parse('$baseUrl/wishlist'));

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
        Uri.parse('$baseUrl/wishlist/add?bookId=$bookId'),
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
        Uri.parse('$baseUrl/wishlist/remove/$bookId'),
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
      final response = await http.get(Uri.parse('$baseUrl/orders'));
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((order) {
          final List<dynamic> detailedItems = order['orderItems'] ?? [];
          return {
            'id': order['id'],
            'date': order['date'] != null ? order['date'].toString().split('T')[0] : 'Recent',
            'status': order['status'] ?? 'Processing',
            'amount': (order['total_price'] as num?)?.toInt() ?? 0,
            'count': detailedItems.fold(0, (sum, item) => sum + (item['quantity'] as int? ?? 1)),
            'tracking': order['trackingNumber'] ?? 'N/A',
          };
        }).toList();
      }
      return [];
    } catch (e) {
      print("Error fetching past history constraints: $e");
      return [];
    }
  }

  // ── TRIGGER CHECKOUT SUBMISSION ──
  static Future<bool> executeCheckout() async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/orders/checkout'),
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
        Uri.parse('$baseUrl/reviews/book/$bookId'),
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
        Uri.parse('$baseUrl/reviews/add'),
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
  // Fetch logged-in user profile details safely
  static Future<Map<String, dynamic>?> fetchUserProfile() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/auth/profile'),
        headers: await getAuthHeaders(), // 👈 Automatically bundles our fixed JWT token!
      );

      if (response.statusCode == 200) {
        return Map<String, dynamic>.from(json.decode(response.body));
      } else {
        print("Profile fetch failed with status: ${response.statusCode}");
      }
    } catch (e) {
      print("Exception reading profile connection schema: $e");
    }
    return null;
  }
}