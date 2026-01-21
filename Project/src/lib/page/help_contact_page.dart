import 'package:flutter/material.dart';
import 'dart:convert'; // JSON変換に必要
import 'package:shared_preferences/shared_preferences.dart'; // 保存に必要
import '../services/auth_service.dart';

class HelpContactPage extends StatefulWidget {
  const HelpContactPage({super.key});

  @override
  State<HelpContactPage> createState() => _HelpContactPageState();
}

class _HelpContactPageState extends State<HelpContactPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();
  final _contentController = TextEditingController();
  final String _adminEmail = 'kut.stellarworks@gmail.com';
  bool _isLoading = false;

  String? _selectedCategory;
  final List<String> _categories = [
    '依頼について',
    '配達について',
    '店舗情報・メニューについて', 
    '支払い・請求について',
    '振込みについて',
    '会員登録・退会について', 
    '規約・プライバシーについて',
    'アプリの不具合について',
    'その他',
  ];

  // 送信履歴リスト
  List<Map<String, String>> _history = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadHistory(); // 画面起動時に保存された履歴を読み込む
  }

  // --- 履歴をスマホ内に保存する ---
  Future<void> _saveHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedData = json.encode(_history);
    await prefs.setString('contact_history_key', encodedData);
  }

  // --- スマホ内から履歴を読み込む ---
  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final String? historyJson = prefs.getString('contact_history_key');
    if (historyJson != null) {
      setState(() {
        _history = List<Map<String, String>>.from(
          json.decode(historyJson).map((item) => Map<String, String>.from(item))
        );
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _confirmSend() {
    if (!_formKey.currentState!.validate()) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('送信の確認'),
        content: const Text('入力した内容で運営にメールを送信しますか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _sendEmail();
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1A237E)),
            child: const Text('送信する'),
          ),
        ],
      ),
    );
  }

  // --- 送信処理 ---
  Future<void> _sendEmail() async {
    setState(() => _isLoading = true);
    try {
      // 1. AuthService を呼び出して実際にメールを送信 (Backend連携)
      final bool success = await AuthService().sendContactEmail(
        category: _selectedCategory!,
        content: _contentController.text,
      );

      if (success && mounted) {
        setState(() {
          // 2. 履歴の先頭に追加
          _history.insert(0, {
            'date': '${DateTime.now().year}/${DateTime.now().month}/${DateTime.now().day}',
            'subject': _selectedCategory!,
            'status': '送信済み',
          });
        });

        // 3. 履歴をスマホに保存
        await _saveHistory();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('お問い合わせを送信しました')),
        );
        
        _contentController.clear();
        setState(() => _selectedCategory = null);
        _tabController.animateTo(1); // 履歴タブへ移動
      } else {
        throw Exception('送信に失敗しました');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('エラー: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ヘルプ・お問い合わせ'),
        backgroundColor: const Color(0xFF1A237E),
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.orange,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.orange,
          tabs: const [
            Tab(text: 'お問い合わせ'),
            Tab(text: '送信履歴'),
          ],
        ),
      ),
      body: Stack(
        children: [
          TabBarView(
            controller: _tabController,
            children: [
              _buildContactForm(),
              _buildHistoryList(),
            ],
          ),
          if (_isLoading)
            const Center(child: CircularProgressIndicator(color: Colors.orange)),
        ],
      ),
    );
  }

  Widget _buildContactForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('宛先', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(_adminEmail, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 24),
            const Text('カテゴリー', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              isExpanded: true,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.white,
                hintText: '選択してください',
              ),
              items: _categories.map((String category) {
                return DropdownMenuItem<String>(value: category, child: Text(category));
              }).toList(),
              onChanged: (String? newValue) => setState(() => _selectedCategory = newValue),
              validator: (value) => value == null ? '選択してください' : null,
            ),
            const SizedBox(height: 24),
            const Text('お問い合わせ内容', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextFormField(
              controller: _contentController,
              maxLines: 8,
              decoration: InputDecoration(
                hintText: '詳細を入力してください',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              validator: (value) => value == null || value.isEmpty ? '内容を入力してください' : null,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _confirmSend,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('送信内容を確認する', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryList() {
    if (_history.isEmpty) {
      return const Center(child: Text('送信履歴はありません'));
    }
    return ListView.builder(
      itemCount: _history.length,
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) {
        final item = _history[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            title: Text(item['subject']!, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(item['date']!),
            trailing: Chip(
              label: Text(item['status']!, style: const TextStyle(fontSize: 12, color: Colors.orange)),
              backgroundColor: Colors.orange[50],
            ),
          ),
        );
      },
    );
  }
}