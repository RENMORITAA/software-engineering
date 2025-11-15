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
  int _currentIndex = 0;

  void _addRandom() {
    final id = 'DLV-${1000 + _rnd.nextInt(9000)}';
    final addr = 'Tokyo - Shibuya ${1 + _rnd.nextInt(100)}';
    setState(() {
      _items.insert(0, Delivery(id: id, address: addr));
    });
  }

  void _showAddSheet() {
    final _addrCtl = TextEditingController();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Add Delivery', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              TextField(controller: _addrCtl, decoration: const InputDecoration(labelText: 'Address')),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () {
                  final addr = _addrCtl.text.trim();
                  if (addr.isEmpty) return;
                  final id = 'DLV-${1000 + _rnd.nextInt(9000)}';
                  setState(() => _items.insert(0, Delivery(id: id, address: addr)));
                  Navigator.of(ctx).pop();
                },
                child: const Text('Add'),
              )
            ],
          ),
        ),
      ),
    );
  }

  void _toggleDeliveredById(String id) {
    final idx = _items.indexWhere((e) => e.id == id);
    if (idx == -1) return;
    setState(() => _items[idx].delivered = !_items[idx].delivered);
  }

  void _showDetailsSheet(Delivery d) {
    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Delivery ${d.id}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text('Address: ${d.address}'),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text('Status: '),
                Chip(label: Text(d.delivered ? 'Delivered' : 'Pending')),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    _toggleDeliveredById(d.id);
                  },
                  child: Text(d.delivered ? 'Mark Pending' : 'Mark Delivered'),
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildDeliveries() {
    if (_items.isEmpty) {
      return const Center(child: Text('No deliveries'));
    }
    return ListView.separated(
      itemCount: _items.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, idx) {
        final d = _items[idx];
        return Dismissible(
          key: ValueKey(d.id),
          direction: DismissDirection.endToStart,
          background: Container(
            color: Colors.red,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          onDismissed: (direction) {
            final removed = d;
            setState(() => _items.removeAt(idx));
            ScaffoldMessenger.of(context).clearSnackBars();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Deleted ${removed.id}'),
                action: SnackBarAction(
                  label: 'Undo',
                  onPressed: () => setState(() => _items.insert(idx, removed)),
                ),
              ),
            );
          },
          child: ListTile(
            leading: CircleAvatar(child: Text(d.id.split('-').last)),
            title: Text(d.address),
            subtitle: Text(d.delivered ? 'Delivered' : 'Pending'),
            trailing: Checkbox(
              value: d.delivered,
              onChanged: (_) => _toggleDeliveredById(d.id),
            ),
            onTap: () => _showDetailsSheet(d),
            onLongPress: () => _showDetailsSheet(d),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stellar Delivery'),
        centerTitle: true,
        elevation: 2,
        actions: [
          IconButton(onPressed: _showAddSheet, icon: const Icon(Icons.add)),
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
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: _buildDeliveries(),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Deliveries'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddSheet,
        child: const Icon(Icons.add),
      ),
    );
  }
}
