import 'package:flutter/foundation.dart';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

/// ブラウザのURLを更新するユーティリティ
/// Flutterの画面遷移なしでURLだけを変更する
class UrlHelper {
  /// URLを更新（履歴に追加せず置換）
  static void replaceUrl(String path) {
    if (kIsWeb) {
      html.window.history.replaceState(null, '', path);
    }
  }

  /// URLを更新（履歴に追加）
  static void pushUrl(String path) {
    if (kIsWeb) {
      html.window.history.pushState(null, '', path);
    }
  }

  /// 現在のパスを取得
  static String get currentPath {
    if (kIsWeb) {
      return html.window.location.pathname ?? '/';
    }
    return '/';
  }
}
