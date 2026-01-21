import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import 'package:http_parser/http_parser.dart';
import 'api_service.dart';

/// 認証・ユーザー管理サービス
class AuthService {
  final ApiService _apiService = ApiService();
  
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'current_user';
  static const String _roleKey = 'user_role';
  static const String _loginTimeKey = 'login_time';
  static const int _tokenExpiryHours = 24;

  // ---------------------------------------------------------------------------
  // 1. 認証 (ログイン・登録・ログアウト・退会)
  // ---------------------------------------------------------------------------

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _apiService.post(
        '/auth/login',
        {'username': email, 'password': password},
        isFormData: true,
      );

      final String? token = response['access_token'];
      if (token != null) {
        await _saveAuthData(token);
        final userInfo = await getCurrentUser();
        
        Map<String, dynamic> detail = {};
        final String? role = userInfo['role'];
        try {
          if (role == 'store') detail = await getStoreProfile();
          if (role == 'deliverer') detail = await getDelivererProfile();
          if (role == 'requester') detail = await getRequesterProfile();
        } catch (e) {
          debugPrint('Profile detail fetch failed: $e');
        }
        await saveUserInfo({...userInfo, ...detail});
      }
      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// 新規登録 (businessHours 等の不足していた引数をすべて追加)
  Future<void> register(
    String email,
    String password,
    String role, {
    String? name,
    String? phoneNumber,
    String? storeName,
    String? storeAddress,
    String? storeDescription,
    String? businessHours, // 追加
    String? vehicleType,   // 追加
  }) async {
    try {
      // 1. アカウント作成
      await _apiService.post('/auth/register', {
        'email': email,
        'password': password,
        'role': role,
        'name': name,
        'store_name': storeName,
        'store_address': storeAddress,
      });

      // 2. ログインしてトークン取得
      await login(email, password);

      // 3. ロールごとのプロフィール詳細を更新
      Map<String, dynamic> detailData = {};
      if (role == 'requester') {
        detailData = {'name': name, 'phone_number': phoneNumber};
        await _apiService.put('/profile/requester', detailData);
      } else if (role == 'deliverer') {
        detailData = {
          'name': name, 
          'phone_number': phoneNumber,
          'vehicle_type': vehicleType, // 車種も追加
        };
        await _apiService.put('/profile/deliverer', detailData);
      } else if (role == 'store') {
        detailData = {
          'store_name': storeName,
          'address': storeAddress,
          'description': storeDescription,
          'business_hours': businessHours, // 営業時間を追加
          'phone_number': phoneNumber,
        };
        await _apiService.put('/profile/store', detailData);
      }

      final baseInfo = await getCurrentUser();
      await saveUserInfo({...baseInfo, ...detailData});
    } catch (e) {
      rethrow;
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _apiService.post('/auth/password-reset-request', {'email': email});
    } catch (e) {
      if (e.toString().contains('404')) throw 'このメールアドレスは登録されていません。';
      rethrow;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
    await prefs.remove(_roleKey);
    await prefs.remove(_loginTimeKey);
  }

  /// 退会 (DB削除 + ログアウト)
  Future<void> withdraw() async {
    try {
      await _apiService.delete('/auth/withdraw');
      await logout();
      debugPrint('[AuthService] Withdraw successful');
    } catch (e) {
      debugPrint('[AuthService] Withdraw failed: $e');
      rethrow;
    }
  }

  // ---------------------------------------------------------------------------
  // 2. プロフィール更新・同期
  // ---------------------------------------------------------------------------

  Future<void> updateProfile({
    required String role,
    required Map<String, dynamic> data,
    XFile? imageFile,
  }) async {
    try {
      final String endpoint = '/profile/$role';
      if (imageFile == null) {
        await _apiService.put(endpoint, data);
      } else {
        final String? token = await getToken();
        final Uri uri = Uri.parse('${ApiService.baseUrl}$endpoint');
        final request = http.MultipartRequest('PUT', uri);
        request.headers['Authorization'] = 'Bearer $token';

        data.forEach((key, value) {
          if (value != null) request.fields[key] = value.toString();
        });

        final String fieldName = (role == 'store') ? 'license_image' : 'resume_image';
        if (kIsWeb) {
          final bytes = await imageFile.readAsBytes();
          request.files.add(http.MultipartFile.fromBytes(fieldName, bytes, filename: imageFile.name, contentType: MediaType('image', 'jpeg')));
        } else {
          request.files.add(await http.MultipartFile.fromPath(fieldName, imageFile.path));
        }

        final response = await http.Response.fromStream(await request.send());
        if (response.statusCode < 200 || response.statusCode >= 300) throw '保存失敗';
      }
      await saveUserInfo(data);
      await _refreshAndSaveUserInfo(role);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateBankingInfo({required String role, required Map<String, dynamic> data}) async {
    await _apiService.put('/profile/$role/banking', data);
    await saveUserInfo(data);
    await _refreshAndSaveUserInfo(role);
  }

  Future<Map<String, dynamic>?> getUserProfile() async {
    final role = await getSavedRole();
    if (role == null) return null;
    Map<String, dynamic> detail = {};
    if (role == 'store') detail = await getStoreProfile();
    if (role == 'deliverer') detail = await getDelivererProfile();
    if (role == 'requester') detail = await getRequesterProfile();
    await saveUserInfo(detail);
    return detail;
  }

  Future<void> _refreshAndSaveUserInfo(String role) async {
    try {
      final baseInfo = await getCurrentUser();
      Map<String, dynamic> detail = {};
      if (role == 'store') detail = await getStoreProfile();
      if (role == 'deliverer') detail = await getDelivererProfile();
      if (role == 'requester') detail = await getRequesterProfile();
      await saveUserInfo({...baseInfo, ...detail});
    } catch (e) {}
  }

  // ---------------------------------------------------------------------------
  // 3. その他
  // ---------------------------------------------------------------------------

  Future<bool> sendContactEmail({required String category, required String content}) async {
    try {
      final info = await getSavedUserInfo();
      await _apiService.post('/contact', {
        'category': category,
        'content': content,
        'user_email': info?['email'] ?? 'unknown',
        'target_email': 'kut.stellarworks@gmail.com',
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> saveUserInfo(Map<String, dynamic> user) async {
    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getString(_userKey);
    Map<String, dynamic> updated = existing != null ? Map<String, dynamic>.from(jsonDecode(existing)) : {};
    user.forEach((key, value) { if (value != null) updated[key] = value; });
    await prefs.setString(_userKey, jsonEncode(updated));
    if (updated['role'] != null) await prefs.setString(_roleKey, updated['role']);
  }

  Future<Map<String, dynamic>?> getSavedUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_userKey);
    return json != null ? jsonDecode(json) as Map<String, dynamic> : null;
  }

  Future<String?> getSavedRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_roleKey);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    if (token == null) return false;
    final loginTime = prefs.getInt(_loginTimeKey);
    if (loginTime != null) {
      if (DateTime.now().difference(DateTime.fromMillisecondsSinceEpoch(loginTime)).inHours >= _tokenExpiryHours) {
        await logout();
        return false;
      }
    }
    return true;
  }

  Future<void> _saveAuthData(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setInt(_loginTimeKey, DateTime.now().millisecondsSinceEpoch);
  }

  Future<Map<String, dynamic>> getCurrentUser() async => await _apiService.get('/auth/me');
  Future<Map<String, dynamic>> getStoreProfile() async => await _apiService.get('/profile/store');
  Future<Map<String, dynamic>> getDelivererProfile() async => await _apiService.get('/profile/deliverer');
  Future<Map<String, dynamic>> getRequesterProfile() async => await _apiService.get('/profile/requester');
}