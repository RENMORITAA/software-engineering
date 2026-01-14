import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/env_config.dart';
import 'mock_api_service.dart';

class ApiService {
  /// モックAPIを使うかどうか
  static bool get _useMockApi => EnvConfig.useMockApi;

  static final MockApiService _mockApiService = MockApiService();

  /// API Base URL（EnvConfigから取得）
  static String get baseUrl => EnvConfig.apiBaseUrl;

  /// タイムアウト時間
  Duration get timeout => Duration(seconds: EnvConfig.apiTimeout);

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<Map<String, String>> _getHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  void _log(String message) {
    if (EnvConfig.enableLogging) {
      debugPrint('[ApiService] $message');
    }
  }

  Future<dynamic> get(String endpoint) async {
    if (_useMockApi) {
      return _mockApiService.get(endpoint);
    }

    _log('GET $baseUrl$endpoint');
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
    ).timeout(timeout);
    return _handleResponse(response);
  }

  Future<dynamic> post(String endpoint, Map<String, dynamic> data, {bool isFormData = false}) async {
    if (_useMockApi) {
      return _mockApiService.post(endpoint, data, isFormData: isFormData);
    }

    _log('POST $baseUrl$endpoint');
    final headers = await _getHeaders();
    
    dynamic body;
    if (isFormData) {
      headers['Content-Type'] = 'application/x-www-form-urlencoded';
      body = data.entries.map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value.toString())}').join('&');
    } else {
      body = jsonEncode(data);
    }

    final response = await http.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
      body: body,
    ).timeout(timeout);
    return _handleResponse(response);
  }

  Future<dynamic> put(String endpoint, Map<String, dynamic> data) async {
    if (_useMockApi) {
      return _mockApiService.put(endpoint, data);
    }

    _log('PUT $baseUrl$endpoint');
    final headers = await _getHeaders();
    final response = await http.put(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
      body: jsonEncode(data),
    ).timeout(timeout);
    return _handleResponse(response);
  }

  Future<dynamic> delete(String endpoint) async {
    if (_useMockApi) {
      return _mockApiService.delete(endpoint);
    }

    _log('DELETE $baseUrl$endpoint');
    final headers = await _getHeaders();
    final response = await http.delete(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
    ).timeout(timeout);
    return _handleResponse(response);
  }

  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      // ボディが空の場合はnullを返す
      if (response.body.isEmpty) return null;
      return jsonDecode(utf8.decode(response.bodyBytes));
    } else {
      // エラーハンドリング
      throw Exception('API Error: ${response.statusCode} ${response.body}');
    }
  }
}
