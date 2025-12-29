import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../component/component.dart';
import '../../provider/provider.dart';
import '../../models/database_models.dart';
import '../../services/profile_service.dart';

/// 住所管理画面
class CAddressManagementPage extends StatefulWidget {
  const CAddressManagementPage({super.key});

  @override
  State<CAddressManagementPage> createState() => _CAddressManagementPageState();
}

class _CAddressManagementPageState extends State<CAddressManagementPage> {
  final ProfileService _profileService = ProfileService();
  List<RequesterAddress> _addresses = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAddresses();
  }

  Future<void> _fetchAddresses() async {
    setState(() => _isLoading = true);
    try {
      final response = await _profileService.getRequesterAddresses();
      _addresses = response.map((data) => RequesterAddress.fromMap(data)).toList();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('住所の取得に失敗しました: $e')),
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
        title: '住所管理',
        showBackButton: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _addresses.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _addresses.length,
                  itemBuilder: (context, index) {
                    return _buildAddressCard(_addresses[index]);
                  },
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddAddressDialog(),
        backgroundColor: Theme.of(context).primaryColor,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('住所を追加', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.location_off_outlined,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            '登録された住所がありません',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showAddAddressDialog(),
            icon: const Icon(Icons.add),
            label: const Text('住所を追加'),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressCard(RequesterAddress address) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: address.isDefault
            ? Border.all(color: Theme.of(context).primaryColor, width: 2)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: address.isDefault
                      ? Theme.of(context).primaryColor
                      : Colors.grey[200],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  address.label,
                  style: TextStyle(
                    fontSize: 12,
                    color: address.isDefault ? Colors.white : Colors.grey[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              if (address.isDefault) ...[
                const SizedBox(width: 8),
                const Text(
                  'デフォルト',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.green,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
              const Spacer(),
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'edit') {
                    _showEditAddressDialog(address);
                  } else if (value == 'delete') {
                    _confirmDeleteAddress(address);
                  } else if (value == 'default') {
                    _setDefaultAddress(address);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit, size: 18),
                        SizedBox(width: 8),
                        Text('編集'),
                      ],
                    ),
                  ),
                  if (!address.isDefault)
                    const PopupMenuItem(
                      value: 'default',
                      child: Row(
                        children: [
                          Icon(Icons.check_circle, size: 18),
                          SizedBox(width: 8),
                          Text('デフォルトに設定'),
                        ],
                      ),
                    ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, size: 18, color: Colors.red),
                        SizedBox(width: 8),
                        Text('削除', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.location_on, color: Colors.grey[400], size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '〒${address.postalCode}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${address.prefecture}${address.city}${address.addressLine1}',
                      style: const TextStyle(fontSize: 14),
                    ),
                    if (address.addressLine2 != null &&
                        address.addressLine2!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        address.addressLine2!,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showAddAddressDialog() {
    _showAddressFormDialog(null);
  }

  void _showEditAddressDialog(RequesterAddress address) {
    _showAddressFormDialog(address);
  }

  void _showAddressFormDialog(RequesterAddress? address) {
    final isEdit = address != null;
    final labelController = TextEditingController(text: address?.label ?? '自宅');
    final postalCodeController =
        TextEditingController(text: address?.postalCode ?? '');
    final prefectureController =
        TextEditingController(text: address?.prefecture ?? '');
    final cityController = TextEditingController(text: address?.city ?? '');
    final addressLine1Controller =
        TextEditingController(text: address?.addressLine1 ?? '');
    final addressLine2Controller =
        TextEditingController(text: address?.addressLine2 ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEdit ? '住所を編集' : '住所を追加'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: labelController,
                decoration: const InputDecoration(
                  labelText: 'ラベル（自宅、会社など）',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: postalCodeController,
                decoration: const InputDecoration(
                  labelText: '郵便番号',
                  border: OutlineInputBorder(),
                  hintText: '123-4567',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: prefectureController,
                decoration: const InputDecoration(
                  labelText: '都道府県',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: cityController,
                decoration: const InputDecoration(
                  labelText: '市区町村',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: addressLine1Controller,
                decoration: const InputDecoration(
                  labelText: '番地',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: addressLine2Controller,
                decoration: const InputDecoration(
                  labelText: '建物名・部屋番号（任意）',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          ElevatedButton(
            onPressed: () async {
              final addressData = {
                'label': labelController.text,
                'postal_code': postalCodeController.text,
                'prefecture': prefectureController.text,
                'city': cityController.text,
                'address_line1': addressLine1Controller.text,
                'address_line2': addressLine2Controller.text,
              };

              try {
                await _profileService.addRequesterAddress(addressData);
                if (mounted) {
                  Navigator.pop(context);
                  _fetchAddresses();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(isEdit ? '住所を更新しました' : '住所を追加しました')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('エラー: $e')),
                  );
                }
              }
            },
            child: Text(isEdit ? '更新' : '追加'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteAddress(RequesterAddress address) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('住所を削除'),
        content: const Text('この住所を削除してもよろしいですか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              try {
                if (address.id != null) {
                  await _profileService.deleteRequesterAddress(address.id!);
                  if (mounted) {
                    Navigator.pop(context);
                    _fetchAddresses();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('住所を削除しました')),
                    );
                  }
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('エラー: $e')),
                  );
                }
              }
            },
            child: const Text('削除'),
          ),
        ],
      ),
    );
  }

  void _setDefaultAddress(RequesterAddress address) {
    // TODO: APIでデフォルト住所を設定
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('デフォルト住所に設定しました')),
    );
    _fetchAddresses();
  }
}
