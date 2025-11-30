import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app_restarter/app_restarter.dart';

void main() {
  group('AppRestarter Widget Tests', () {
    testWidgets('AppRestarter wraps child widget correctly', (
      WidgetTester tester,
    ) async {
      const testKey = Key('test_child');

      await tester.pumpWidget(
        AppRestarter(
          child: MaterialApp(
            home: Scaffold(body: Container(key: testKey)),
          ),
        ),
      );

      expect(find.byKey(testKey), findsOneWidget);
    });

    testWidgets('Simple restart rebuilds widget tree', (
      WidgetTester tester,
    ) async {
      int buildCount = 0;

      await tester.pumpWidget(
        AppRestarter(
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  buildCount++;
                  return ElevatedButton(
                    onPressed: () => AppRestarter.restartApp(context),
                    child: Text('Build count: $buildCount'),
                  );
                },
              ),
            ),
          ),
        ),
      );

      expect(buildCount, 1);
      expect(find.text('Build count: 1'), findsOneWidget);

      // Trigger restart
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      // Build count should increase due to rebuild
      expect(buildCount, greaterThan(1));
    });

    testWidgets('Restart with delay waits before restarting', (
      WidgetTester tester,
    ) async {
      bool restarted = false;

      await tester.pumpWidget(
        AppRestarter(
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  return ElevatedButton(
                    onPressed: () async {
                      await AppRestarter.restartApp(
                        context,
                        config: RestartConfig(
                          delay: const Duration(milliseconds: 100),
                          onAfterRestart: () async {
                            restarted = true;
                          },
                        ),
                      );
                    },
                    child: const Text('Restart'),
                  );
                },
              ),
            ),
          ),
        ),
      );

      expect(restarted, false);

      // Trigger restart
      await tester.tap(find.byType(ElevatedButton));

      // Should not be restarted immediately
      await tester.pump(const Duration(milliseconds: 50));
      expect(restarted, false);

      // Should be restarted after delay
      await tester.pumpAndSettle();
      expect(restarted, true);
    });

    testWidgets('Conditional restart respects condition', (
      WidgetTester tester,
    ) async {
      bool shouldRestart = false;
      bool restarted = false;

      await tester.pumpWidget(
        AppRestarter(
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  return ElevatedButton(
                    onPressed: () async {
                      await AppRestarter.restartApp(
                        context,
                        config: RestartConfig(
                          condition: () => shouldRestart,
                          onAfterRestart: () async {
                            restarted = true;
                          },
                        ),
                      );
                    },
                    child: const Text('Restart'),
                  );
                },
              ),
            ),
          ),
        ),
      );

      // First attempt - should not restart
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      expect(restarted, false);

      // Enable restart
      shouldRestart = true;

      // Second attempt - should restart
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      expect(restarted, true);
    });

    testWidgets('onBeforeRestart callback executes before restart', (
      WidgetTester tester,
    ) async {
      bool beforeCalled = false;
      bool afterCalled = false;

      await tester.pumpWidget(
        AppRestarter(
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  return ElevatedButton(
                    onPressed: () async {
                      await AppRestarter.restartApp(
                        context,
                        config: RestartConfig(
                          onBeforeRestart: () async {
                            beforeCalled = true;
                            expect(
                              afterCalled,
                              false,
                              reason: 'onBeforeRestart should run first',
                            );
                          },
                          onAfterRestart: () async {
                            afterCalled = true;
                            expect(
                              beforeCalled,
                              true,
                              reason: 'onBeforeRestart should have run already',
                            );
                          },
                        ),
                      );
                    },
                    child: const Text('Restart'),
                  );
                },
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      expect(beforeCalled, true);
      expect(afterCalled, true);
    });

    testWidgets('onAfterRestart callback executes after restart', (
      WidgetTester tester,
    ) async {
      bool afterCalled = false;

      await tester.pumpWidget(
        AppRestarter(
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  return ElevatedButton(
                    onPressed: () async {
                      await AppRestarter.restartApp(
                        context,
                        config: RestartConfig(
                          onAfterRestart: () async {
                            afterCalled = true;
                          },
                        ),
                      );
                    },
                    child: const Text('Restart'),
                  );
                },
              ),
            ),
          ),
        ),
      );

      expect(afterCalled, false);

      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      expect(afterCalled, true);
    });

    testWidgets('Custom transition animation works', (
      WidgetTester tester,
    ) async {
      bool customTransitionUsed = false;

      await tester.pumpWidget(
        AppRestarter(
          transitionDuration: const Duration(milliseconds: 300),
          transitionBuilder: (child, animation) {
            customTransitionUsed = true;
            return FadeTransition(opacity: animation, child: child);
          },
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  return ElevatedButton(
                    onPressed: () => AppRestarter.restartApp(context),
                    child: const Text('Restart'),
                  );
                },
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      expect(customTransitionUsed, true);
    });

    testWidgets('Throws error when AppRestarter not in tree', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    expect(
                      () => AppRestarter.restartApp(context),
                      throwsA(isA<FlutterError>()),
                    );
                  },
                  child: const Text('Restart'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byType(ElevatedButton));
    });

    testWidgets('State resets after restart', (WidgetTester tester) async {
      await tester.pumpWidget(
        AppRestarter(child: const MaterialApp(home: CounterPage())),
      );

      // Initial state
      expect(find.text('Count: 0'), findsOneWidget);

      // Increment counter
      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();
      expect(find.text('Count: 1'), findsOneWidget);

      // Restart app
      await tester.tap(find.byIcon(Icons.restart_alt));
      await tester.pumpAndSettle();

      // State should be reset
      expect(find.text('Count: 0'), findsOneWidget);
    });
  });

  group('RestartConfig Tests', () {
    test('RestartConfig can be created with all parameters', () {
      final config = RestartConfig(
        onBeforeRestart: () async {},
        onAfterRestart: () async {},
        delay: const Duration(seconds: 1),
        condition: () => true,
      );

      expect(config.onBeforeRestart, isNotNull);
      expect(config.onAfterRestart, isNotNull);
      expect(config.delay, const Duration(seconds: 1));
      expect(config.condition, isNotNull);
    });

    test('RestartConfig can be created with no parameters', () {
      const config = RestartConfig();

      expect(config.onBeforeRestart, isNull);
      expect(config.onAfterRestart, isNull);
      expect(config.delay, isNull);
      expect(config.condition, isNull);
    });

    test('RestartConfig callbacks are async', () async {
      bool beforeCalled = false;
      bool afterCalled = false;

      final config = RestartConfig(
        onBeforeRestart: () async {
          await Future.delayed(const Duration(milliseconds: 10));
          beforeCalled = true;
        },
        onAfterRestart: () async {
          await Future.delayed(const Duration(milliseconds: 10));
          afterCalled = true;
        },
      );

      expect(beforeCalled, false);
      expect(afterCalled, false);

      await config.onBeforeRestart!();
      expect(beforeCalled, true);

      await config.onAfterRestart!();
      expect(afterCalled, true);
    });
  });
}

// Helper widget for testing state reset
class CounterPage extends StatefulWidget {
  const CounterPage({super.key});

  @override
  State<CounterPage> createState() => _CounterPageState();
}

class _CounterPageState extends State<CounterPage> {
  int count = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text('Count: $count')),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'increment',
            onPressed: () => setState(() => count++),
            child: const Icon(Icons.add),
          ),
          const SizedBox(height: 8),
          FloatingActionButton(
            heroTag: 'restart',
            onPressed: () => AppRestarter.restartApp(context),
            child: const Icon(Icons.restart_alt),
          ),
        ],
      ),
    );
  }
}
