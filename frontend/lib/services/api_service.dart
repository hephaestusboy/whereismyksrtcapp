import 'dart:convert';
import 'package:flutter/foundation.dart' show kDebugMode;
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
        Uri.parse('$baseUrl/auth/login'),
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
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'fullName': fullName,
          'email': email,
          'password': password,
          'role': 1,
        }),
      );
      if (kDebugMode) {
        print(response);
      }
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
        Uri.parse('$baseUrl/bus/search?departurePoint=$departurePoint&arrivalPoint=$arrivalPoint'),
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
      final response = await http.get(
        Uri.parse('$baseUrl/location/latest/$busId'),
        headers: {
          'Authorization': 'Bearer $_token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw 'Failed to load bus location';
      }
    } catch (e) {
      throw 'Connection error: ${e.toString()}';
    }
  }

  //send current location
  Future<Map<String, dynamic>> updateBusLocation(String busId, double latitude, double longitude) async {
    try {
      if (_token == null) throw 'Not authenticated';

      final response = await http.post(
        Uri.parse('$baseUrl/location/update'),
        headers: {
          'Authorization': 'Bearer $_token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'busId': busId,
          'latitude': latitude,
          'longitude': longitude,
          'speed' : 45,
        }),
      );

      if (kDebugMode) {
        print('Update Bus Location Response: ${response.body}');
      }

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        final error = json.decode(response.body);
        throw error['message'] ?? 'Failed to update bus location';
      }
    } catch (e) {
      if (kDebugMode) {
        print('Update Bus Location Error: $e');
      }
      if (e.toString().contains('Connection refused')) {
        throw 'Unable to connect to server. Please check your connection.';
      }
      throw e.toString();
    }
  }
}
