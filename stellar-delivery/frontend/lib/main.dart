import 'dart:math';

import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Stellar Delivery',
      theme: ThemeData(primarySwatch: Colors.indigo),
      home: const DeliveryHome(),
    );
  }
}

class Delivery {
  Delivery({required this.id, required this.address, this.delivered = false});
  final String id;
  final String address;
  bool delivered;
}

class DeliveryHome extends StatefulWidget {
  const DeliveryHome({super.key});

  @override
  State<DeliveryHome> createState() => _DeliveryHomeState();
}

class _DeliveryHomeState extends State<DeliveryHome> {
  final List<Delivery> _items = List.generate(
    5,
    (i) => Delivery(id: 'DLV-${1000 + i}', address: 'Tokyo - Chiyoda ${i + 1}'),
  );

  final Random _rnd = Random();

  void _addRandom() {
    final id = 'DLV-${1000 + _rnd.nextInt(9000)}';
    final addr = 'Tokyo - Shibuya ${1 + _rnd.nextInt(100)}';
    setState(() {
      _items.insert(0, Delivery(id: id, address: addr));
    });
  }

  void _toggleDelivered(int idx) {
    setState(() {
      _items[idx].delivered = !_items[idx].delivered;
    });
  }

  void _showDetails(Delivery d) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delivery ${d.id}'),
        content: Text('Address: ${d.address}\nStatus: ${d.delivered ? 'Delivered' : 'Pending'}'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Close')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stellar Delivery'),
        actions: [
          IconButton(icon: const Icon(Icons.add), onPressed: _addRandom, tooltip: 'Add random delivery'),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Today\'s deliveries', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Expanded(
              child: Card(
                child: ListView.separated(
                  itemCount: _items.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, idx) {
                    final d = _items[idx];
                    return ListTile(
                      leading: CircleAvatar(child: Text(d.id.split('-').last)),
                      title: Text(d.address),
                      subtitle: Text(d.delivered ? 'Delivered' : 'Pending'),
                      trailing: Wrap(spacing: 8, children: [
                        IconButton(
                          icon: Icon(d.delivered ? Icons.check_box : Icons.check_box_outline_blank),
                          onPressed: () => _toggleDelivered(idx),
                        ),
                        IconButton(icon: const Icon(Icons.info_outline), onPressed: () => _showDetails(d)),
                      ]),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addRandom,
        label: const Text('Add'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}
