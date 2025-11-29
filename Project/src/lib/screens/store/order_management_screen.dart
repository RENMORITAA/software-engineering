import 'package:flutter/material.dart';

class OrderManagementScreen extends StatelessWidget {
  const OrderManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // タブでステータスを切り替えられるようにする
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('注文管理'),
          bottom: const TabBar(
            tabs: [
              Tab(text: '新規受注'),
              Tab(text: '調理中'),
              Tab(text: '受け渡し待'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _OrderList(status: 'new'),
            _OrderList(status: 'cooking'),
            _OrderList(status: 'ready'),
          ],
        ),
      ),
    );
  }
}

class _OrderList extends StatelessWidget {
  final String status;
  const _OrderList({required this.status});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 3,
      itemBuilder: (context, index) {
        return Card(
          child: Column(
            children: [
              ListTile(
                title: Text('注文番号 #100$index'),
                subtitle: const Text('唐揚げ弁当 x 2'),
                trailing: Text(status == 'new' ? '10:30 受注' : '進行中'),
              ),
              ButtonBar(
                children: [
                  if (status == 'new')
                    ElevatedButton(onPressed: () {}, child: const Text('受注する')),
                  if (status == 'cooking')
                    ElevatedButton(onPressed: () {}, child: const Text('調理完了')),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}