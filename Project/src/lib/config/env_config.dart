/// 環境設定クラス
/// 
/// --dart-define または環境変数でAPI Base URLを切り替え可能
/// 
/// 使用例:
/// ```bash
/// # ローカル開発
/// flutter run --dart-define=ENV=local
/// 
/// # ステージング
/// flutter run --dart-define=ENV=staging --dart-define=API_BASE_URL=https://staging-api.example.com
/// 
/// # 本番
/// flutter run --dart-define=ENV=production --dart-define=API_BASE_URL=https://api.example.com
/// ```
class EnvConfig {
  // シングルトンパターン
  static final EnvConfig _instance = EnvConfig._internal();
  factory EnvConfig() => _instance;
  EnvConfig._internal();

  /// 環境名 (local, docker, staging, production)
  static const String environment = String.fromEnvironment(
    'ENV',
    defaultValue: 'local',
  );

  /// API Base URL（--dart-defineで上書き可能）
  static const String _apiBaseUrlOverride = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: '',
  );

  /// 環境ごとのデフォルトAPI Base URL
  static const Map<String, String> _defaultApiBaseUrls = {
    'local': 'http://localhost:8000',
    'docker': 'http://localhost:8000',
    'staging': 'https://staging-api.example.com',
    'production': 'https://api.example.com',
  };

  /// モックAPIを利用するか（--dart-defineで上書き可能）
  /// デフォルト: 全環境でfalse（必要なときだけ明示的にtrueへ）
  static const bool useMockApi = bool.fromEnvironment(
    'USE_MOCK_API',
    defaultValue: false,
  );

  /// API Base URLを取得
  /// 優先順位: --dart-define > 環境別デフォルト > ローカル
  static String get apiBaseUrl {
    // 1. --dart-defineで明示的に指定されていればそれを使用
    if (_apiBaseUrlOverride.isNotEmpty) {
      return _apiBaseUrlOverride;
    }

    // 2. 環境に応じたデフォルトURLを返す
    return _defaultApiBaseUrls[environment] ?? _defaultApiBaseUrls['local']!;
  }

  /// WebSocket URL（APIと同じホストを使用）
  static String get wsBaseUrl {
    final url = apiBaseUrl;
    if (url.startsWith('https://')) {
      return url.replaceFirst('https://', 'wss://');
    } else if (url.startsWith('http://')) {
      return url.replaceFirst('http://', 'ws://');
    }
    return url;
  }

  /// デバッグモードかどうか
  static bool get isDebug => environment == 'local' || environment == 'staging' || environment == 'docker';

  /// 本番環境かどうか
  static bool get isProduction => environment == 'production';

  /// ログ出力を有効にするか
  static bool get enableLogging => isDebug;

  /// API タイムアウト時間（秒）
  static int get apiTimeout => isProduction ? 30 : 60;

  /// 設定情報をデバッグ出力
  static void printConfig() {
    if (enableLogging) {
      print('┌─────────────────────────────────────');
      print('│ Environment Config');
      print('├─────────────────────────────────────');
      print('│ ENV: $environment');
      print('│ API Base URL: $apiBaseUrl');
      print('│ WS Base URL: $wsBaseUrl');
      print('│ Use Mock API: $useMockApi');
      print('│ Debug Mode: $isDebug');
      print('│ API Timeout: ${apiTimeout}s');
      print('└─────────────────────────────────────');
    }
  }
}

/// 環境タイプの列挙型
enum Environment {
  local,
  docker,
  staging,
  production;

  static Environment get current {
    switch (EnvConfig.environment) {
      case 'docker':
        return Environment.docker;
      case 'staging':
        return Environment.staging;
      case 'production':
        return Environment.production;
      default:
        return Environment.local;
    }
  }
}
