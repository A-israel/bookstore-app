import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/book_model.dart';

class ApiService {
  // Replace with your actual local IP address (from ipconfig)
  static const String baseUrl = "http://10.151.175.4:8080/api/books";

  Future<List<Book>> fetchBooks(int page, int size) async {
    final url = Uri.parse("$baseUrl/all?page=$page&size=$size");

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        // Spring Boot pagination wraps content inside a "content" array
        final Map<String, dynamic> decodedData = json.decode(response.body);
        final List<dynamic> bookList = decodedData['content'];

        return bookList.map((json) => Book.fromJson(json)).toList();
      } else {
        throw Exception("Failed to load books. Server returned status: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error connecting to backend: $e");
    }
  }
}