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
  
  // SharedPreferencesのキー
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'current_user';
  static const String _roleKey = 'user_role';
  static const String _loginTimeKey = 'login_time';
  
  // トークンの有効期限（24時間）
  static const int _tokenExpiryHours = 24;

  // ---------------------------------------------------------------------------
  // 1. 認証 (ログイン・登録・ログアウト・パスワードリセット)
  // ---------------------------------------------------------------------------

  /// ログイン
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
        
        // ログイン直後のユーザー基本情報を取得
        final userInfo = await getCurrentUser();
        
        // ロールに応じた詳細プロファイルを取得してマージ
        Map<String, dynamic> detail = {};
        final String? role = userInfo['role'];
        try {
          if (role == 'store') detail = await getStoreProfile();
          if (role == 'deliverer') detail = await getDelivererProfile();
          if (role == 'requester') detail = await getRequesterProfile();
        } catch (e) {
          debugPrint('Profile detail fetch failed: $e');
        }

        // 基本情報 + 詳細情報を統合して保存
        await saveUserInfo({...userInfo, ...detail});
      }
      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// 新規登録
  Future<void> register(
    String email,
    String password,
    String role, {
    String? name,
    String? phoneNumber,
    String? storeName,
    String? storeAddress,
    String? storeDescription,
    String? businessHours,
    String? vehicleType,
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

      // 2. 自動ログイン（トークン取得）
      await login(email, password);

      // 3. 詳細情報を各プロフィールへ送信
      Map<String, dynamic> detailData = {};
      if (role == 'requester') {
        detailData = {'name': name, 'phone_number': phoneNumber};
        await _apiService.put('/profile/requester', detailData);
      } else if (role == 'deliverer') {
        detailData = {
          'name': name, 
          'phone_number': phoneNumber, 
          'vehicle_type': vehicleType
        };
        await _apiService.put('/profile/deliverer', detailData);
      } else if (role == 'store') {
        detailData = {
          'store_name': storeName,
          'address': storeAddress,
          'description': storeDescription,
          'phone_number': phoneNumber,
          'business_hours': businessHours,
        };
        await _apiService.put('/profile/store', detailData);
      }

      // 4. 最新状態を保存
      final baseInfo = await getCurrentUser();
      await saveUserInfo({...baseInfo, ...detailData});

    } catch (e) {
      rethrow;
    }
  }

  /// パスワードリセット
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _apiService.post('/auth/password-reset-request', {'email': email});
    } catch (e) {
      final errStr = e.toString();
      if (errStr.contains('404')) throw 'このメールアドレスは登録されていません。';
      rethrow;
    }
  }

  /// ログアウト
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
    await prefs.remove(_roleKey);
    await prefs.remove(_loginTimeKey);
  }

  // ---------------------------------------------------------------------------
  // 2. プロフィール・口座情報更新
  // ---------------------------------------------------------------------------

  /// プロフィールの更新（画像対応）
  Future<void> updateProfile({
    required String role,
    required Map<String, dynamic> data,
    XFile? imageFile,
  }) async {
    try {
      final String endpoint = '/profile/$role'; 
      final String? token = await getToken(); 
      final String host = kIsWeb ? "127.0.0.1" : "10.0.2.2";
      final String baseUrl = "http://$host:8000";
      final Uri uri = Uri.parse('$baseUrl$endpoint');

      if (imageFile == null) {
        await _apiService.put(endpoint, data);
      } else {
        final request = http.MultipartRequest('PUT', uri);
        request.headers['Authorization'] = 'Bearer $token';

        data.forEach((key, value) {
          if (value != null) request.fields[key] = value.toString();
        });

        final String imageFieldName = (role == 'store') ? 'license_image' : 'resume_image';

        if (kIsWeb) {
          final Uint8List bytes = await imageFile.readAsBytes();
          request.files.add(http.MultipartFile.fromBytes(
            imageFieldName,
            bytes,
            filename: imageFile.name,
            contentType: MediaType('image', 'jpeg'),
          ));
        } else {
          request.files.add(await http.MultipartFile.fromPath(imageFieldName, imageFile.path));
        }

        final streamedResponse = await request.send().timeout(const Duration(seconds: 40));
        final response = await http.Response.fromStream(streamedResponse);
        
        if (response.statusCode < 200 || response.statusCode >= 300) {
          throw 'プロフィールの保存に失敗しました (${response.statusCode})';
        }
      }

      // プロフィール更新時もデータを反映
      await saveUserInfo(data);
      await _refreshAndSaveUserInfo(role);
      
    } catch (e) {
      debugPrint('updateProfile error: $e');
      rethrow;
    }
  }

  /// 口座情報の更新
  Future<void> updateBankingInfo({required String role, required Map<String, dynamic> data}) async {
    try {
      final String endpoint = '/profile/$role/banking';
      await _apiService.put(endpoint, data);
      
      // 【修正ポイント】サーバーからの再取得を待つ前に、
      // 入力された最新データを直接ローカルキャッシュに上書き保存します。
      // これにより、通信ラグによる「戻り現象」を防ぎます。
      await saveUserInfo(data);
      
      // その後、整合性を保つために最新状態をサーバーからバックグラウンドで同期
      await _refreshAndSaveUserInfo(role);
    } catch (e) {
      debugPrint('updateBankingInfo error: $e');
      rethrow;
    }
  }

  /// 最新のプロフィールを取得する
  Future<Map<String, dynamic>?> getUserProfile() async {
    try {
      final String? role = await getSavedRole();
      if (role == null) return null;

      Map<String, dynamic> detail = {};
      if (role == 'store') detail = await getStoreProfile();
      if (role == 'deliverer') detail = await getDelivererProfile();
      if (role == 'requester') detail = await getRequesterProfile();
      
      // サーバーから取得した詳細情報をキャッシュにも反映
      await saveUserInfo(detail);
      
      return detail;
    } catch (e) {
      debugPrint('getUserProfile error: $e');
      return null;
    }
  }

  /// サーバーから最新情報を取得し、SharedPreferencesを更新する内部メソッド
  Future<void> _refreshAndSaveUserInfo(String role) async {
    try {
      final baseInfo = await getCurrentUser();
      Map<String, dynamic> detail = {};
      if (role == 'store') detail = await getStoreProfile();
      if (role == 'deliverer') detail = await getDelivererProfile();
      if (role == 'requester') detail = await getRequesterProfile();
      
      await saveUserInfo({...baseInfo, ...detail});
    } catch (e) {
      debugPrint('Detail fetch failed in _refreshAndSaveUserInfo: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // 3. お問い合わせ機能
  // ---------------------------------------------------------------------------

  Future<bool> sendContactEmail({required String category, required String content}) async {
    try {
      final userInfo = await getSavedUserInfo();
      final String userEmail = userInfo?['email'] ?? 'unknown';

      await _apiService.post('/contact', {
        'category': category,
        'content': content,
        'user_email': userEmail,
        'target_email': 'kut.stellarworks@gmail.com',
      });

      return true;
    } catch (e) {
      debugPrint('sendContactEmail error: $e');
      return false;
    }
  }

  // ---------------------------------------------------------------------------
  // 4. ローカルデータ永続化
  // ---------------------------------------------------------------------------

  Future<void> saveUserInfo(Map<String, dynamic> user) async {
    final prefs = await SharedPreferences.getInstance();
    final String? existingJson = prefs.getString(_userKey);
    
    Map<String, dynamic> updatedData = {};
    if (existingJson != null) {
      try {
        updatedData = Map<String, dynamic>.from(jsonDecode(existingJson));
      } catch (e) {
        debugPrint('Error decoding existing user info: $e');
      }
    }
    
    // nullでない値のみをマージ（上書き）
    user.forEach((key, value) {
      if (value != null) {
        updatedData[key] = value;
      }
    });

    await prefs.setString(_userKey, jsonEncode(updatedData));
    
    // ロールが変更された場合は個別のキーも更新
    if (updatedData['role'] != null) {
      await prefs.setString(_roleKey, updatedData['role']);
    }
  }

  Future<Map<String, dynamic>?> getSavedUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final String? userJson = prefs.getString(_userKey);
    if (userJson == null) return null;
    try {
      return jsonDecode(userJson) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
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
    final String? token = prefs.getString(_tokenKey);
    if (token == null) return false;
    
    final int? loginTime = prefs.getInt(_loginTimeKey);
    if (loginTime != null) {
      final DateTime loginDateTime = DateTime.fromMillisecondsSinceEpoch(loginTime);
      if (DateTime.now().difference(loginDateTime).inHours >= _tokenExpiryHours) {
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

  // ---------------------------------------------------------------------------
  // 5. API メソッド
  // ---------------------------------------------------------------------------

  Future<Map<String, dynamic>> getCurrentUser() async => await _apiService.get('/auth/me');
  Future<Map<String, dynamic>> getStoreProfile() async => await _apiService.get('/profile/store');
  Future<Map<String, dynamic>> getDelivererProfile() async => await _apiService.get('/profile/deliverer');
  Future<Map<String, dynamic>> getRequesterProfile() async => await _apiService.get('/profile/requester');
}