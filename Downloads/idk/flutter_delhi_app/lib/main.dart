import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'firebase_options.dart';
import 'core/config/env.dart';
import 'theme/app_theme.dart';
import 'theme/theme_provider.dart';
import 'core/router/app_router.dart';
import 'core/utils/local_logger.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Log Flutter framework errors
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    LocalLogger.logError(details.exceptionAsString(), details.stack);
  };

  // Log asynchronous errors
  PlatformDispatcher.instance.onError = (error, stack) {
    LocalLogger.logError(error, stack);
    return true;
  };

  // Initialize Firebase with project config
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await Supabase.initialize(
    url: Env.supabaseUrl,
    publishableKey: Env.supabaseAnonKey,
  );

  // Sync Firebase ID token with Supabase Client REST headers dynamically
  FirebaseAuth.instance.idTokenChanges().listen((user) async {
    if (user != null) {
      try {
        final token = await user.getIdToken();
        Supabase.instance.client.rest.headers['Authorization'] = 'Bearer $token';
        Supabase.instance.client.rest.headers['x-firebase-user-id'] = user.uid;
      } catch (e) {
        debugPrint('Error syncing Firebase token to Supabase: $e');
      }
    } else {
      Supabase.instance.client.rest.headers.remove('Authorization');
      Supabase.instance.client.rest.headers.remove('x-firebase-user-id');
    }
  });

  // Initialize Sentry for crash reporting
  await SentryFlutter.init(
    (options) {
      options.dsn = Env.sentryDsn;
      options.tracesSampleRate = 1.0;
    },
    appRunner: () => runApp(
      const ProviderScope(
        child: LegalAssistantApp(),
      ),
    ),
  );
}

class LegalAssistantApp extends ConsumerWidget {
  const LegalAssistantApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final router = AppRouter.createRouter();
    
    // Firebase ID token is dynamically bound to Supabase rest headers in main()

    return MaterialApp.router(
      title: 'Delhi Legal Assistant Pro',
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      routerConfig: router,
    );
  }
}
