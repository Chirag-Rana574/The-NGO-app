import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/env.dart';

class AppSupabaseClient {
  static bool get isInitialized => true;

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: Env.supabaseUrl,
      publishableKey: Env.supabaseAnonKey,
    );
  }

  static SupabaseClient get instance => Supabase.instance.client;
}
