import 'package:flutter/material.dart';
import 'db_helper.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('講義アプリ: あああDB連携')),
        body: const TodoListScreen(),
      ),
    );
  }
}

class TodoListScreen extends StatefulWidget {
  const TodoListScreen({super.key});

  @override
  State<TodoListScreen> createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  final _dbHelper = DbHelper();
  List<Map<String, dynamic>> _todos = [];
  String _status = 'データを取得ボタンを押してください';

  Future<void> _fetchData() async {
    setState(() => _status = '読み込み中...');
    try {
      final data = await _dbHelper.getTodos();
      setState(() {
        _todos = data;
        _status = 'データ取得成功 (${data.length}件)';
      });
    } catch (e) {
      setState(() => _status = 'エラー: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(_status, style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _fetchData,
                child: const Text('DBからTODOを取得'),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _todos.length,
            itemBuilder: (context, index) {
              final todo = _todos[index];
              return ListTile(
                leading: Icon(
                  todo['is_done'] ? Icons.check_box : Icons.check_box_outline_blank,
                  color: todo['is_done'] ? Colors.green : Colors.grey,
                ),
                title: Text(todo['title']),
              );
            },
          ),
        ),
      ],
    );
  }
}