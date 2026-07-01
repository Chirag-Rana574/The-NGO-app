import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supa;
import 'api_interceptor.dart';

// Dio provider
final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
    sendTimeout: const Duration(seconds: 30),
  ));

  // Add interceptors
  dio.interceptors.add(ApiInterceptor());

  return dio;
});

// Supabase client provider (for data access only — NOT auth)
final supabaseClientProvider = Provider<supa.SupabaseClient>((ref) {
  return supa.Supabase.instance.client;
});

// Firebase Auth state provider (stream)
final authStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

// Current Firebase user provider
final currentUserProvider = Provider<User?>((ref) {
  // Watch the auth state stream to get reactive updates
  final authState = ref.watch(authStateProvider);
  return authState.valueOrNull;
});

// Session provider (Firebase doesn't have sessions — use user presence as proxy)
final sessionProvider = Provider<User?>((ref) {
  return ref.watch(currentUserProvider);
});
