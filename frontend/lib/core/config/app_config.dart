enum AppEnvironment { dev, staging, prod }

class AppConfig {
  static const AppEnvironment environment = AppEnvironment.dev;
  static const String apiBaseUrl = 'https://api.prachtiz.local/v1';

  // Feature Flags
  static const bool enableTelehealthWebRTC = true;
  static const bool enableVitalsIoTStreaming = false;
  static const bool enableOfflineCaching = true;

  // App version
  static const String version = '1.0.0+1';
}
