class Environment {
  // Supabase Configuration
  static const String supabaseUrl = 'https://dpwibhfgfxwvxntgjxns.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRwd2liaGZnZnh3dnhudGdqeG5zIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODEyNTc3NDYsImV4cCI6MjA5NjgzMzc0Nn0.8d2eCjS8bEAYBeE9QsuX6Qw9MhoGMVSXuwC2yOaVksY';

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
