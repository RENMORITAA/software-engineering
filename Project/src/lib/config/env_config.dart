import 'package:flutter/foundation.dart';
import 'dart:io' show Platform;

/// 環境設定クラス
/// 
/// --dart-define または環境変数でAPI Base URLを切り替え可能
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

  /// モックAPIを利用するか（--dart-defineで上書き可能）
  static const bool useMockApi = bool.fromEnvironment(
    'USE_MOCK_API',
    defaultValue: false,
  );

  /// デフォルトのローカルURLをプラットフォーム別に取得
  static String get _defaultLocalUrl {
    if (kIsWeb) {
      return 'http://localhost:8000';
    }
    // AndroidエミュレータからPCのホスト(localhost)を参照する場合
    try {
      if (Platform.isAndroid) {
        return 'http://10.0.2.2:8000';
      }
    } catch (e) {
      // Platform.isAndroid が使えない環境（Unit Test等）への配慮
    }
    // iOSシミュレータやデスクトップ実行
    return 'http://127.0.0.1:8000';
  }

  /// API Base URLを取得
  /// 優先順位: --dart-define > 環境別デフォルト > ローカル
  static String get apiBaseUrl {
    // 1. --dart-defineで明示的に指定されていればそれを使用（最優先）
    if (_apiBaseUrlOverride.isNotEmpty) {
      return _apiBaseUrlOverride;
    }

    // 2. 本番環境のデフォルト（dart-defineが設定されていない場合のフォールバック）
    if (environment == 'production') {
      // 本番環境では相対パスを使用（同一オリジン）
      if (kIsWeb) {
        return '/api';
      }
      return 'https://api.example.com';
    }
    if (environment == 'staging') return 'https://staging-api.example.com';
    
    // 3. ローカル/Docker環境（動的に判定）
    return _defaultLocalUrl;
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
  static int get apiTimeout => 60; // 本番でも60秒に設定

  /// 設定情報をデバッグ出力
  static void printConfig() {
    if (enableLogging) {
      debugPrint('┌─────────────────────────────────────');
      debugPrint('│ Environment Config');
      debugPrint('├─────────────────────────────────────');
      debugPrint('│ ENV: $environment');
      debugPrint('│ API Base URL: $apiBaseUrl');
      debugPrint('│ Use Mock API: $useMockApi');
      debugPrint('│ Debug Mode: $isDebug');
      debugPrint('└─────────────────────────────────────');
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