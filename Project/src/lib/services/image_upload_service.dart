import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'dart:convert';
import 'api_service.dart';

/// 画像アップロードサービス
class ImageUploadService {
  final ApiService _apiService = ApiService();

  /// プロフィール画像をアップロード
  Future<String> uploadProfileImage(Uint8List imageBytes, String filename) async {
    return await _uploadImage('/uploads/profile-image', imageBytes, filename);
  }

  /// 店舗画像をアップロード
  Future<String> uploadStoreImage(Uint8List imageBytes, String filename) async {
    return await _uploadImage('/uploads/store-image', imageBytes, filename);
  }

  /// 商品画像をアップロード
  Future<String> uploadProductImage(int productId, Uint8List imageBytes, String filename) async {
    return await _uploadImage('/uploads/product-image/$productId', imageBytes, filename);
  }

  /// 画像をアップロード（共通処理）
  Future<String> _uploadImage(String endpoint, Uint8List imageBytes, String filename) async {
    final token = await _apiService.getToken();
    final uri = Uri.parse('${ApiService.baseUrl}$endpoint');

    // ファイル拡張子からContent-Typeを判定
    final ext = filename.split('.').last.toLowerCase();
    String mimeType = 'image/jpeg';
    if (ext == 'png') mimeType = 'image/png';
    if (ext == 'gif') mimeType = 'image/gif';
    if (ext == 'webp') mimeType = 'image/webp';

    final request = http.MultipartRequest('POST', uri);
    
    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    request.files.add(http.MultipartFile.fromBytes(
      'file',
      imageBytes,
      filename: filename,
      contentType: MediaType.parse(mimeType),
    ));

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = jsonDecode(response.body);
      return data['url'] ?? '';
    } else {
      throw Exception('Upload failed: ${response.statusCode} ${response.body}');
    }
  }

  /// 画像を削除
  Future<void> deleteImage(String imageUrl) async {
    // URLから image_type と filename を抽出
    // 例: /uploads/profiles/20251231_123456_abcd1234.jpg
    final parts = imageUrl.split('/');
    if (parts.length >= 3) {
      final imageType = parts[parts.length - 2];
      final filename = parts.last;
      await _apiService.delete('/uploads/$imageType/$filename');
    }
  }

  /// 画像URLをフルURLに変換
  static String getFullImageUrl(String? relativeUrl) {
    if (relativeUrl == null || relativeUrl.isEmpty) {
      return '';
    }
    if (relativeUrl.startsWith('http')) {
      return relativeUrl;
    }
    return '${ApiService.baseUrl}$relativeUrl';
  }
}
