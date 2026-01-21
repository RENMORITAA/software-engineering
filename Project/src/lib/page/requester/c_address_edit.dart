import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class AddressEditPage extends StatefulWidget {
  final String initialAddress;
  final String userRole; // store / deliverer など

  const AddressEditPage({
    super.key,
    required this.initialAddress,
    required this.userRole,
  });

  @override
  State<AddressEditPage> createState() => _AddressEditPageState();
}

class _AddressEditPageState extends State<AddressEditPage> {
  bool _isEditing = false;
  bool _isLoading = false;

  final AuthService _authService = AuthService();
  late TextEditingController _addressController;

  @override
  void initState() {
    super.initState();
    _addressController = TextEditingController(text: widget.initialAddress);
  }

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  void _showConfirmDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('住所の変更'),
        content: const Text('この内容で住所を更新しますか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _saveAddress();
            },
            child: const Text('更新する'),
          ),
        ],
      ),
    );
  }

  Future<void> _saveAddress() async {
    setState(() => _isLoading = true);

    try {
      await _authService.updateProfile(
        role: widget.userRole,
        data: {
          'address': _addressController.text,
        },
      );

      if (mounted) {
        setState(() => _isEditing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('住所を更新しました')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('エラーが発生しました: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: const Text('住所'),
            actions: [
              TextButton(
                onPressed: () {
                  if (_isEditing) {
                    _showConfirmDialog();
                  } else {
                    setState(() => _isEditing = true);
                  }
                },
                child: Text(
                  _isEditing ? '完了' : '変更',
                  style: TextStyle(
                    color: _isEditing ? Colors.orange : Colors.white,
                  ),
                ),
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_isEditing)
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      '住所を編集中です',
                      style: TextStyle(color: Colors.orange),
                    ),
                  ),

                TextField(
                  controller: _addressController,
                  enabled: _isEditing,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: '住所',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
        ),

        if (_isLoading)
          Container(
            color: Colors.black45,
            child: const Center(child: CircularProgressIndicator()),
          ),
      ],
    );
  }
}
