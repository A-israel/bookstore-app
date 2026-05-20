
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';import 'dart:convert';


class ApiService {
  // Replace with your computer's IP if testing on a physical device
  static const String baseUrl = 'http://localhost:8080/api';

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
  static Future<bool> executeCheckout(String address) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/orders/checkout?shippingAddress=${Uri.encodeComponent(address)}'),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      return false;
    }

  }
}