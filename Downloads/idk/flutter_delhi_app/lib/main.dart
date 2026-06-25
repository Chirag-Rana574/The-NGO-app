import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

  // Initialize Firebase (optional - for legacy features)
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint("Firebase initialization failed/bypassed: $e");
  }

  // Initialize Supabase
  await Supabase.initialize(
    url: Env.supabaseUrl,
    publishableKey: Env.supabaseAnonKey,
  );

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
