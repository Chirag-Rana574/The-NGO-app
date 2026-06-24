import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/network/network_provider.dart';

/// Authentication service using Supabase Auth.
/// Replaces direct Firebase Auth usage across the app.
class FirebaseAuthService {
  final SupabaseClient _client;

  FirebaseAuthService(this._client);

  /// Get current user
  User? get currentUser => _client.auth.currentUser;

  /// Get current session
  Session? get currentSession => _client.auth.currentSession;

  /// Auth state change stream
  Stream<AuthState> get onAuthStateChange => _client.auth.onAuthStateChange;

  /// Sign in with Google using ID token (for mobile)
  Future<User?> signInWithGoogleIdToken(String idToken) async {
    try {
      final response = await _client.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
      );
      return response.user;
    } catch (e) {
      throw AuthException('Google sign-in failed: $e');
    }
  }

  /// Sign in with OAuth provider (for web)
  Future<User?> signInWithOAuth(String provider) async {
    try {
      final providerEnum = OAuthProvider.values.firstWhere(
        (p) => p.name.toLowerCase() == provider.toLowerCase(),
        orElse: () => throw ArgumentError('Unknown provider: $provider'),
      );
      await _client.auth.signInWithOAuth(
        providerEnum,
        redirectTo: 'io.supabase.flutterquickstart://login-callback/',
      );
      return _client.auth.currentUser;
    } catch (e) {
      throw AuthException('OAuth sign-in failed: $e');
    }
  }

  /// Sign in with email and password
  Future<User?> signInWithEmail(String email, String password) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response.user;
    } catch (e) {
      throw AuthException('Email sign-in failed: $e');
    }
  }

  /// Sign up with email and password
  Future<User?> signUpWithEmail(String email, String password) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
      );
      return response.user;
    } catch (e) {
      throw AuthException('Email sign-up failed: $e');
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } catch (e) {
      throw AuthException('Sign-out failed: $e');
    }
  }

  /// Send password reset email
  Future<void> resetPassword(String email) async {
    try {
      await _client.auth.resetPasswordForEmail(email);
    } catch (e) {
      throw AuthException('Password reset failed: $e');
    }
  }

  /// Update user profile
  Future<User?> updateProfile({String? displayName, String? avatarUrl}) async {
    try {
      await _client.auth.updateUser(UserAttributes(
        data: {
          if (displayName != null) 'display_name': displayName,
          if (avatarUrl != null) 'avatar_url': avatarUrl,
        },
      ));
      return _client.auth.currentUser;
    } catch (e) {
      throw AuthException('Profile update failed: $e');
    }
  }
}

/// Provider for FirebaseAuthService
final firebaseAuthServiceProvider = Provider<FirebaseAuthService>((ref) {
  return FirebaseAuthService(ref.watch(supabaseClientProvider));
});

// Note: Use currentUserProvider from network_provider.dart for reactive auth state.
// The AuthNotifier was removed to avoid the ref.listen anti-pattern in build().
// Auth actions (signIn, signOut) should call the service methods directly.
