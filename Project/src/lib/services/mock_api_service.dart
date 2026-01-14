import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// モックAPIサービス - ローカルデータで動作する
/// 実際のAPIの代わりにダミーデータを返す
class MockApiService {
  static const String _mockPrefix = 'mock_';
  
  // モックデータストレージ
  static final Map<String, dynamic> _mockDatabase = {
    // ユーザーテスト用
    'users': {
      'requester@example.com': {
        'id': '1',
        'email': 'requester@example.com',
        'password': 'password123',
        'role': 'requester',
      },
      'deliverer@example.com': {
        'id': '2',
        'email': 'deliverer@example.com',
        'password': 'password123',
        'role': 'deliverer',
      },
      'store@example.com': {
        'id': '3',
        'email': 'store@example.com',
        'password': 'password123',
        'role': 'store',
      },
    },
    'profiles': {
      'requester': {
        'id': '1',
        'name': '山田太郎',
        'phone_number': '09012345678',
        'address': '高知県香美市',
      },
      'deliverer': {
        'id': '2',
        'name': '配達太郎',
        'phone_number': '09087654321',
        'vehicle_type': 'bicycle',
      },
      'store': {
        'id': '3',
        'store_name': 'サンプル店舗',
        'address': '高知県香美市中町',
        'phone_number': '0887123456',
        'business_hours': '10:00-22:00',
        'description': 'おいしい料理をお届けします',
      },
    },
  };

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
    debugPrint('[MockApiService] $message');
  }

  Future<dynamic> get(String endpoint) async {
    _log('GET $endpoint');
    await Future.delayed(const Duration(milliseconds: 300)); // API遅延をシミュレート
    return _handleMockRequest(endpoint, 'GET');
  }

  Future<dynamic> post(String endpoint, Map<String, dynamic> data, {bool isFormData = false}) async {
    _log('POST $endpoint');
    await Future.delayed(const Duration(milliseconds: 300));
    return _handleMockRequest(endpoint, 'POST', data);
  }

  Future<dynamic> put(String endpoint, Map<String, dynamic> data) async {
    _log('PUT $endpoint');
    await Future.delayed(const Duration(milliseconds: 300));
    return _handleMockRequest(endpoint, 'PUT', data);
  }

  Future<dynamic> delete(String endpoint) async {
    _log('DELETE $endpoint');
    await Future.delayed(const Duration(milliseconds: 300));
    return _handleMockRequest(endpoint, 'DELETE');
  }

  dynamic _handleMockRequest(String endpoint, String method, [Map<String, dynamic>? data]) {
    _log('Mock Response: $method $endpoint');
    
    // ログイン
    if (endpoint == '/auth/login' && method == 'POST') {
      final email = data?['username'];
      final password = data?['password'];
      final user = _mockDatabase['users']?[email];
      
      if (user != null && user['password'] == password) {
        return {
          'access_token': 'mock_token_${user['id']}',
          'token_type': 'bearer',
        };
      }
      throw Exception('Invalid credentials');
    }
    
    // 新規登録
    if (endpoint == '/auth/register' && method == 'POST') {
      final email = data?['email'];
      final password = data?['password'];
      final role = data?['role'] ?? 'requester';
      
      // ユーザーが既に存在する場合はエラー
      if (_mockDatabase['users']?.containsKey(email) == true) {
        throw Exception('User already exists');
      }
      
      final newUser = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'email': email,
        'password': password,
        'role': role,
      };
      
      _mockDatabase['users']?[email] = newUser;
      return {'id': newUser['id'], 'email': email, 'role': role};
    }
    
    // ユーザー情報取得 (/auth/me)
    if (endpoint == '/auth/me' && method == 'GET') {
      final token = null; // 実装では実際のトークンをパース
      // モックなので、テスト用ユーザーを返す
      return {
        'id': '1',
        'email': 'requester@example.com',
        'role': 'requester',
      };
    }
    
    // プロフィール取得 - Requester
    if (endpoint == '/profile/requester' && method == 'GET') {
      return _mockDatabase['profiles']?['requester'] ?? {};
    }
    
    // プロフィール取得 - Deliverer
    if (endpoint == '/profile/deliverer' && method == 'GET') {
      return _mockDatabase['profiles']?['deliverer'] ?? {};
    }
    
    // プロフィール取得 - Store
    if (endpoint == '/profile/store' && method == 'GET') {
      return _mockDatabase['profiles']?['store'] ?? {};
    }
    
    // プロフィール更新 - Requester
    if (endpoint == '/profile/requester' && method == 'PUT') {
      _mockDatabase['profiles']?['requester'] = {
        ..._mockDatabase['profiles']?['requester'] ?? {},
        ...?data,
      };
      return _mockDatabase['profiles']?['requester'] ?? {};
    }
    
    // プロフィール更新 - Deliverer
    if (endpoint == '/profile/deliverer' && method == 'PUT') {
      _mockDatabase['profiles']?['deliverer'] = {
        ..._mockDatabase['profiles']?['deliverer'] ?? {},
        ...?data,
      };
      return _mockDatabase['profiles']?['deliverer'] ?? {};
    }
    
    // プロフィール更新 - Store
    if (endpoint == '/profile/store' && method == 'PUT') {
      _mockDatabase['profiles']?['store'] = {
        ..._mockDatabase['profiles']?['store'] ?? {},
        ...?data,
      };
      return _mockDatabase['profiles']?['store'] ?? {};
    }
    
    // 商品一覧
    if (endpoint == '/products' && method == 'GET') {
      return {
        'items': [
          {
            'id': '1',
            'name': 'ハンバーガー',
            'price': 1500,
            'description': 'おいしいハンバーガー',
            'store_id': '3',
          },
          {
            'id': '2',
            'name': 'フライドポテト',
            'price': 500,
            'description': 'カリカリなフライドポテト',
            'store_id': '3',
          },
        ],
        'total': 2,
      };
    }
    
    // デフォルト: 空のレスポンス
    _log('Unknown endpoint: $endpoint');
    return {};
  }
}
