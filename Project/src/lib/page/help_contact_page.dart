import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
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

  List<Map<String, String>> _history = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadHistory();
  }

  Future<void> _saveHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedData = json.encode(_history);
    await prefs.setString('contact_history_key', encodedData);
  }

  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final String? historyJson = prefs.getString('contact_history_key');
    if (historyJson != null) {
      setState(() {
        _history = List<Map<String, String>>.from(
            json.decode(historyJson).map((item) => Map<String, String>.from(item)));
      });
    }
  }

  // --- 追加：古い履歴（内容なしデータ）を消去するためのリセット機能 ---
  Future<void> _clearHistory() async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('履歴の削除'),
        content: const Text('すべての送信履歴を削除しますか？'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('キャンセル')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('削除する', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('contact_history_key');
      setState(() => _history = []);
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
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('キャンセル', style: TextStyle(color: Colors.grey))),
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

  Future<void> _sendEmail() async {
    setState(() => _isLoading = true);
    try {
      final bool success = await AuthService().sendContactEmail(
        category: _selectedCategory!,
        content: _contentController.text,
      );

      if (success && mounted) {
        setState(() {
          _history.insert(0, {
            'date': '${DateTime.now().year}/${DateTime.now().month}/${DateTime.now().day}',
            'subject': _selectedCategory!,
            'content': _contentController.text, // ここで本文を確実に保存
            'status': '送信済み',
          });
        });
        await _saveHistory();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('お問い合わせを送信しました')));
        _contentController.clear();
        setState(() => _selectedCategory = null);
        _tabController.animateTo(1);
      } else {
        throw Exception('送信に失敗しました');
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('エラー: $e'), backgroundColor: Colors.red));
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
        actions: [
          // 履歴タブにいる時だけ削除ボタンを表示
          if (_tabController.index == 1 && _history.isNotEmpty)
            IconButton(onPressed: _clearHistory, icon: const Icon(Icons.delete_sweep_outlined)),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.orange,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.orange,
          onTap: (index) => setState(() {}), // アイコン表示切り替えのため
          tabs: const [Tab(text: 'お問い合わせ'), Tab(text: '送信履歴')],
        ),
      ),
      body: Stack(
        children: [
          TabBarView(
            controller: _tabController,
            children: [_buildContactForm(), _buildHistoryList()],
          ),
          if (_isLoading) const Center(child: CircularProgressIndicator(color: Colors.orange)),
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
              items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
              onChanged: (val) => setState(() => _selectedCategory = val),
              validator: (val) => val == null ? '選択してください' : null,
            ),
            const SizedBox(height: 24),
            const Text('お問い合わせ内容', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextFormField(
              controller: _contentController,
              maxLines: 8,
              decoration: InputDecoration(hintText: '詳細を入力してください', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
              validator: (val) => val == null || val.isEmpty ? '内容を入力してください' : null,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _confirmSend,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: const Text('送信内容を確認する', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryList() {
    if (_history.isEmpty) return const Center(child: Text('送信履歴はありません'));
    return ListView.builder(
      itemCount: _history.length,
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) {
        final item = _history[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            onTap: () => _showHistoryDetail(item),
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

  void _showHistoryDetail(Map<String, String> item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
        contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
        title: const Text('お問い合わせ詳細', style: TextStyle(fontWeight: FontWeight.bold)),
        content: SizedBox(
          width: MediaQuery.of(context).size.width * 0.85,
          child: SingleChildScrollView(
            child: ListBody(
              children: [
                _detailRow('送信日', item['date']!),
                _detailRow('カテゴリー', item['subject']!),
                const SizedBox(height: 20),
                const Text('内容:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  constraints: const BoxConstraints(minHeight: 150),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    border: Border.all(color: Colors.grey[200]!),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    item['content'] ?? '（この履歴には内容が保存されていません）',
                    style: const TextStyle(fontSize: 15, height: 1.5),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('閉じる', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 80, child: Text(label, style: const TextStyle(color: Colors.grey))),
          Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }
}