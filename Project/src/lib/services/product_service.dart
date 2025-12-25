import 'api_service.dart';

class ProductService {
  final ApiService _apiService = ApiService();

  /// 全商品を取得
  Future<List<dynamic>> getProducts() async {
    try {
      final response = await _apiService.get('/products/');
      return response as List<dynamic>;
    } catch (e) {
      rethrow;
    }
  }

  /// 特定の商品を取得
  Future<dynamic> getProduct(int productId) async {
    try {
      final response = await _apiService.get('/products/$productId');
      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// 店舗の商品一覧を取得
  Future<List<dynamic>> getStoreProducts(int storeId) async {
    try {
      final response = await _apiService.get('/products/store/$storeId');
      return response as List<dynamic>;
    } catch (e) {
      rethrow;
    }
  }

  /// 店舗のカテゴリ一覧を取得
  Future<List<dynamic>> getStoreCategories(int storeId) async {
    try {
      final response = await _apiService.get('/products/store/$storeId/categories');
      return response as List<dynamic>;
    } catch (e) {
      rethrow;
    }
  }

  /// 商品を作成（店舗のみ）
  Future<dynamic> createProduct(Map<String, dynamic> productData) async {
    try {
      final response = await _apiService.post('/products/', productData);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// 商品を更新（店舗のみ）
  Future<dynamic> updateProduct(int productId, Map<String, dynamic> productData) async {
    try {
      final response = await _apiService.put('/products/$productId', productData);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// 商品を削除（店舗のみ）
  Future<void> deleteProduct(int productId) async {
    try {
      await _apiService.delete('/products/$productId');
    } catch (e) {
      rethrow;
    }
  }

  /// カテゴリを作成（店舗のみ）
  Future<dynamic> createCategory(Map<String, dynamic> categoryData) async {
    try {
      final response = await _apiService.post('/products/categories', categoryData);
      return response;
    } catch (e) {
      rethrow;
    }
  }
}

