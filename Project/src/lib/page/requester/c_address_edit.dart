import 'package:flutter/material.dart';

import '../../component/component.dart';
import '../../services/api_service.dart';

/// 住所編集画面（シンプル版）
class CAddressEditPage extends StatefulWidget {
  final String initialAddress;
  final String userRole;
  final int? addressId; // 編集時は既存のaddress ID

  const CAddressEditPage({
    super.key,
    this.initialAddress = '',
    this.userRole = 'requester',
    this.addressId,
  });

  @override
  State<CAddressEditPage> createState() => _CAddressEditPageState();
}

class _CAddressEditPageState extends State<CAddressEditPage> {
  late TextEditingController _addressController;
  final ApiService _apiService = ApiService();
  bool _isLoading = false;

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

  Future<void> _saveAddress() async {
    if (_addressController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('住所を入力してください')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final addressData = {
        'address_line1': _addressController.text.trim(),
        'is_default': true,
      };

      if (widget.addressId != null) {
        // 既存の住所を更新
        await _apiService.put('/profile/requester/addresses/${widget.addressId}', addressData);
      } else {
        // 新規作成
        await _apiService.post('/profile/requester/addresses', addressData);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('住所を保存しました')),
        );
        Navigator.pop(context, _addressController.text);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('住所の保存に失敗しました: $e')),
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
    return Scaffold(
      appBar: const TitleAppBar(
        title: '住所を編集',
        showBackButton: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '配達先住所',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _addressController,
              decoration: const InputDecoration(
                hintText: '例: 東京都渋谷区道玄坂1-2-3',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.location_on),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveAddress,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text(
                        '保存',
                        style: TextStyle(fontSize: 16),
                      ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'キャンセル',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}