/// ブラウザのURLを更新するユーティリティ（非Web用スタブ）
class UrlHelper {
  /// URLを更新（履歴に追加せず置換）
  static void replaceUrl(String path) {
    // 非Webプラットフォームでは何もしない
  }

  /// URLを更新（履歴に追加）
  static void pushUrl(String path) {
    // 非Webプラットフォームでは何もしない
  }

  /// 現在のパスを取得
  static String get currentPath => '/';
}
