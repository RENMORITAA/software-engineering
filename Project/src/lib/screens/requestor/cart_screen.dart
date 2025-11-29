import 'package:flutter/material.dart';
import '../../widgets/custom_button.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('カート')),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // カート内の商品リスト（仮）
                _CartItem(name: '唐揚げ弁当', price: 600, quantity: 1),
                _CartItem(name: 'お茶', price: 150, quantity: 2),
                const Divider(),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('合計', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      Text('¥900', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: CustomButton(
              text: '注文確認へ進む',
              onPressed: () {
                // 注文確認画面へ遷移
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _CartItem extends StatelessWidget {
  final String name;
  final int price;
  final int quantity;

  const _CartItem({required this.name, required this.price, required this.quantity});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(name),
      subtitle: Text('¥$price'),
      trailing: Text('x $quantity'),
    );
  }
}