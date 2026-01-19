// --- パスワード変更ダイアログ（リセット機能付き） ---
  void _showPasswordChangeDialog() {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
            title: const Center(
              child: Text('パスワード変更', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 8),
                _buildDialogTextField(
                  controller: _currentPwController,
                  label: '現在のパスワード',
                  visible: _isCurrentPwVisible,
                  onToggle: () => setDialogState(() => _isCurrentPwVisible = !_isCurrentPwVisible),
                ),
                const SizedBox(height: 16),
                _buildDialogTextField(
                  controller: _newPwController,
                  label: '新しいパスワード',
                  visible: _isNewPwVisible,
                  onToggle: () => setDialogState(() => _isNewPwVisible = !_isNewPwVisible),
                ),
                const SizedBox(height: 16),
                _buildDialogTextField(
                  controller: _confirmPwController,
                  label: 'パスワードの確認',
                  visible: _isConfirmPwVisible,
                  onToggle: () => setDialogState(() => _isConfirmPwVisible = !_isConfirmPwVisible),
                ),
              ],
            ),
            actionsPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            actions: [
              TextButton(
                onPressed: () {
                  // --- キャンセル時に全てリセット ---
                  _resetPasswordFields();
                  Navigator.pop(context);
                },
                child: const Text('キャンセル', style: TextStyle(color: Color(0xFF1A237E))),
              ),
              ElevatedButton(
                onPressed: _isChangingPassword
                    ? null
                    : () async {
                        if (_newPwController.text != _confirmPwController.text) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('新しいパスワードが一致しません')),
                          );
                          return;
                        }

                        setDialogState(() => _isChangingPassword = true);

                        try {
                          final authService = AuthService();
                          final token = await authService.getToken();

                          final response = await http.post(
                            Uri.parse('http://localhost:8000/auth/change-password'),
                            headers: {
                              'Content-Type': 'application/json',
                              'Authorization': 'Bearer $token',
                            },
                            body: jsonEncode({
                              'current_password': _currentPwController.text,
                              'new_password': _newPwController.text,
                            }),
                          );

                          if (response.statusCode == 200) {
                            if (mounted) {
                              // --- 成功時も全てリセットしてから閉じる ---
                              _resetPasswordFields();
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('パスワードを変更しました')),
                              );
                            }
                          } else {
                            throw Exception('変更に失敗しました');
                          }
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('エラー：パスワードを変更できませんでした')),
                            );
                          }
                        } finally {
                          if (mounted) {
                            setDialogState(() => _isChangingPassword = false);
                            setState(() => _isChangingPassword = false);
                          }
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A237E),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isChangingPassword
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('変更'),
              ),
            ],
          );
        },
      ),
    );
  }

  // --- 状態をデフォルトに戻す共通メソッド ---
  void _resetPasswordFields() {
    setState(() {
      // 入力内容をクリア
      _currentPwController.clear();
      _newPwController.clear();
      _confirmPwController.clear();
      // 表示状態（目のアイコン）を非表示に戻す
      _isCurrentPwVisible = false;
      _isNewPwVisible = false;
      _isConfirmPwVisible = false;
    });
  }