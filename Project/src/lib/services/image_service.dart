import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'api_service.dart';

class ImageService {
  final ApiService _apiService = ApiService();
  static const String baseUrl = ApiService.baseUrl;

  /// 画像をアップロード
  Future<Map<String, dynamic>> uploadImage(
    File imageFile, {
    String? entityType,
    int? entityId,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/images/upload'),
      );

      // 認証ヘッダー
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      // クエリパラメータ
      if (entityType != null) {
        request.fields['entity_type'] = entityType;
      }
      if (entityId != null) {
        request.fields['entity_id'] = entityId.toString();
      }

      // ファイルを追加
      request.files.add(
        await http.MultipartFile.fromPath('file', imageFile.path),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Upload failed: ${response.body}');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// 画像情報を取得
  Future<Map<String, dynamic>> getImage(int imageId) async {
    try {
      final response = await _apiService.get('/images/$imageId');
      return response as Map<String, dynamic>;
    } catch (e) {
      rethrow;
    }
  }

  /// エンティティに紐づく画像一覧を取得
  Future<List<dynamic>> getEntityImages(String entityType, int entityId) async {
    try {
      final response = await _apiService.get('/images/entity/$entityType/$entityId');
      return response as List<dynamic>;
    } catch (e) {
      rethrow;
    }
  }

  /// 画像を削除
  Future<void> deleteImage(int imageId) async {
    try {
      await _apiService.delete('/images/$imageId');
    } catch (e) {
      rethrow;
    }
  }

  /// 画像URLを取得（相対パスから絶対URLへ変換）
  String getImageUrl(String filePath) {
    if (filePath.startsWith('http')) {
      return filePath;
    }
    return '$baseUrl$filePath';
  }
}
