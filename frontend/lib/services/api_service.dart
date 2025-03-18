import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  String? _token;
  // Use Render deployment URL
  final String baseUrl = 'https://whereismyksrtc.onrender.com';

  // Getter for token
  String? get token => _token;

  // Sign In
  Future<Map<String, dynamic>> signIn(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/signin'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        _token = json.decode(response.body)['token'];
        return json.decode(response.body);
      } else {
        final error = json.decode(response.body);
        throw error['message'] ?? 'Failed to sign in';
      }
    } catch (e) {
      if (e.toString().contains('Connection refused')) {
        throw 'Unable to connect to server. Please check your connection.';
      }
      throw e.toString();
    }
  }

  // Sign Up
  Future<Map<String, dynamic>> signUp(
      String fullName, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/signup'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'fullName': fullName,
          'email': email,
          'password': password,
        }),
      );

      final data = json.decode(response.body);
      if (response.statusCode == 201) {
        _token = data['token'];
        return data;
      } else {
        throw data['message'] ?? 'Sign up failed';
      }
    } catch (e) {
      if (e.toString().contains('Connection refused')) {
        throw 'Unable to connect to server. Please check your connection.';
      }
      throw e.toString();
    }
  }

  // Search Buses
  Future<List<Map<String, dynamic>>> searchBuses(
      String departurePoint, String arrivalPoint) async {
    try {
      if (_token == null) throw 'Not authenticated';

      final response = await http.get(
        Uri.parse('$baseUrl/api/bus/search').replace(
          queryParameters: {
            'departurePoint': departurePoint,
            'arrivalPoint': arrivalPoint,
          },
        ),
        headers: {
          'Authorization': 'Bearer $_token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        final error = json.decode(response.body);
        throw error['message'] ?? 'Failed to search buses';
      }
    } catch (e) {
      if (e.toString().contains('Connection refused')) {
        throw 'Unable to connect to server. Please check your connection.';
      }
      throw e.toString();
    }
  }

  // Get Bus Location
  Future<Map<String, dynamic>> getBusLocation(String busId) async {
    try {
      if (_token == null) throw 'Not authenticated';

      final response = await http.get(
        Uri.parse('$baseUrl/api/bus/location').replace(
          queryParameters: {'busId': busId},
        ),
        headers: {
          'Authorization': 'Bearer $_token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        final error = json.decode(response.body);
        throw error['message'] ?? 'Failed to get bus location';
      }
    } catch (e) {
      if (e.toString().contains('Connection refused')) {
        throw 'Unable to connect to server. Please check your connection.';
      }
      throw e.toString();
    }
  }
}
