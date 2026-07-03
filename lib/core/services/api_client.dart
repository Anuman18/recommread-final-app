import 'dart:async';
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
  static final String baseUrl = kIsWeb
      ? 'http://127.0.0.1:8000'
      : (Platform.isAndroid ? 'http://10.0.2.2:8000' : 'http://127.0.0.1:8000');

  static const Duration _timeout = Duration(seconds: 30);
  static const String _tokenKey = 'jwt_token';
  String? _token;
  VoidCallback? onUnauthorized;

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

  String _messageForStatus(int code, String fallback) {
    switch (code) {
      case 400:
        return fallback.isNotEmpty ? fallback : 'Invalid request.';
      case 401:
        return 'Session expired. Please log in again.';
      case 403:
        return fallback.isNotEmpty ? fallback : 'You do not have permission to perform this action.';
      case 404:
        return fallback.isNotEmpty ? fallback : 'The requested resource was not found.';
      case 409:
        return fallback.isNotEmpty ? fallback : 'This action conflicts with existing data.';
      case 422:
        return fallback.isNotEmpty ? fallback : 'Validation failed. Please check your input.';
      case 429:
        return 'Too many requests. Please wait a moment and try again.';
      case 500:
        return 'Server error. Please try again later.';
      case 503:
        return 'Service temporarily unavailable. Please try again later.';
      default:
        return fallback.isNotEmpty ? fallback : 'An unexpected error occurred.';
    }
  }

  dynamic _handleResponse(http.Response response) {
    final code = response.statusCode;
    if (code >= 200 && code < 300) {
      if (response.body.isEmpty) return null;
      return json.decode(response.body);
    }

    if (code == 401) {
      clearToken();
      onUnauthorized?.call();
      throw ApiException(_messageForStatus(code, ''), statusCode: code);
    }

    String errorMsg = '';
    try {
      final decoded = json.decode(response.body);
      if (decoded is Map && decoded.containsKey('detail')) {
        final detail = decoded['detail'];
        if (detail is String) {
          errorMsg = detail;
        } else if (detail is List) {
          errorMsg = detail
              .map((e) => e is Map ? (e['msg'] ?? e.toString()) : e.toString())
              .join(', ');
        } else {
          errorMsg = detail.toString();
        }
      }
    } catch (_) {}

    throw ApiException(
      _messageForStatus(code, errorMsg),
      statusCode: code,
    );
  }

  Future<dynamic> _send(Future<http.Response> request) async {
    try {
      final response = await request.timeout(_timeout);
      return _handleResponse(response);
    } on TimeoutException {
      throw ApiException('Request timed out. Please try again.');
    } on SocketException {
      throw ApiException('No internet connection.');
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  Future<dynamic> get(String path) async {
    return _send(http.get(
      Uri.parse('$baseUrl$path'),
      headers: _getHeaders(),
    ));
  }

  Future<dynamic> post(String path, {Map<String, dynamic>? body}) async {
    return _send(http.post(
      Uri.parse('$baseUrl$path'),
      headers: _getHeaders(),
      body: body != null ? json.encode(body) : null,
    ));
  }

  Future<dynamic> put(String path, {Map<String, dynamic>? body}) async {
    return _send(http.put(
      Uri.parse('$baseUrl$path'),
      headers: _getHeaders(),
      body: body != null ? json.encode(body) : null,
    ));
  }

  Future<dynamic> delete(String path) async {
    return _send(http.delete(
      Uri.parse('$baseUrl$path'),
      headers: _getHeaders(),
    ));
  }
}

final apiClient = ApiClient();
