class AppConfig {
  AppConfig._();

  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://beissab.de/api',
  );

  static const String appVersion = '1.0.0';
}
