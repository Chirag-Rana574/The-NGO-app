import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'route_names.dart';
import '../../screens/home_screen.dart';
import '../../screens/splash_screen.dart';
import '../../features/legal_updates/presentation/legal_updates_screen.dart';
import '../../features/judgments/presentation/judgments_screen.dart';
import '../../features/cause_lists/presentation/cause_lists_screen.dart';
import '../../features/document_builder/presentation/document_selection_screen.dart';
import '../../features/document_builder/presentation/document_builder_screen.dart';
import '../../screens/bare_acts_screen.dart';
import '../../screens/bare_act_detail_screen.dart';
import '../../screens/police_admin_screen.dart';
import '../../screens/police_station_detail_screen.dart';
import '../../screens/delhi_high_court_screen.dart';
import '../../screens/supreme_court_screen.dart';
import '../../screens/district_courts_screen.dart';
import '../../screens/district_court_detail_screen.dart';
import '../../screens/new_criminal_law_screen.dart';
import '../../screens/court_calendar_screen.dart';
import '../../screens/court_fee_calculator_screen.dart';
import '../../screens/profile_screen.dart';
import '../../screens/legal_meeting_builder_screen.dart';
import '../../screens/ai_chat_screen.dart';
import '../../screens/login_screen.dart';
import '../../screens/legal_forms_screen.dart';
import '../../screens/case_diary_screen.dart';
import '../../screens/case_documents_screen.dart';
import '../../screens/admin_dashboard_screen.dart';
import '../../shared/widgets/floating_ai_assistant.dart';

// Navigator keys
final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

class AppRouter {
  static GoRouter createRouter() {
    return GoRouter(
      navigatorKey: _rootNavigatorKey,
      initialLocation: AppRoutes.login,
      routes: [
        // Auth routes
        GoRoute(
          path: AppRoutes.login,
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: AppRoutes.splash,
          builder: (context, state) => const SplashScreen(),
        ),

        // Full-screen routes (no bottom nav)
        GoRoute(
          path: AppRoutes.aiChat,
          parentNavigatorKey: _rootNavigatorKey,
          builder: (context, state) => const AiChatScreen(),
        ),
        GoRoute(
          path: AppRoutes.delhiHighCourt,
          parentNavigatorKey: _rootNavigatorKey,
          builder: (context, state) => const DelhiHighCourtScreen(),
        ),
        GoRoute(
          path: AppRoutes.supremeCourt,
          parentNavigatorKey: _rootNavigatorKey,
          builder: (context, state) => const SupremeCourtScreen(),
        ),
        GoRoute(
          path: AppRoutes.districtCourts,
          parentNavigatorKey: _rootNavigatorKey,
          builder: (context, state) => const DistrictCourtsScreen(),
        ),
        GoRoute(
          path: AppRoutes.policeAdmin,
          parentNavigatorKey: _rootNavigatorKey,
          builder: (context, state) => const PoliceAdminScreen(),
        ),
        GoRoute(
          path: AppRoutes.bareActs,
          parentNavigatorKey: _rootNavigatorKey,
          builder: (context, state) => const BareActsScreen(),
        ),
        GoRoute(
          path: AppRoutes.bareActDetail,
          parentNavigatorKey: _rootNavigatorKey,
          builder: (context, state) {
            final act = state.extra;
            return BareActDetailScreen(act: act);
          },
        ),
        GoRoute(
          path: AppRoutes.newCriminalLaw,
          parentNavigatorKey: _rootNavigatorKey,
          builder: (context, state) => const NewCriminalLawScreen(),
        ),
        GoRoute(
          path: AppRoutes.legalForms,
          parentNavigatorKey: _rootNavigatorKey,
          builder: (context, state) => const LegalFormsScreen(),
        ),
        GoRoute(
          path: AppRoutes.causeListsSupreme,
          parentNavigatorKey: _rootNavigatorKey,
          builder: (context, state) => const CauseListsScreen(defaultCourt: 'Supreme Court of India'),
        ),
        GoRoute(
          path: AppRoutes.causeListsHigh,
          parentNavigatorKey: _rootNavigatorKey,
          builder: (context, state) => const CauseListsScreen(defaultCourt: 'Delhi High Court'),
        ),
        GoRoute(
          path: AppRoutes.courtFeeCalculator,
          parentNavigatorKey: _rootNavigatorKey,
          builder: (context, state) => const CourtFeeCalculatorScreen(),
        ),
        GoRoute(
          path: AppRoutes.caseDiary,
          parentNavigatorKey: _rootNavigatorKey,
          builder: (context, state) => const CaseDiaryScreen(),
        ),
        GoRoute(
          path: AppRoutes.caseDocuments,
          parentNavigatorKey: _rootNavigatorKey,
          builder: (context, state) => const CaseDocumentsScreen(),
        ),
        GoRoute(
          path: AppRoutes.adminDashboard,
          parentNavigatorKey: _rootNavigatorKey,
          builder: (context, state) => const AdminDashboardScreen(),
        ),

        // Feature routes
        GoRoute(
          path: AppRoutes.legalUpdates,
          parentNavigatorKey: _rootNavigatorKey,
          builder: (context, state) => const LegalUpdatesScreen(),
        ),
        GoRoute(
          path: AppRoutes.judgments,
          parentNavigatorKey: _rootNavigatorKey,
          builder: (context, state) => const JudgmentsScreen(),
        ),
        GoRoute(
          path: AppRoutes.causeLists,
          parentNavigatorKey: _rootNavigatorKey,
          builder: (context, state) => const CauseListsScreen(),
        ),

        // Shell route with bottom navigation
        ShellRoute(
          navigatorKey: _shellNavigatorKey,
          builder: (context, state, child) {
            return _ScaffoldWithBottomNavBar(child: child);
          },
          routes: [
            GoRoute(
              path: AppRoutes.home,
              builder: (context, state) => const HomeScreen(),
            ),
            GoRoute(
              path: AppRoutes.documents,
              builder: (context, state) => const DocumentSelectionScreen(),
            ),
            GoRoute(
              path: AppRoutes.calendar,
              builder: (context, state) => const CourtCalendarScreen(),
            ),
            GoRoute(
              path: AppRoutes.profile,
              builder: (context, state) => const ProfileScreen(),
            ),
            GoRoute(
              path: AppRoutes.documentBuilder,
              builder: (context, state) {
                final formId = state.extra as String? ?? state.uri.queryParameters['formId'] ?? 'vakalatnama';
                return DocumentBuilderScreen(formId: formId);
              },
            ),
            GoRoute(
              path: AppRoutes.documentSelection,
              builder: (context, state) => const DocumentSelectionScreen(),
            ),
            GoRoute(
              path: AppRoutes.policeStationDetail,
              builder: (context, state) {
                final station = state.extra;
                return PoliceStationDetailScreen(station: station);
              },
            ),
            GoRoute(
              path: AppRoutes.districtCourtDetail,
              builder: (context, state) {
                final court = state.extra;
                return DistrictCourtDetailScreen(court: court);
              },
            ),
            GoRoute(
              path: AppRoutes.legalMeetingBuilder,
              builder: (context, state) => const LegalMeetingBuilderScreen(),
            ),
          ],
        ),
      ],
    );
  }
}

