
import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {

  static const String baseUrl = 'http://10.0.2.2:8080';

  // LOGIN CONNECTION
  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return {'success': true, 'token': data['token']};
      } else {
        return {'success': false, 'message': response.body};
      }
    } catch (e) {
      return {'success': false, 'message': 'Connection error. Check your server connection.'};
    }
  }

  //  REGISTER CONNECTOIN
  static Future<Map<String, dynamic>> register({
    required String fullname,
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'fullname': fullname,
          'email': email,
          'password': password,
          'shipping_address': '', // Defaults expected by UserReq mapping
          'payment_method': '',
        }),
      );

      if (response.statusCode == 201) {
        return {'success': true, 'message': response.body};
      } else {
        return {'success': false, 'message': response.body};
      }
    } catch (e) {
      return {'success': false, 'message': 'Connection error. Check your server connection.'};
    }
  }
}