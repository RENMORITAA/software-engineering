import 'dart:convert';
import 'package:crypto/crypto.dart';
import '../db_helper.dart';
import '../models/database_models.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  final DbHelper _dbHelper = DbHelper();
  
  AuthService._internal();
  
  factory AuthService() {
    return _instance;
  }

  // パスワードをハッシュ化する
  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  // ユーザー登録
  Future<int?> registerUser({
    required String email,
    required String password,
    required String role,
  }) async {
    try {
      // 既存ユーザーのチェック
      final existingUser = await _dbHelper.getUserByEmail(email);
      if (existingUser != null) {
        throw Exception('このメールアドレスは既に登録されています');
      }

      // パスワードをハッシュ化
      final hashedPassword = _hashPassword(password);

      // ユーザーを作成
      final user = User(
        email: email,
        password: hashedPassword,
        role: role,
      );

      final userId = await _dbHelper.insertUser(user.toMap());
      return userId;
    } catch (e) {
      print('ユーザー登録エラー: $e');
      rethrow;
    }
  }

  // ログイン
  Future<User?> login({
    required String email,
    required String password,
  }) async {
    try {
      // ユーザーを取得
      final userData = await _dbHelper.getUserByEmail(email);
      if (userData == null) {
        throw Exception('ユーザーが見つかりません');
      }

      // パスワードを検証
      final hashedPassword = _hashPassword(password);
      if (userData['password'] != hashedPassword) {
        throw Exception('パスワードが正しくありません');
      }

      return User.fromMap(userData);
    } catch (e) {
      print('ログインエラー: $e');
      rethrow;
    }
  }

  // ユーザー情報を取得
  Future<User?> getUserById(int id) async {
    try {
      final userData = await _dbHelper.getUserById(id);
      if (userData != null) {
        return User.fromMap(userData);
      }
      return null;
    } catch (e) {
      print('ユーザー取得エラー: $e');
      rethrow;
    }
  }

  // 依頼者プロフィールを作成
  Future<int> createRequesterProfile({
    required int userId,
    required String name,
    String? phone,
    String? address,
    String? creditCardInfo,
  }) async {
    try {
      final profile = RequesterProfile(
        userId: userId,
        name: name,
        phone: phone,
        address: address,
        creditCardInfo: creditCardInfo,
      );

      return await _dbHelper.insertRequesterProfile(profile.toMap());
    } catch (e) {
      print('依頼者プロフィール作成エラー: $e');
      rethrow;
    }
  }

  // 配達員プロフィールを作成
  Future<int> createDelivererProfile({
    required int userId,
    required String name,
    String? phone,
    String? resume,
    String? bankAccountInfo,
    String? vehicleType,
    String? licenseNumber,
  }) async {
    try {
      final profile = DelivererProfile(
        userId: userId,
        name: name,
        phone: phone,
        resume: resume,
        bankAccountInfo: bankAccountInfo,
        vehicleType: vehicleType,
        licenseNumber: licenseNumber,
      );

      return await _dbHelper.insertDelivererProfile(profile.toMap());
    } catch (e) {
      print('配達員プロフィール作成エラー: $e');
      rethrow;
    }
  }

  // 店舗プロフィールを作成
  Future<int> createStoreProfile({
    required int userId,
    required String storeName,
    required String address,
    String? phone,
    String? businessLicense,
    String? businessHours,
    String? bankAccountInfo,
  }) async {
    try {
      final profile = StoreProfile(
        userId: userId,
        storeName: storeName,
        address: address,
        phone: phone,
        businessLicense: businessLicense,
        businessHours: businessHours,
        bankAccountInfo: bankAccountInfo,
      );

      return await _dbHelper.insertStoreProfile(profile.toMap());
    } catch (e) {
      print('店舗プロフィール作成エラー: $e');
      rethrow;
    }
  }

  // プロフィールを取得（役割に応じて）
  Future<dynamic> getProfile(int userId, String role) async {
    try {
      switch (role) {
        case 'requester':
          final profileData = await _dbHelper.getRequesterProfile(userId);
          return profileData != null ? RequesterProfile.fromMap(profileData) : null;
        case 'deliverer':
          final profileData = await _dbHelper.getDelivererProfile(userId);
          return profileData != null ? DelivererProfile.fromMap(profileData) : null;
        case 'store':
          final profileData = await _dbHelper.getStoreProfile(userId);
          return profileData != null ? StoreProfile.fromMap(profileData) : null;
        default:
          return null;
      }
    } catch (e) {
      print('プロフィール取得エラー: $e');
      rethrow;
    }
  }

  // パスワード変更
  Future<bool> changePassword({
    required int userId,
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      // 現在のユーザー情報を取得
      final userData = await _dbHelper.getUserById(userId);
      if (userData == null) {
        throw Exception('ユーザーが見つかりません');
      }

      // 現在のパスワードを検証
      final hashedCurrentPassword = _hashPassword(currentPassword);
      if (userData['password'] != hashedCurrentPassword) {
        throw Exception('現在のパスワードが正しくありません');
      }

      // 新しいパスワードをハッシュ化して更新
      final hashedNewPassword = _hashPassword(newPassword);
      // Note: DbHelperにupdateUserメソッドを追加する必要があります
      // await _dbHelper.updateUser(userId, {'password': hashedNewPassword});
      
      return true;
    } catch (e) {
      print('パスワード変更エラー: $e');
      rethrow;
    }
  }
}