// Placeholder screen for migration - replace with actual screens
class _PlaceholderScreen extends StatelessWidget {
  final String name;

  const _PlaceholderScreen({required this.name});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(name)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              name,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18),
            ),
            if (name == 'Login') ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.go(AppRoutes.home),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
                child: const Text('Enter App', style: TextStyle(fontSize: 16)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// Bottom navigation scaffold
class _ScaffoldWithBottomNavBar extends StatelessWidget {
  final Widget child;

  const _ScaffoldWithBottomNavBar({required this.child});

  @override
  Widget build(BuildContext context) {
    return _ResponsiveShell(
      child: Scaffold(
        drawer: const _PlaceholderScreen(name: 'App Drawer'),
        body: Stack(
          children: [
            child,
            const FloatingAiAssistant(),
          ],
        ),
        bottomNavigationBar: _BottomNavBar(
          onTap: (index) => _onItemTapped(index, context),
        ),
      ),
    );
  }

  static void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go(AppRoutes.home);
        break;
      case 1:
        context.go(AppRoutes.documents);
        break;
      case 2:
        context.go(AppRoutes.calendar);
        break;
      case 3:
        context.go(AppRoutes.profile);
        break;
    }
  }
}

// Extracted bottom navigation bar for better performance
class _BottomNavBar extends StatelessWidget {
  final ValueChanged<int> onTap;

  const _BottomNavBar({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.folder),
          label: 'Documents',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_today),
          label: 'Calendar',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
      currentIndex: _calculateSelectedIndex(context),
      onTap: onTap,
    );
  }

  static int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.path;
    if (location.startsWith(AppRoutes.home)) return 0;
    if (location.startsWith(AppRoutes.documents)) return 1;
    if (location.startsWith(AppRoutes.calendar)) return 2;
    if (location.startsWith(AppRoutes.profile)) return 3;
    return 0;
  }
}

class _ResponsiveShell extends StatelessWidget {
  final Widget child;
  const _ResponsiveShell({required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF080C14) : const Color(0xFFF9F4EC);
    final borderColor = isDark ? const Color(0xFF1E2F45) : const Color(0xFFC4956A);

    return Container(
      color: bgColor,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              border: Border.symmetric(
                vertical: BorderSide(color: borderColor, width: 2),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  spreadRadius: 1,
                )
              ],
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
