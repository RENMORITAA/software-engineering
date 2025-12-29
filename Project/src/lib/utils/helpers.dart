import 'package:flutter/material.dart';

/// 入力バリデーションユーティリティ
class Validators {
  /// メールアドレスのバリデーション
  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return 'メールアドレスを入力してください';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return '有効なメールアドレスを入力してください';
    }
    return null;
  }

  /// パスワードのバリデーション
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'パスワードを入力してください';
    }
    if (value.length < 8) {
      return 'パスワードは8文字以上で入力してください';
    }
    return null;
  }

  /// パスワード確認のバリデーション
  static String? Function(String?) confirmPassword(String password) {
    return (String? value) {
      if (value == null || value.isEmpty) {
        return 'パスワードを再入力してください';
      }
      if (value != password) {
        return 'パスワードが一致しません';
      }
      return null;
    };
  }

  /// 必須項目のバリデーション
  static String? required(String? value, [String? fieldName]) {
    if (value == null || value.isEmpty) {
      return '${fieldName ?? 'この項目'}を入力してください';
    }
    return null;
  }

  /// 電話番号のバリデーション
  static String? phoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return '電話番号を入力してください';
    }
    final phoneRegex = RegExp(r'^[0-9]{10,11}$');
    if (!phoneRegex.hasMatch(value.replaceAll('-', ''))) {
      return '有効な電話番号を入力してください';
    }
    return null;
  }

  /// 郵便番号のバリデーション
  static String? postalCode(String? value) {
    if (value == null || value.isEmpty) {
      return '郵便番号を入力してください';
    }
    final postalRegex = RegExp(r'^\d{3}-?\d{4}$');
    if (!postalRegex.hasMatch(value)) {
      return '有効な郵便番号を入力してください（例: 123-4567）';
    }
    return null;
  }

  /// 数値のバリデーション
  static String? number(String? value, [String? fieldName]) {
    if (value == null || value.isEmpty) {
      return '${fieldName ?? '数値'}を入力してください';
    }
    if (int.tryParse(value) == null) {
      return '有効な数値を入力してください';
    }
    return null;
  }

  /// 最小値のバリデーション
  static String? Function(String?) minValue(int min, [String? fieldName]) {
    return (String? value) {
      if (value == null || value.isEmpty) {
        return '${fieldName ?? '数値'}を入力してください';
      }
      final number = int.tryParse(value);
      if (number == null) {
        return '有効な数値を入力してください';
      }
      if (number < min) {
        return '${fieldName ?? '数値'}は$min以上で入力してください';
      }
      return null;
    };
  }

  /// 最大値のバリデーション
  static String? Function(String?) maxValue(int max, [String? fieldName]) {
    return (String? value) {
      if (value == null || value.isEmpty) {
        return null; // 空の場合はrequiredでチェック
      }
      final number = int.tryParse(value);
      if (number == null) {
        return '有効な数値を入力してください';
      }
      if (number > max) {
        return '${fieldName ?? '数値'}は$max以下で入力してください';
      }
      return null;
    };
  }

  /// 文字数制限のバリデーション
  static String? Function(String?) maxLength(int max, [String? fieldName]) {
    return (String? value) {
      if (value == null || value.isEmpty) {
        return null;
      }
      if (value.length > max) {
        return '${fieldName ?? 'この項目'}は$max文字以内で入力してください';
      }
      return null;
    };
  }

  /// 複数のバリデーションを組み合わせる
  static String? Function(String?) combine(
      List<String? Function(String?)> validators) {
    return (String? value) {
      for (final validator in validators) {
        final result = validator(value);
        if (result != null) {
          return result;
        }
      }
      return null;
    };
  }
}

/// 日付フォーマットユーティリティ
class DateFormatUtils {
  /// 日付を「YYYY年MM月DD日」形式でフォーマット
  static String formatJapanese(DateTime date) {
    return '${date.year}年${date.month}月${date.day}日';
  }

  /// 日付を「YYYY/MM/DD」形式でフォーマット
  static String formatSlash(DateTime date) {
    return '${date.year}/${_twoDigits(date.month)}/${_twoDigits(date.day)}';
  }

  /// 日時を「YYYY/MM/DD HH:mm」形式でフォーマット
  static String formatDateTime(DateTime date) {
    return '${formatSlash(date)} ${_twoDigits(date.hour)}:${_twoDigits(date.minute)}';
  }

  /// 相対時間を取得
  static String relativeTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inSeconds < 60) {
      return 'たった今';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}分前';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}時間前';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}日前';
    } else if (difference.inDays < 30) {
      return '${(difference.inDays / 7).floor()}週間前';
    } else if (difference.inDays < 365) {
      return '${(difference.inDays / 30).floor()}ヶ月前';
    } else {
      return '${(difference.inDays / 365).floor()}年前';
    }
  }

  static String _twoDigits(int n) {
    return n.toString().padLeft(2, '0');
  }
}

/// 通貨フォーマットユーティリティ
class CurrencyUtils {
  /// 金額を円表記でフォーマット
  static String formatYen(int amount) {
    return '¥${_formatWithComma(amount)}';
  }

  /// カンマ区切りでフォーマット
  static String _formatWithComma(int number) {
    return number.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }
}

/// 文字列ユーティリティ
class StringUtils {
  /// 電話番号をフォーマット
  static String formatPhoneNumber(String phone) {
    final cleaned = phone.replaceAll(RegExp(r'\D'), '');
    if (cleaned.length == 11) {
      return '${cleaned.substring(0, 3)}-${cleaned.substring(3, 7)}-${cleaned.substring(7)}';
    } else if (cleaned.length == 10) {
      return '${cleaned.substring(0, 3)}-${cleaned.substring(3, 6)}-${cleaned.substring(6)}';
    }
    return phone;
  }

  /// 郵便番号をフォーマット
  static String formatPostalCode(String postalCode) {
    final cleaned = postalCode.replaceAll(RegExp(r'\D'), '');
    if (cleaned.length == 7) {
      return '${cleaned.substring(0, 3)}-${cleaned.substring(3)}';
    }
    return postalCode;
  }

  /// 文字列を省略
  static String truncate(String text, int maxLength, {String suffix = '...'}) {
    if (text.length <= maxLength) {
      return text;
    }
    return '${text.substring(0, maxLength - suffix.length)}$suffix';
  }
}
