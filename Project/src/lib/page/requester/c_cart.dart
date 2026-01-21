import "package:flutter/material.dart";
import "package:provider/provider.dart";

import "../../component/component.dart";
import "../../page/requester/c_order_confirmation.dart";
import "../../provider/cart_provider.dart";
import "../../provider/order_provider.dart";

class CCartPage extends StatelessWidget {
  const CCartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TitleAppBar(
        title: 'カート',
        showBackButton: false,
      ),
      body: Consumer2<CartProvider, OrderProvider>(
        builder: (context, cartProvider, orderProvider, _) {
          if (cartProvider.isEmpty) {
            return const Center(
              child: Text('カートは空です'),
            );
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: cartProvider.items.length,
                  itemBuilder: (context, index) {
                    final item = cartProvider.items[index];
                    return _CartItemTile(item: item, cartProvider: cartProvider);
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildSummaryRow('小計', cartProvider.subtotal),
                      const SizedBox(height: 8),
                      _buildSummaryRow('配達料', cartProvider.deliveryFee),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Divider(),
                      ),
                      _buildSummaryRow('合計', cartProvider.totalPrice, isTotal: true),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: orderProvider.isLoading
                              ? null
                              : () async {
                                  final storeId = cartProvider.selectedStoreId;
                                  final details = cartProvider.buildOrderDetailsPayload();

                                  if (storeId == null) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('店舗情報が取得できません')),
                                    );
                                    return;
                                  }

                                  if (details.isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('商品情報が不足しています')),
                                    );
                                    return;
                                  }

                                  final address = cartProvider.deliveryAddress.isEmpty
                                      ? '住所未設定'
                                      : cartProvider.deliveryAddress;

                                  final payload = {
                                    'store_id': storeId,
                                    'delivery_address': address,
                                    'delivery_latitude': null,
                                    'delivery_longitude': null,
                                    'notes': cartProvider.notes.isEmpty ? null : cartProvider.notes,
                                    'details': details,
                                  };

                                  final orderId = await orderProvider.createOrder(payload);

                                  if (orderId != null) {
                                    final storeName = cartProvider.selectedStoreName ?? '店舗';
                                    final totalPrice = cartProvider.totalPrice;

                                    // 履歴に即時反映（createOrder 内で再取得済み）
                                    cartProvider.clear();

                                    if (!context.mounted) return;

                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => COrderConfirmationPage(
                                          orderId: orderId,
                                          storeName: storeName,
                                          totalPrice: totalPrice,
                                        ),
                                      ),
                                    );
                                  } else {
                                    final error = orderProvider.error ?? '注文の作成に失敗しました';
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(error)),
                                    );
                                  }
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
          );
        },
      ),
    );
  }

  Widget _buildSummaryRow(String label, int value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 18 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          '$value',
          style: TextStyle(
            fontSize: isTotal ? 24 : 16,
            fontWeight: FontWeight.bold,
            color: isTotal ? const Color(0xFF1A237E) : Colors.black,
          ),
        ),
      ],
    );
  }
}

class _CartItemTile extends StatelessWidget {
  final CartItem item;
  final CartProvider cartProvider;

  const _CartItemTile({required this.item, required this.cartProvider});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.fastfood, color: Colors.grey),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.product.name,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text('${item.product.price}'),
              ],
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.remove_circle_outline),
                onPressed: () => cartProvider.updateQuantity(item.product.id!, item.quantity - 1),
              ),
              Text('${item.quantity}', style: const TextStyle(fontWeight: FontWeight.bold)),
              IconButton(
                icon: const Icon(Icons.add_circle_outline),
                onPressed: () => cartProvider.updateQuantity(item.product.id!, item.quantity + 1),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
