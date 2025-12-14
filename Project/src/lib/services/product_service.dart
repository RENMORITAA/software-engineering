import '../db_helper.dart';
import '../models/database_models.dart';

class ProductService {
  static final ProductService _instance = ProductService._internal();
  final DbHelper _dbHelper = DbHelper();
  
  ProductService._internal();
  
  factory ProductService() {
    return _instance;
  }

  // 商品を追加
  Future<int> addProduct({
    required int storeId,
    required String name,
    String? description,
    required int price,
    String? category,
    String? imageUrl,
    bool isAvailable = true,
  }) async {
    try {
      final product = Product(
        storeId: storeId,
        name: name,
        description: description,
        price: price,
        category: category,
        imageUrl: imageUrl,
        isAvailable: isAvailable,
      );

      return await _dbHelper.insertProduct(product.toMap());
    } catch (e) {
      print('商品追加エラー: $e');
      rethrow;
    }
  }

  // 商品情報を更新
  Future<void> updateProduct({
    required int productId,
    String? name,
    String? description,
    int? price,
    String? category,
    String? imageUrl,
    bool? isAvailable,
  }) async {
    try {
      final updateData = <String, dynamic>{};
      
      if (name != null) updateData['name'] = name;
      if (description != null) updateData['description'] = description;
      if (price != null) updateData['price'] = price;
      if (category != null) updateData['category'] = category;
      if (imageUrl != null) updateData['image_url'] = imageUrl;
      if (isAvailable != null) updateData['is_available'] = isAvailable ? 1 : 0;

      if (updateData.isNotEmpty) {
        await _dbHelper.updateProduct(productId, updateData);
      }
    } catch (e) {
      print('商品更新エラー: $e');
      rethrow;
    }
  }

  // 店舗の商品一覧を取得
  Future<List<Product>> getProductsByStore(int storeId) async {
    try {
      final productsData = await _dbHelper.getProductsByStore(storeId);
      return productsData.map((data) => Product.fromMap(data)).toList();
    } catch (e) {
      print('店舗商品一覧取得エラー: $e');
      rethrow;
    }
  }

  // 全商品一覧を取得
  Future<List<Product>> getAllProducts() async {
    try {
      final productsData = await _dbHelper.getAllProducts();
      return productsData.map((data) => Product.fromMap(data)).toList();
    } catch (e) {
      print('全商品一覧取得エラー: $e');
      rethrow;
    }
  }

  // 商品を検索
  Future<List<Product>> searchProducts({
    String? keyword,
    String? category,
    int? maxPrice,
    int? minPrice,
  }) async {
    try {
      final db = await _dbHelper.database;
      
      String whereClause = 'is_available = 1';
      List<dynamic> whereArgs = [];
      
      if (keyword != null && keyword.isNotEmpty) {
        whereClause += ' AND (name LIKE ? OR description LIKE ?)';
        whereArgs.addAll(['%$keyword%', '%$keyword%']);
      }
      
      if (category != null && category.isNotEmpty) {
        whereClause += ' AND category = ?';
        whereArgs.add(category);
      }
      
      if (minPrice != null) {
        whereClause += ' AND price >= ?';
        whereArgs.add(minPrice);
      }
      
      if (maxPrice != null) {
        whereClause += ' AND price <= ?';
        whereArgs.add(maxPrice);
      }
      
      final productsData = await db.query(
        'products',
        where: whereClause,
        whereArgs: whereArgs,
        orderBy: 'created_at DESC',
      );
      
      return productsData.map((data) => Product.fromMap(data)).toList();
    } catch (e) {
      print('商品検索エラー: $e');
      rethrow;
    }
  }

  // 商品の詳細情報を取得
  Future<Map<String, dynamic>?> getProductDetails(int productId) async {
    try {
      final db = await _dbHelper.database;
      
      final productData = await db.rawQuery('''
        SELECT p.*, sp.store_name, sp.address as store_address
        FROM products p
        JOIN store_profiles sp ON p.store_id = sp.id
        WHERE p.id = ? AND p.is_available = 1
      ''', [productId]);
      
      if (productData.isNotEmpty) {
        final data = productData.first;
        return {
          'product': Product.fromMap(data).toMap(),
          'store_name': data['store_name'],
          'store_address': data['store_address'],
        };
      }
      
      return null;
    } catch (e) {
      print('商品詳細取得エラー: $e');
      rethrow;
    }
  }

  // カテゴリ一覧を取得
  Future<List<String>> getCategories() async {
    try {
      final db = await _dbHelper.database;
      
      final categoriesData = await db.rawQuery('''
        SELECT DISTINCT category
        FROM products
        WHERE category IS NOT NULL AND category != '' AND is_available = 1
        ORDER BY category
      ''');
      
      return categoriesData
          .map((data) => data['category'] as String)
          .toList();
    } catch (e) {
      print('カテゴリ一覧取得エラー: $e');
      rethrow;
    }
  }

  // 商品の在庫状況を切り替え
  Future<void> toggleProductAvailability(int productId) async {
    try {
      final db = await _dbHelper.database;
      
      // 現在の在庫状況を取得
      final currentData = await db.query(
        'products',
        columns: ['is_available'],
        where: 'id = ?',
        whereArgs: [productId],
      );
      
      if (currentData.isNotEmpty) {
        final currentAvailability = currentData.first['is_available'] as int;
        final newAvailability = currentAvailability == 1 ? 0 : 1;
        
        await _dbHelper.updateProduct(productId, {'is_available': newAvailability});
      }
    } catch (e) {
      print('商品在庫状況切り替えエラー: $e');
      rethrow;
    }
  }

  // 商品を削除（論理削除）
  Future<void> deleteProduct(int productId) async {
    try {
      await _dbHelper.updateProduct(productId, {'is_available': 0});
    } catch (e) {
      print('商品削除エラー: $e');
      rethrow;
    }
  }

  // 人気商品を取得（注文回数順）
  Future<List<Map<String, dynamic>>> getPopularProducts({int limit = 10}) async {
    try {
      final db = await _dbHelper.database;
      
      final popularProductsData = await db.rawQuery('''
        SELECT p.*, COUNT(od.product_id) as order_count,
               sp.store_name, sp.address as store_address
        FROM products p
        LEFT JOIN order_details od ON p.id = od.product_id
        JOIN store_profiles sp ON p.store_id = sp.id
        WHERE p.is_available = 1
        GROUP BY p.id
        ORDER BY order_count DESC, p.created_at DESC
        LIMIT ?
      ''', [limit]);
      
      return popularProductsData.map((data) => {
        'product': Product.fromMap(data).toMap(),
        'order_count': data['order_count'],
        'store_name': data['store_name'],
        'store_address': data['store_address'],
      }).toList();
    } catch (e) {
      print('人気商品取得エラー: $e');
      rethrow;
    }
  }

  // 店舗ごとの商品カテゴリを取得
  Future<List<String>> getCategoriesByStore(int storeId) async {
    try {
      final db = await _dbHelper.database;
      
      final categoriesData = await db.rawQuery('''
        SELECT DISTINCT category
        FROM products
        WHERE store_id = ? AND category IS NOT NULL AND category != '' AND is_available = 1
        ORDER BY category
      ''', [storeId]);
      
      return categoriesData
          .map((data) => data['category'] as String)
          .toList();
    } catch (e) {
      print('店舗カテゴリ取得エラー: $e');
      rethrow;
    }
  }
}
