import "package:flutter/material.dart";
import "package:provider/provider.dart";

import "../../component/component.dart";
import "../../provider/provider.dart";
import "../../models/database_models.dart";

/// 在庫管理
class SInventoryStatusPage extends StatefulWidget {
  const SInventoryStatusPage({super.key});

  @override
  State<SInventoryStatusPage> createState() => _SInventoryStatusPageState();
}

class _SInventoryStatusPageState extends State<SInventoryStatusPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final storeProvider = context.read<StoreProvider>();
      try {
        await storeProvider.fetchMyStoreProducts();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('在庫情報の読み込みに失敗しました: $e')),
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final storeProvider = context.watch<StoreProvider>();
    final products = storeProvider.products;

    return Scaffold(
      appBar: const TitleAppBar(
        title: '在庫管理',
        backgroundColor: Color(0xFFE65100),
        showBackButton: false,
      ),
      body: storeProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : products.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: () => storeProvider.fetchMyStoreProducts(),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final productData = products[index];
                      final product = Product.fromMap(productData);
                      return _buildInventoryCard(product);
                    },
                  ),
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            '商品が登録されていません',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'メニュー編集から商品を追加してください',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInventoryCard(Product product) {
    final stockQuantity = product.stockQuantity;
    final isLowStock = stockQuantity < 5;
    final isOutOfStock = stockQuantity == 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
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
        title: Row(
          children: [
            Expanded(child: Text(product.name)),
            if (isOutOfStock)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  '在庫切れ',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            else if (isLowStock)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  '残りわずか',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        subtitle: Text('¥${product.price}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.remove_circle_outline),
              onPressed: stockQuantity > 0
                  ? () => _updateStock(product, stockQuantity - 1)
                  : null,
              color: const Color(0xFFE65100),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: isOutOfStock
                    ? Colors.red[50]
                    : isLowStock
                        ? Colors.orange[50]
                        : Colors.green[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '$stockQuantity',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isOutOfStock
                      ? Colors.red
                      : isLowStock
                          ? Colors.orange
                          : Colors.green,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add_circle_outline),
              onPressed: () => _updateStock(product, stockQuantity + 1),
              color: const Color(0xFFE65100),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _updateStock(Product product, int newStock) async {
    try {
      final success = await context.read<StoreProvider>().updateProductStock(
        product.id,
        newStock,
      );

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${product.name}の在庫を${newStock}個に更新しました'),
              duration: const Duration(seconds: 1),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('在庫の更新に失敗しました'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('在庫の更新に失敗しました: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}