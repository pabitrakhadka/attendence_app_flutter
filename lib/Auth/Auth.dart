import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final String apiUrl =
      "https://your-api-url"; // Replace with your actual API URL

  Future<Map<String, dynamic>> loginUser(
      String username, String password) async {
    final response = await http.post(
      Uri.parse('$apiUrl/login'),
      body: {'username': username, 'password': password},
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      // Assuming your API returns a token upon successful login
      String token = responseData['token'];

      // Save token locally using shared_preferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('token', token);

      return {'success': true, 'token': token};
    } else {
      return {'success': false, 'error': 'Invalid credentials'};
    }
  }

  Future<void> logoutUser() async {
    // Clear the locally stored token
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('token');
  }

  // Add other authentication-related functions as needed
}
