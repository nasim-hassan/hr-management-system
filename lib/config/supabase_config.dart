import 'package:supabase_flutter/supabase_flutter.dart';
import 'environment.dart';

class SupabaseConfig {
  static Future<void> initialize() async {
    try {
      print('🔧 [SUPABASE] Initializing Supabase...');
      print('🔧 [SUPABASE] URL: ${Environment.supabaseUrl}');
      print('🔧 [SUPABASE] Anon Key exists: ${Environment.supabaseAnonKey.isNotEmpty}');
      print('🔧 [SUPABASE] Debug mode: ${Environment.enableDebugMode}');
      
      await Supabase.initialize(
        url: Environment.supabaseUrl,
        anonKey: Environment.supabaseAnonKey,
        debug: Environment.enableDebugMode,
      );
      
      print('✅ [SUPABASE] Initialization successful');
      print('✅ [SUPABASE] Auth endpoint ready');
    } catch (e) {
      print('❌ [SUPABASE] Initialization failed: $e');
      throw SupabaseConfigException('Failed to initialize Supabase: $e');
    }
  }

  static SupabaseClient get client => Supabase.instance.client;

  static String? get currentUserId => client.auth.currentUser?.id;

  static bool get isAuthenticated => client.auth.currentUser != null;

  static Future<void> signOut() async {
    await client.auth.signOut();
  }
}

class SupabaseConfigException implements Exception {
  final String message;

  SupabaseConfigException(this.message);

  @override
  String toString() => message;
}
