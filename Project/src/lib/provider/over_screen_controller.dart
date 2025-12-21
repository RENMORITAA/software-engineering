import 'package:flutter/material.dart';

/// オーバースクリーン（オーバーレイ）の表示制御
/// 設計書に基づき、show() / hide() メソッドで制御する
class OverScreenController extends ChangeNotifier {
  bool _isVisible = false;
  Widget? _content;
  String? _screenType;

  // ゲッター
  bool get isVisible => _isVisible;
  Widget? get content => _content;
  String? get screenType => _screenType;

  /// オーバースクリーンを表示
  void show({
    required Widget content,
    String? screenType,
  }) {
    _content = content;
    _screenType = screenType;
    _isVisible = true;
    notifyListeners();
  }

  /// オーバースクリーンを非表示
  void hide() {
    _isVisible = false;
    _content = null;
    _screenType = null;
    notifyListeners();
  }

  /// ログアウト確認画面を表示
  void showLogout(VoidCallback onConfirm) {
    show(
      content: _buildConfirmDialog(
        title: 'ログアウト',
        message: 'ログアウトしますか？',
        confirmText: 'ログアウト',
        onConfirm: onConfirm,
      ),
      screenType: 'logout',
    );
  }

  /// 退会確認画面を表示
  void showWithdraw(VoidCallback onConfirm) {
    show(
      content: _buildConfirmDialog(
        title: '退会',
        message: '本当に退会しますか？\nこの操作は取り消せません。',
        confirmText: '退会する',
        confirmColor: Colors.red,
        onConfirm: onConfirm,
      ),
      screenType: 'withdraw',
    );
  }

  /// 変更キャンセル確認画面を表示
  void showCancelChange(VoidCallback onConfirm) {
    show(
      content: _buildConfirmDialog(
        title: '変更をキャンセル',
        message: '変更内容を破棄しますか？',
        confirmText: '破棄する',
        onConfirm: onConfirm,
      ),
      screenType: 'cancel_change',
    );
  }

  /// 変更確定確認画面を表示
  void showConfirmChange(VoidCallback onConfirm) {
    show(
      content: _buildConfirmDialog(
        title: '変更を確定',
        message: 'この内容で変更しますか？',
        confirmText: '確定する',
        onConfirm: onConfirm,
      ),
      screenType: 'confirm_change',
    );
  }

  /// 確認ダイアログを構築
  Widget _buildConfirmDialog({
    required String title,
    required String message,
    required String confirmText,
    Color confirmColor = const Color(0xFF1A237E),
    required VoidCallback onConfirm,
  }) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(32),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: hide,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('キャンセル'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      hide();
                      onConfirm();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: confirmColor,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(confirmText),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
