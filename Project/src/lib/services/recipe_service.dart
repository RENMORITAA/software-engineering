import 'api_service.dart';

class RecipeService {
  final ApiService _apiService = ApiService();

  /// 商品のレシピを取得
  Future<Map<String, dynamic>> getProductRecipe(int productId) async {
    try {
      final response = await _apiService.get('/recipes/product/$productId');
      return response as Map<String, dynamic>;
    } catch (e) {
      rethrow;
    }
  }

  /// 商品のレシピを作成
  Future<Map<String, dynamic>> createProductRecipe(
    int productId,
    Map<String, dynamic> recipeData,
  ) async {
    try {
      final response = await _apiService.post('/recipes/product/$productId', recipeData);
      return response as Map<String, dynamic>;
    } catch (e) {
      rethrow;
    }
  }

  /// 商品のレシピを更新
  Future<Map<String, dynamic>> updateProductRecipe(
    int productId,
    Map<String, dynamic> recipeData,
  ) async {
    try {
      final response = await _apiService.put('/recipes/product/$productId', recipeData);
      return response as Map<String, dynamic>;
    } catch (e) {
      rethrow;
    }
  }

  /// 商品のレシピを削除
  Future<void> deleteProductRecipe(int productId) async {
    try {
      await _apiService.delete('/recipes/product/$productId');
    } catch (e) {
      rethrow;
    }
  }
}
