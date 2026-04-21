class Environment {
  // Supabase Configuration
  static const String supabaseUrl = 'YOUR_SUPABASE_URL';
  static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';

  // App Configuration
  static const String appName = 'HR Management System';
  static const String appVersion = '1.0.0';

  // API Endpoints
  static const String apiBaseUrl = '$supabaseUrl/rest/v1';

  // Feature Flags
  static const bool enableLogging = true;
  static const bool enableAnalytics = false;
  static const bool enableDebugMode = true;
}
