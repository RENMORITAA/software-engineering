import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/change_user_role.dart';

class UserDetailPage extends StatefulWidget {
  final String userName;
  final String userEmail;
  final String userRole;
  final Map<String, dynamic>? additionalInfo;

  const UserDetailPage({
    super.key,
    required this.userName,
    required this.userEmail,
    required this.userRole,
    this.additionalInfo,
  });

  @override
  State<UserDetailPage> createState() => _UserDetailPageState();
}

class _UserDetailPageState extends State<UserDetailPage> {
  bool _isEditing = false;

  // 各入力項目のコントローラー
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;

  late String _selectedTransport;
  final List<String> _transportOptions = ['自動車', 'バイク', '軽自動車', '徒歩'];
  
  late TextEditingController _storeNameController;
  late TextEditingController _storeAddressController;
  late TextEditingController _storeDescriptionController;
  late TextEditingController _openingHoursController;

  @override
  void initState() {
    super.initState();
    // 引数で受け取ったデータをコントローラーの初期値としてセット
    final info = widget.additionalInfo ?? {};
    _nameController = TextEditingController(text: widget.userName);
    _emailController = TextEditingController(text: widget.userEmail);
    _phoneController = TextEditingController(text: info['phone_number']?.toString() ?? '');
    
    // 配達手段の初期値
    _selectedTransport = _mapVehicleType(info['vehicle_type']?.toString() ?? 'walk');
    
    // 店舗用初期値
    _storeNameController = TextEditingController(text: info['store_name']?.toString() ?? '');
    _storeAddressController = TextEditingController(text: info['store_address']?.toString() ?? '');
    _storeDescriptionController = TextEditingController(text: info['store_description']?.toString() ?? '');
    _openingHoursController = TextEditingController(text: info['business_hours']?.toString() ?? '');
  }

  // 内部的な値を日本語に変換するヘルパー
  String _mapVehicleType(String type) {
    switch (type) {
      case 'car': return '自動車';
      case 'motorcycle': return 'バイク';
      case 'bicycle': return '自転車'; 
      case 'walk': return '徒歩';
      default: return '徒歩';
    }
  }

  @override
  void dispose() {
    // 全てのコントローラーを破棄
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _storeNameController.dispose();
    _storeAddressController.dispose();
    _storeDescriptionController.dispose();
    _openingHoursController.dispose();
    super.dispose();
  }

  // 以前の確定/キャンセルボタンのデザインを再現したダイアログ
  void _showConfirmDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text('変更の確定', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('入力した内容で会員情報を更新しますか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              // --- Providerのデータを更新 ---
              final userProvider = Provider.of<UserRoleProvider>(context, listen: false);
              userProvider.updateProfile(
                name: _nameController.text,
                phoneNumber: _phoneController.text,
                storeName: _storeNameController.text,
                storeAddress: _storeAddressController.text,
                vehicleType: widget.userRole == 'deliverer' ? _selectedTransport : null,
              );

              Navigator.pop(context);
              setState(() => _isEditing = false);
              
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('情報を更新しました')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1A237E),
              foregroundColor: Colors.white,
            ),
            child: const Text('確定する'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('会員情報'),
        backgroundColor: const Color(0xFF1A237E),
        foregroundColor: Colors.white,
        actions: [
          if (_isEditing)
            const Center(child: Text('変更中：', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold))),
          TextButton(
            onPressed: () => _isEditing ? _showConfirmDialog() : setState(() => _isEditing = true),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(_isEditing ? Icons.check_circle : Icons.edit, color: _isEditing ? Colors.orange : Colors.white),
                Text(_isEditing ? '完了' : '変更', style: TextStyle(color: _isEditing ? Colors.orange : Colors.white, fontSize: 10)),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // オレンジバー
            if (_isEditing)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.edit_note, color: Colors.orange),
                    SizedBox(width: 8),
                    Text('現在情報を変更中です', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),

            _buildSectionTitle('基本情報'),
            _buildCustomField('名前', _nameController),
            _buildCustomField('メールアドレス', _emailController),
            _buildCustomField('電話番号', _phoneController),

            if (widget.userRole == 'deliverer') ...[
              const SizedBox(height: 20),
              _buildSectionTitle('配達員情報'),
              _buildDropdownField('配達手段', _selectedTransport),
              _buildUploadField('履歴書'),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A237E))),
    );
  }

  // 枠線を黒(black87)に統一したフィールド
  Widget _buildCustomField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextField(
        controller: controller,
        enabled: _isEditing,
        style: const TextStyle(color: Colors.black, fontSize: 16),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.black87),
          floatingLabelBehavior: FloatingLabelBehavior.always,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          // 非編集時も黒い枠線を表示
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.black87),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.black87),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildDropdownField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.black87),
          floatingLabelBehavior: FloatingLabelBehavior.always,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.black87),
          ),
        ),
        child: _isEditing
            ? DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _transportOptions.contains(value) ? value : _transportOptions.last,
                  isExpanded: true,
                  onChanged: (val) => setState(() => _selectedTransport = val!),
                  items: _transportOptions.map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
                ),
              )
            : Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(value, style: const TextStyle(fontSize: 16, color: Colors.black)),
              ),
      ),
    );
  }

  Widget _buildUploadField(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.black87),
          floatingLabelBehavior: FloatingLabelBehavior.always,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.black87),
          ),
        ),
        child: const Padding(
          padding: EdgeInsets.symmetric(vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_a_photo, color: Colors.grey),
              SizedBox(width: 8),
              Text('画像をアップロード', style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }
}