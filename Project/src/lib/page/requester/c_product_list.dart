import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../component/component.dart';
import '../../provider/provider.dart';
import '../../models/database_models.dart';

/// 商品一覧画面（店舗詳細）
class CProductListPage extends StatefulWidget {
  final int? storeId;
  final String? storeName;

  const CProductListPage({
    super.key,
    this.storeId,
    this.storeName,
  });

  @override
  State<CProductListPage> createState() => _CProductListPageState();
}

class _CProductListPageState extends State<CProductListPage> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'すべて';
  final List<String> _categories = ['すべて', '料理', 'カフェ', 'ファスト', 'ラーメン', '食料品'];

  @override
  void initState() {
    super.initState();
    if (widget.storeId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<StoreProvider>().fetchStoreProducts(widget.storeId!);
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final storeProvider = context.watch<StoreProvider>();
    final products = storeProvider.products;

    return Scaffold(
      appBar: TitleAppBar(
        title: widget.storeName ?? '商品を探す',
        showBackButton: true,
      ),
      body: Column(
        children: [
          // 検索バー
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: '商品を検索',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
              onChanged: (value) {
                // TODO: 検索処理
              },
            ),
          ),
          // 商品リスト
          Expanded(
            child: storeProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : products.isEmpty
                    ? const Center(child: Text('商品がありません'))
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: products.length,
                        itemBuilder: (context, index) {
                          final productData = products[index];
                          // Productモデルに変換（APIレスポンスがMapの場合）
                          final product = Product.fromMap(productData);
                          return _buildProductItem(product);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductItem(Product product) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // 商品画像
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
                image: product.imageUrl != null
                    ? DecorationImage(
                        image: NetworkImage(product.imageUrl!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: product.imageUrl == null
                  ? const Icon(Icons.fastfood, color: Colors.grey)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.description ?? '',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '¥${product.price}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A237E),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          context.read<CartProvider>().addItem(product);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${product.name}をカートに追加しました'),
                              duration: const Duration(seconds: 1),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1A237E),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text('追加'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
