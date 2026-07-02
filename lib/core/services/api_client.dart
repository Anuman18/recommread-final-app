import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter/foundation.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class ApiClient {
  // Use 10.0.2.2 for Android emulator, 127.0.0.1 for iOS simulator/macOS/web
  static final String baseUrl = kIsWeb
      ? 'http://127.0.0.1:8000'
      : (Platform.isAndroid ? 'http://10.0.2.2:8000' : 'http://127.0.0.1:8000');

  static const String _tokenKey = 'jwt_token';
  String? _token;
  
  // Singleton instance
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(_tokenKey);
  }

  Future<void> saveToken(String token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  Future<void> clearToken() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  bool get hasToken => _token != null;
  String? get token => _token;

  Map<String, String> _getHeaders() {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (_token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }
    return headers;
  }

  // Handle Response & Errors
  dynamic _handleResponse(http.Response response) {
    final code = response.statusCode;
    if (code >= 200 && code < 300) {
      if (response.body.isEmpty) return null;
      return json.decode(response.body);
    }
    
    // Auth failures
    if (code == 401 || code == 403) {
      // Clear token since session expired or unauthorized
      clearToken();
      throw ApiException('Session expired. Please log in again.', statusCode: code);
    }

    // Try extracting detail message from API error
    String errorMsg = 'An unexpected error occurred.';
    try {
      final decoded = json.decode(response.body);
      if (decoded is Map && decoded.containsKey('detail')) {
        final detail = decoded['detail'];
        if (detail is String) {
          errorMsg = detail;
        } else if (detail is List) {
          errorMsg = detail.map((e) => e is Map ? (e['msg'] ?? e.toString()) : e.toString()).join(', ');
        } else {
          errorMsg = detail.toString();
        }
      }
    } catch (_) {}

    throw ApiException(errorMsg, statusCode: code);
  }

  // GET Request
  Future<dynamic> get(String path) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl$path'),
        headers: _getHeaders(),
      );
      return _handleResponse(response);
    } on SocketException {
      throw ApiException('No internet connection.');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(e.toString());
    }
  }

  // POST Request
  Future<dynamic> post(String path, {Map<String, dynamic>? body}) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl$path'),
        headers: _getHeaders(),
        body: body != null ? json.encode(body) : null,
      );
      return _handleResponse(response);
    } on SocketException {
      throw ApiException('No internet connection.');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(e.toString());
    }
  }

  // PUT Request
  Future<dynamic> put(String path, {Map<String, dynamic>? body}) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl$path'),
        headers: _getHeaders(),
        body: body != null ? json.encode(body) : null,
      );
      return _handleResponse(response);
    } on SocketException {
      throw ApiException('No internet connection.');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(e.toString());
    }
  }

  // DELETE Request
  Future<dynamic> delete(String path) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl$path'),
        headers: _getHeaders(),
      );
      return _handleResponse(response);
    } on SocketException {
      throw ApiException('No internet connection.');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(e.toString());
    }
  }
}

final apiClient = ApiClient();
