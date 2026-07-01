import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:delhi_legal_assistant/shared/widgets/pietra_card.dart';
import 'package:delhi_legal_assistant/shared/widgets/jaali_background.dart';
import 'package:delhi_legal_assistant/shared/widgets/single_arch.dart';
import 'package:delhi_legal_assistant/shared/widgets/inlay_chip.dart';
import 'package:delhi_legal_assistant/shared/widgets/lal_app_bar.dart';
import 'package:delhi_legal_assistant/shared/widgets/gold_divider.dart';
import 'package:delhi_legal_assistant/shared/widgets/arch_row.dart';
import 'package:flutter_animate/flutter_animate.dart';

void main() {
  setUpAll(() {
    Animate.restartOnHotReload = true;
    Animate.defaultDuration = Duration.zero;
  });

  group('PietraCard', () {
    testWidgets('should render with child', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PietraCard(
              child: const Text('Test Content'),
            ),
          ),
        ),
      );

      expect(find.text('Test Content'), findsOneWidget);
      expect(find.byType(PietraCard), findsOneWidget);
      await tester.pumpAndSettle();
    });

    testWidgets('should handle onTap', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PietraCard(
              onTap: () => tapped = true,
              child: const Text('Tap Me'),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(PietraCard));
      expect(tapped, isTrue);
      await tester.pumpAndSettle();
    });

    testWidgets('should apply custom accent color', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PietraCard(
              accentColor: Colors.red,
              child: const Text('Custom Color'),
            ),
          ),
        ),
      );

      expect(find.byType(PietraCard), findsOneWidget);
      await tester.pumpAndSettle();
    });
  });

  group('JaaliBackground', () {
    testWidgets('should render with child', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: JaaliBackground(
              child: const Text('Background Test'),
            ),
          ),
        ),
      );

      expect(find.text('Background Test'), findsOneWidget);
      expect(find.byType(JaaliBackground), findsOneWidget);
      await tester.pumpAndSettle();
    });

    testWidgets('should apply custom opacity', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: JaaliBackground(
              opacity: 0.2,
              child: const Text('Opacity Test'),
            ),
          ),
        ),
      );

      expect(find.byType(JaaliBackground), findsOneWidget);
      await tester.pumpAndSettle();
    });
  });

  group('SingleArch', () {
    testWidgets('should render with default size', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleArch(),
          ),
        ),
      );

      expect(find.byType(SingleArch), findsOneWidget);
      await tester.pumpAndSettle();
    });

    testWidgets('should render with custom size', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleArch(
              width: 200,
              height: 30,
            ),
          ),
        ),
      );

      expect(find.byType(SingleArch), findsOneWidget);
      await tester.pumpAndSettle();
    });
  });

  group('InlayChip', () {
    testWidgets('should render live status', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InlayChip(status: InlayStatus.live),
          ),
        ),
      );

      expect(find.byType(InlayChip), findsOneWidget);
      expect(find.text('LIVE'), findsOneWidget);
      
      // Clean up infinite animation controller ticker by unmounting it
      await tester.pumpWidget(const SizedBox.shrink());
    });

    testWidgets('should render new feature status', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InlayChip(status: InlayStatus.newFeature),
          ),
        ),
      );

      expect(find.byType(InlayChip), findsOneWidget);
      expect(find.text('NEW'), findsOneWidget);
    });

    testWidgets('should render custom label', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InlayChip(
              status: InlayStatus.soon,
              label: 'Coming Soon',
            ),
          ),
        ),
      );

      expect(find.text('Coming Soon'), findsOneWidget);
    });
  });

  group('LalAppBar', () {
    testWidgets('should render with title', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: LalAppBar(title: 'Test Title'),
            body: const SizedBox.shrink(),
          ),
        ),
      );

      expect(find.text('Test Title'), findsOneWidget);
      expect(find.byType(LalAppBar), findsOneWidget);
    });

    testWidgets('should render with actions', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: LalAppBar(
              title: 'Test',
              actions: [
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {},
                ),
              ],
            ),
            body: const SizedBox.shrink(),
          ),
        ),
      );

      expect(find.byIcon(Icons.search), findsOneWidget);
    });
  });

  group('GoldDivider', () {
    testWidgets('should render divider', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: const GoldDivider(),
          ),
        ),
      );

      expect(find.byType(GoldDivider), findsOneWidget);
    });
  });

  group('ArchRow', () {
    testWidgets('should render with default count', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ArchRow(),
          ),
        ),
      );

      expect(find.byType(ArchRow), findsOneWidget);
    });

    testWidgets('should render with custom count', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ArchRow(count: 5),
          ),
        ),
      );

      expect(find.byType(ArchRow), findsOneWidget);
    });
  });
}
