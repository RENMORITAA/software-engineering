import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../component/component.dart';
import '../../provider/provider.dart';

/// カート画面
class CCartPage extends StatefulWidget {
  const CCartPage({super.key});

  @override
  State<CCartPage> createState() => _CCartPageState();
}

class _CCartPageState extends State<CCartPage> {
  @override
  Widget build(BuildContext context) {
    final cartProvider = context.watch<CartProvider>();
    final cartItems = cartProvider.items;

    return Scaffold(
      appBar: const TitleAppBar(
        title: 'カート',
        showBackButton: false,
      ),
      body: cartItems.isEmpty
          ? _buildEmptyCart()
          : Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      // 店舗情報
                      if (cartProvider.selectedStoreName != null)
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.08),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.store,
                                  color: Colors.grey[400],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      cartProvider.selectedStoreName!,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    const Text(
                                      '配達予定: 20-30分',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 24),
                      // 注文アイテム
                      const Text(
                        '注文内容',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...cartItems.asMap().entries.map((entry) {
                        final index = entry.key;
                        final item = entry.value;
                        return _buildCartItem(
                          item,
                          index,
                          (newQuantity) {
                            if (item.product.id != null) {
                              context
                                  .read<CartProvider>()
                                  .updateQuantity(item.product.id!, newQuantity);
                            }
                          },
                        );
                      }),
                      const SizedBox(height: 24),
                      // 支払い方法（モック）
                      const Text(
                        '支払い方法',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.credit_card, color: Color(0xFF1A237E)),
                            const SizedBox(width: 12),
                            const Text(
                              'クレジットカード',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const Spacer(),
                            TextButton(
                              onPressed: () {},
                              child: const Text('変更'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // 合計金額と注文ボタン
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('小計'),
                            Text('¥${cartProvider.subtotal}'),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('配達料'),
                            Text('¥${cartProvider.deliveryFee}'),
                          ],
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Divider(),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              '合計',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '¥${cartProvider.totalPrice}',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1A237E),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () async {
                              await _placeOrder(context, cartProvider);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1A237E),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: const Text(
                              '注文を確定する',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Future<void> _placeOrder(
      BuildContext context, CartProvider cartProvider) async {
    if (cartProvider.selectedStoreId == null) return;

    final orderData = {
      'store_id': cartProvider.selectedStoreId,
      'delivery_address': '東京都渋谷区...', // TODO: 実際の住所を使用
      'delivery_latitude': 35.681236, // 仮の座標
      'delivery_longitude': 139.767125, // 仮の座標
      'notes': cartProvider.notes,
      'details': cartProvider.items
          .map((item) => {
                'product_id': item.product.id,
                'quantity': item.quantity,
                'unit_price': item.product.price,
              })
          .toList(),
    };

    final orderId = await context.read<OrderProvider>().createOrder(orderData);

    if (orderId != null && context.mounted) {
      cartProvider.clear();
      // 注文完了ダイアログなどを表示するか、注文履歴へ遷移
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('注文が完了しました')),
      );
      // TODO: 注文完了画面または履歴画面へ遷移
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                '注文に失敗しました: ${context.read<OrderProvider>().error ?? "不明なエラー"}')),
      );
    }
  }

  Widget _buildCartItem(
      CartItem item, int index, Function(int) onUpdateQuantity) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
              image: item.product.imageUrl != null
                  ? DecorationImage(
                      image: NetworkImage(item.product.imageUrl!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: item.product.imageUrl == null
                ? const Icon(Icons.fastfood, color: Colors.grey)
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.product.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '¥${item.product.price}',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.remove_circle_outline),
                color: Colors.grey,
                onPressed: () => onUpdateQuantity(item.quantity - 1),
              ),
              Text(
                '${item.quantity}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle_outline),
                color: const Color(0xFF1A237E),
                onPressed: () => onUpdateQuantity(item.quantity + 1),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            'カートは空です',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'お気に入りの料理を見つけましょう',
            style: TextStyle(
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              // ホームに戻るなどの処理
              // Navigator.of(context).pop(); // タブ切り替えなのでpopは微妙かも
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1A237E),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 32,
                vertical: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
            child: const Text('商品を探す'),
          ),
        ],
      ),
    );
  }
}
