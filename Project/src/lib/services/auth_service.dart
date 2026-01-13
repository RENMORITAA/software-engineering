import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';

/// 認証サービス
/// トークン管理、ログイン状態の永続化、セッション管理を担当
class AuthService {
  final ApiService _apiService = ApiService();
  
  // SharedPreferencesのキー
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'current_user';
  static const String _roleKey = 'user_role';
  static const String _loginTimeKey = 'login_time';
  
  // トークンの有効期限（24時間）
  static const int _tokenExpiryHours = 24;

  /// ログイン
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _apiService.post(
        '/auth/login',
        {
          'username': email,
          'password': password,
        },
        isFormData: true,
      );

      final token = response['access_token'];
      if (token != null) {
        await _saveAuthData(token);
      }
      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// 認証データを保存
  Future<void> _saveAuthData(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setInt(_loginTimeKey, DateTime.now().millisecondsSinceEpoch);
  }

  /// ユーザー情報を保存
  Future<void> saveUserInfo(Map<String, dynamic> user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(user));
    if (user['role'] != null) {
      await prefs.setString(_roleKey, user['role']);
    }
  }

  /// 保存されたユーザー情報を取得
  Future<Map<String, dynamic>?> getSavedUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_userKey);
    if (userJson != null) {
      return jsonDecode(userJson) as Map<String, dynamic>;
    }
    return null;
  }

  /// 保存されたロールを取得
  Future<String?> getSavedRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_roleKey);
  }

  Future<void> register(
    String email,
    String password,
    String role, {
    String? name,
    String? phoneNumber,
    // 店舗用
    String? storeName,
    String? storeAddress,
    String? storeDescription,
    String? businessHours,
    // 配達員用
    String? vehicleType,
  }) async {
    try {
      // ユーザー登録
      final userResponse = await _apiService.post('/auth/register', {
        'email': email,
        'password': password,
        'role': role,
      });

      // 登録成功後、プロフィール情報を更新
      // まずログインしてトークンを取得
      await login(email, password);

      // ロールに応じたプロフィール更新
      if (role == 'requester' && name != null) {
        await _apiService.put('/profile/requester', {
          'name': name,
          'phone_number': phoneNumber,
        });
      } else if (role == 'deliverer' && name != null) {
        await _apiService.put('/profile/deliverer', {
          'name': name,
          'phone_number': phoneNumber,
          'vehicle_type': vehicleType,
        });
      } else if (role == 'store' && storeName != null) {
        await _apiService.put('/profile/store', {
          'store_name': storeName,
          'address': storeAddress,
          'description': storeDescription,
          'phone_number': phoneNumber,
          'business_hours': businessHours,
        });
      }
    } catch (e) {
      rethrow;
    }
  }

  /// ログアウト（すべての認証データをクリア）
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
    await prefs.remove(_roleKey);
    await prefs.remove(_loginTimeKey);
  }

  /// ログイン状態を確認（トークンの存在と有効期限をチェック）
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    
    if (token == null) return false;
    
    // トークンの有効期限をチェック
    final loginTime = prefs.getInt(_loginTimeKey);
    if (loginTime != null) {
      final loginDateTime = DateTime.fromMillisecondsSinceEpoch(loginTime);
      final now = DateTime.now();
      final difference = now.difference(loginDateTime);
      
      if (difference.inHours >= _tokenExpiryHours) {
        // トークン期限切れ - ログアウト
        debugPrint('[AuthService] Token expired, logging out');
        await logout();
        return false;
      }
    }
    
    return true;
  }

  /// トークンの有効性をサーバーで確認
  Future<bool> validateToken() async {
    try {
      final isLogged = await isLoggedIn();
      if (!isLogged) return false;
      
      // サーバーに問い合わせてトークンが有効か確認
      await _apiService.get('/auth/me');
      return true;
    } catch (e) {
      debugPrint('[AuthService] Token validation failed: $e');
      await logout();
      return false;
    }
  }

  Future<Map<String, dynamic>> getCurrentUser() async {
    try {
      final response = await _apiService.get('/auth/me');
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getRequesterProfile() async {
    try {
      final response = await _apiService.get('/profile/requester');
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getDelivererProfile() async {
    try {
      final response = await _apiService.get('/profile/deliverer');
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getStoreProfile() async {
    try {
      final response = await _apiService.get('/profile/store');
      return response;
    } catch (e) {
      rethrow;
    }
  }
}

