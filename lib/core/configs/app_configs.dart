enum Environment { dev, staging, prod }

class AppConfig {
  static late Environment _env;

  // Set & read current environment
  static void set(Environment e) => _env = e;
  static Environment get env => _env;

  // Convenience getters
  static bool get isDev => _env == Environment.dev;
  static bool get isStaging => _env == Environment.staging;
  static bool get isProd => _env == Environment.prod;

  // Example: dynamic app title by env
  static String get appTitle =>
      isDev ? 'Romlerk (Dev)' :
      isStaging ? 'Romlerk (Staging)' :
      'Romlerk';

  // Example: base URLs (replace with yours later)
  static String get apiBaseUrl =>
      isDev ? 'https://api-dev.example.com' :
      isStaging ? 'https://api-staging.example.com' :
      'https://api.example.com';

  // Example: flags/toggles
  static bool get showDebugBanner => isDev || isStaging;
  static bool get useMockData => isDev;          // mock data in dev
  static bool get enableAnalytics => isProd;     // analytics only in prod
}
