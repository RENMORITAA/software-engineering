import 'package:flutter/material.dart';
import '../component/component.dart';
import '../services/auth_service.dart';

class BankingInfoPage extends StatefulWidget {
  final String role;
  const BankingInfoPage({super.key, required this.role});

  @override
  State<BankingInfoPage> createState() => _BankingInfoPageState();
}

class _BankingInfoPageState extends State<BankingInfoPage> {
  final _formKey = GlobalKey<FormState>();
  final _bankNameController = TextEditingController();
  final _branchController = TextEditingController();
  final _accNumberController = TextEditingController();
  final _accHolderController = TextEditingController();
  String _selectedAccType = '普通';

  bool _isLoading = false;
  bool _isEditing = false;
  bool _isNotRegistered = true;
  final _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _loadBankingData();
  }

  // 1. データの読み込みとモード判定
  Future<void> _loadBankingData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    
    try {
      // サーバーから最新のプロフィールを取得
      Map<String, dynamic>? profile = await _authService.getUserProfile();
      
      // サーバーが空ならローカルキャッシュを確認
      if (profile == null || profile['bank_account_number'] == null) {
        profile = await _authService.getSavedUserInfo();
      }

      // デバッグログ：もしデータが消えるなら、VSCode等のコンソールに何が出ているか確認してください
      debugPrint("Load Banking Data: $profile");

      if (profile != null &&
          profile['bank_account_number'] != null &&
          profile['bank_account_number'].toString().trim().isNotEmpty) {
        
        setState(() {
          _bankNameController.text = profile!['bank_name'] ?? '';
          _branchController.text = profile['bank_branch'] ?? '';
          _accNumberController.text = profile['bank_account_number'] ?? '';
          _accHolderController.text = profile['bank_account_holder'] ?? '';
          _selectedAccType = profile['bank_account_type'] ?? '普通';
          _isNotRegistered = false; // 登録済み
          _isEditing = false;      // 閲覧モードへ
        });
      } else {
        setState(() {
          _isNotRegistered = true; // 未登録
          _isEditing = true;       // 最初から編集モード
        });
      }
    } catch (e) {
      debugPrint("データ読み込み失敗: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // 2. 保存処理
  Future<void> _handleSave() async {
    setState(() => _isLoading = true);
    try {
      final bankingData = {
        'bank_name': _bankNameController.text,
        'bank_branch': _branchController.text,
        'bank_account_type': _selectedAccType,
        'bank_account_number': _accNumberController.text,
        'bank_account_holder': _accHolderController.text,
      };

      await _authService.updateBankingInfo(
        role: widget.role,
        data: bankingData,
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('口座情報を更新しました'))
        );
        
        // 保存直後にデータを再読み込みしてモードを切り替える
        await _loadBankingData();
        
        setState(() {
          _isEditing = false;
          _isNotRegistered = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('エラー: $e'), backgroundColor: Colors.red)
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showConfirmDialog() {
    if (!_formKey.currentState!.validate()) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text('変更の確定', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('入力した内容で口座情報を保存しますか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _handleSave(); 
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
    return Stack(
      children: [
        Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: Text('${_getRoleName(widget.role)} 口座情報'),
            backgroundColor: const Color(0xFF1A237E),
            foregroundColor: Colors.white,
            actions: [
              TextButton(
                onPressed: () => _isEditing ? _showConfirmDialog() : setState(() => _isEditing = true),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _isEditing ? Icons.check_circle : Icons.edit,
                      color: _isEditing ? Colors.orange : Colors.white,
                      size: 20,
                    ),
                    Text(
                      _isEditing ? '完了' : '変更',
                      style: TextStyle(
                        color: _isEditing ? Colors.orange : Colors.white,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          body: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
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
                          child: Row(
                            children: [
                              const Icon(Icons.edit_note, color: Colors.orange),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _isNotRegistered ? '口座情報を登録してください' : '現在情報を変更中です',
                                  style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        ),

                      _buildSectionTitle(_getSectionTitle(widget.role)),
                      _isEditing ? _buildEditForm() : _buildPreview(),
                    ],
                  ),
                ),
        ),
        if (_isLoading)
          Container(
            color: Colors.black45, 
            child: const Center(child: CircularProgressIndicator(color: Colors.orange))
          ),
      ],
    );
  }

  // --- UI Parts ---

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A237E))),
    );
  }

  Widget _buildEditForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          _buildTextField('金融機関名', '例：〇〇銀行', _bankNameController),
          _buildTextField('支店名', '例：△△支店', _branchController),
          _buildDropdownField('口座種別'),
          _buildTextField('口座番号', '7桁の半角数字', _accNumberController, isNumber: true),
          _buildTextField('口座名義（カナ）', '例：ヤマダ タロウ', _accHolderController),
          const SizedBox(height: 24),
          if (!_isNotRegistered)
            TextButton(
              onPressed: () => setState(() => _isEditing = false),
              child: const Text('変更をキャンセル', style: TextStyle(color: Colors.grey)),
            ),
        ],
      ),
    );
  }

  Widget _buildPreview() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        children: [
          _buildDataRow('金融機関名', _bankNameController.text),
          const Divider(),
          _buildDataRow('支店名', _branchController.text),
          const Divider(),
          _buildDataRow('口座種別', _selectedAccType),
          const Divider(),
          _buildDataRow('口座番号', _accNumberController.text),
          const Divider(),
          _buildDataRow('口座名義', _accHolderController.text),
        ],
      ),
    );
  }

  // --- Helper Methods ---

  Widget _buildTextField(String label, String hint, TextEditingController controller, {bool isNumber = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          floatingLabelBehavior: FloatingLabelBehavior.always,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        validator: (value) => (value == null || value.trim().isEmpty) ? '必須項目です' : null,
      ),
    );
  }

  Widget _buildDropdownField(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: DropdownButtonFormField<String>(
        value: _selectedAccType,
        decoration: InputDecoration(
          labelText: label,
          floatingLabelBehavior: FloatingLabelBehavior.always,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        items: ['普通', '当座'].map((type) => DropdownMenuItem(value: type, child: Text(type))).toList(),
        onChanged: (val) => setState(() => _selectedAccType = val!),
      ),
    );
  }

  Widget _buildDataRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.black54, fontSize: 14)),
          Text(value.isEmpty ? '未設定' : value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  String _getSectionTitle(String role) {
    return (role == 'requester') ? 'お支払い口座' : 'お振込先口座';
  }

  String _getRoleName(String role) {
    switch (role) {
      case 'requester': return '依頼者';
      case 'store': return '店舗';
      case 'deliverer': return '配達員';
      default: return '';
    }
  }
}