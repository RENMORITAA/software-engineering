import 'package:flutter/material.dart';

/// エラーダイアログ
class ErrorDialog extends StatelessWidget {
  final String title;
  final String message;
  final String? buttonText;
  final VoidCallback? onPressed;
  final bool showRetry;
  final VoidCallback? onRetry;

  const ErrorDialog({
    super.key,
    this.title = 'エラー',
    required this.message,
    this.buttonText,
    this.onPressed,
    this.showRetry = false,
    this.onRetry,
  });

  /// エラーダイアログを表示
  static Future<void> show(
    BuildContext context, {
    String title = 'エラー',
    required String message,
    String? buttonText,
    VoidCallback? onPressed,
    bool showRetry = false,
    VoidCallback? onRetry,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ErrorDialog(
        title: title,
        message: message,
        buttonText: buttonText,
        onPressed: onPressed,
        showRetry: showRetry,
        onRetry: onRetry,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.error_outline,
              color: Colors.red,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      content: Text(
        message,
        style: TextStyle(
          fontSize: 14,
          color: Colors.grey[700],
        ),
      ),
      actions: [
        if (showRetry)
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onRetry?.call();
            },
            child: const Text('再試行'),
          ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            onPressed?.call();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
          child: Text(buttonText ?? '閉じる'),
        ),
      ],
    );
  }
}

/// 確認ダイアログ
class ConfirmDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmText;
  final String cancelText;
  final Color? confirmColor;
  final bool isDestructive;

  const ConfirmDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmText = '確認',
    this.cancelText = 'キャンセル',
    this.confirmColor,
    this.isDestructive = false,
  });

  /// 確認ダイアログを表示
  static Future<bool> show(
    BuildContext context, {
    required String title,
    required String message,
    String confirmText = '確認',
    String cancelText = 'キャンセル',
    Color? confirmColor,
    bool isDestructive = false,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => ConfirmDialog(
        title: title,
        message: message,
        confirmText: confirmText,
        cancelText: cancelText,
        confirmColor: confirmColor,
        isDestructive: isDestructive,
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final buttonColor = confirmColor ??
        (isDestructive ? Colors.red : Theme.of(context).primaryColor);

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Text(
        message,
        style: TextStyle(
          fontSize: 14,
          color: Colors.grey[700],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(cancelText),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          style: ElevatedButton.styleFrom(
            backgroundColor: buttonColor,
            foregroundColor: Colors.white,
          ),
          child: Text(confirmText),
        ),
      ],
    );
  }
}

/// 成功ダイアログ
class SuccessDialog extends StatelessWidget {
  final String title;
  final String message;
  final String? buttonText;
  final VoidCallback? onPressed;

  const SuccessDialog({
    super.key,
    this.title = '完了',
    required this.message,
    this.buttonText,
    this.onPressed,
  });

  /// 成功ダイアログを表示
  static Future<void> show(
    BuildContext context, {
    String title = '完了',
    required String message,
    String? buttonText,
    VoidCallback? onPressed,
  }) {
    return showDialog(
      context: context,
      builder: (context) => SuccessDialog(
        title: title,
        message: message,
        buttonText: buttonText,
        onPressed: onPressed,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle_outline,
              color: Colors.green,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      content: Text(
        message,
        style: TextStyle(
          fontSize: 14,
          color: Colors.grey[700],
        ),
      ),
      actions: [
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            onPressed?.call();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
          ),
          child: Text(buttonText ?? 'OK'),
        ),
      ],
    );
  }
}

/// 情報ダイアログ
class InfoDialog extends StatelessWidget {
  final String title;
  final String message;
  final String? buttonText;

  const InfoDialog({
    super.key,
    this.title = 'お知らせ',
    required this.message,
    this.buttonText,
  });

  /// 情報ダイアログを表示
  static Future<void> show(
    BuildContext context, {
    String title = 'お知らせ',
    required String message,
    String? buttonText,
  }) {
    return showDialog(
      context: context,
      builder: (context) => InfoDialog(
        title: title,
        message: message,
        buttonText: buttonText,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.info_outline,
              color: Colors.blue,
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      content: Text(
        message,
        style: TextStyle(
          fontSize: 14,
          color: Colors.grey[700],
        ),
      ),
      actions: [
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          child: Text(buttonText ?? 'OK'),
        ),
      ],
    );
  }
}
