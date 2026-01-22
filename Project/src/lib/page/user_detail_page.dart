import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../provider/change_user_role.dart';
import '../services/auth_service.dart';

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
  bool _isLoading = false;
  final AuthService _authService = AuthService();
  final ImagePicker _picker = ImagePicker();
  XFile? _pickedImage;
  String? _serverImageUrl;

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;

  late String _selectedTransport;
  final List<String> _transportOptions = ['車', 'バイク', '自転車', '徒歩'];

  late TextEditingController _storeNameController;
  late TextEditingController _storeAddressController;
  late TextEditingController _storeDescriptionController;
  late TextEditingController _businessHoursController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.userName);
    _emailController = TextEditingController(text: widget.userEmail);
    _phoneController = TextEditingController();
    _storeNameController = TextEditingController();
    _storeAddressController = TextEditingController();
    _storeDescriptionController = TextEditingController();
    _businessHoursController = TextEditingController();
    _selectedTransport = '徒歩';

    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final savedInfo = await _authService.getSavedUserInfo();
    final info = savedInfo ?? widget.additionalInfo ?? {};

    if (mounted) {
      setState(() {
        if (info['name'] != null) _nameController.text = info['name'].toString();
        if (info['email'] != null) _emailController.text = info['email'].toString();
        
        final phone = info['phone_number'] ?? info['phoneNumber'] ?? info['phone'];
        if (phone != null) _phoneController.text = phone.toString();

        if (widget.userRole == 'deliverer') {
          _selectedTransport = _mapVehicleType(info['vehicle_type']?.toString() ?? 'walk');
        } else if (widget.userRole == 'store') {
          _storeNameController.text = info['store_name']?.toString() ?? '';
          _storeAddressController.text = info['address']?.toString() ?? '';
          _storeDescriptionController.text = info['description']?.toString() ?? '';
          _businessHoursController.text = info['business_hours']?.toString() ?? '';
        }

        String? imagePath = (widget.userRole == 'deliverer') ? info['resume_image'] : info['license_image'];
        if (imagePath != null && imagePath.isNotEmpty) {
          final host = kIsWeb ? "127.0.0.1" : "10.0.2.2";
          _serverImageUrl = "http://$host:8000$imagePath";
        }
      });
    }
  }

  String _mapVehicleType(String type) {
    switch (type) {
      case 'car': return '車';
      case 'motorcycle': return 'バイク';
      case 'bicycle': return '自転車';
      case 'walk': return '徒歩';
      default: return '徒歩';
    }
  }

  String _reverseMapVehicle(String val) {
    if (val == '車') return 'car';
    if (val == 'バイク') return 'motorcycle';
    if (val == '自転車') return 'bicycle';
    return 'walk';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _storeNameController.dispose();
    _storeAddressController.dispose();
    _storeDescriptionController.dispose();
    _businessHoursController.dispose();
    super.dispose();
  }

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
              Navigator.pop(context);
              _saveProfile();
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

  Future<void> _saveProfile() async {
    setState(() => _isLoading = true);
    try {
      final data = {
        'name': _nameController.text,
        'email': _emailController.text, // 追加
        'phone_number': _phoneController.text,
      };
      if (widget.userRole == 'deliverer') {
        data['vehicle_type'] = _reverseMapVehicle(_selectedTransport);
      } else if (widget.userRole == 'store') {
        data['store_name'] = _storeNameController.text;
        data['address'] = _storeAddressController.text;
        data['description'] = _storeDescriptionController.text;
        data['business_hours'] = _businessHoursController.text;
      }

      // API実行
      await _authService.updateProfile(
        role: widget.userRole,
        data: data,
        imageFile: _pickedImage,
      );

      // 成功した場合のUIリセット
      if (mounted) {
        setState(() {
          _isEditing = false;
          _pickedImage = null;
        });
        await _loadInitialData(); // サーバーから最新データを再ロード
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('情報を更新しました')));
      }
    } catch (e) {
      debugPrint('Update Error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('エラーが発生しました: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      // 成功・失敗に関わらずローディングを停止
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
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: const Text('会員情報'),
            backgroundColor: const Color(0xFF1A237E),
            foregroundColor: Colors.white,
            actions: [
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

                if (widget.userRole == 'store') ...[
                  const SizedBox(height: 20),
                  _buildSectionTitle('店舗情報'),
                  _buildCustomField('店舗名', _storeNameController),
                  _buildCustomField('住所', _storeAddressController),
                  _buildCustomField('店舗説明', _storeDescriptionController),
                  _buildCustomField('営業時間', _businessHoursController),
                  _buildUploadField('営業許可証'),
                ],
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
        if (_isLoading)
          Container(color: Colors.black45, child: const Center(child: CircularProgressIndicator(color: Colors.orange))),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A237E))),
    );
  }

  Widget _buildCustomField(String label, TextEditingController controller, {bool enabled = true}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextField(
        controller: controller,
        enabled: _isEditing && enabled,
        style: const TextStyle(color: Colors.black, fontSize: 16),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.black87),
          floatingLabelBehavior: FloatingLabelBehavior.always,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
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
                  value: _transportOptions.contains(_selectedTransport) ? _selectedTransport : '徒歩',
                  isExpanded: true,
                  onChanged: (val) => setState(() => _selectedTransport = val!),
                  items: _transportOptions.map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
                ),
              )
            : Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text(_selectedTransport, style: const TextStyle(fontSize: 16, color: Colors.black)),
              ),
      ),
    );
  }

  Widget _buildUploadField(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: InkWell(
        onTap: _isEditing ? _pickImage : null,
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
          child: Container(
            constraints: const BoxConstraints(minHeight: 100),
            alignment: Alignment.center,
            child: _buildImageContent(),
          ),
        ),
      ),
    );
  }

  Widget _buildImageContent() {
    if (_pickedImage != null) {
      return kIsWeb ? Image.network(_pickedImage!.path, height: 120) : Image.file(File(_pickedImage!.path), height: 120);
    }
    if (_serverImageUrl != null) {
      return Image.network('$_serverImageUrl?t=${DateTime.now().millisecondsSinceEpoch}', height: 120);
    }
    return const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.add_a_photo, color: Colors.grey),
        SizedBox(width: 8),
        Text('画像をアップロード', style: TextStyle(color: Colors.grey)),
      ],
    );
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) setState(() => _pickedImage = image);
  }
}