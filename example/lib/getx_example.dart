import 'package:flutter/material.dart';
import 'package:app_restarter/app_restarter.dart';
import 'package:get/get.dart';

// ============================================================================
// SERVICES (Simulating GetX Services)
// ============================================================================

/// Storage service that would normally use Hive or SharedPreferences
class StorageService extends GetxService {
  int counter = 0;

  Future<StorageService> init() async {
    // Simulate initialization
    await Future.delayed(const Duration(milliseconds: 100));
    debugPrint('✅ StorageService initialized');
    return this;
  }

  void incrementCounter() {
    counter++;
    debugPrint('Counter incremented to: $counter');
  }
}

/// Connectivity service
class ConnectivityService extends GetxService {
  Future<ConnectivityService> init() async {
    await Future.delayed(const Duration(milliseconds: 50));
    debugPrint('✅ ConnectivityService initialized');
    return this;
  }
}

// ============================================================================
// DEPENDENCY INJECTION
// ============================================================================

class DependencyInjection {
  static Future<void> init() async {
    debugPrint('🔄 Initializing dependencies...');

    // Initialize services
    final storageService = await StorageService().init();
    Get.put(storageService, permanent: true);

    final connectivityService = await ConnectivityService().init();
    Get.put(connectivityService, permanent: true);

    debugPrint('✅ All dependencies initialized');
  }
}

// ============================================================================
// MAIN APP
// ============================================================================

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize dependencies BEFORE running the app
  await DependencyInjection.init();

  runApp(
    AppRestarter(
      transitionDuration: const Duration(milliseconds: 500),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'GetX + AppRestarter Demo',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      darkTheme: ThemeData.dark(useMaterial3: true),
      initialRoute: '/home',
      getPages: [
        GetPage(name: '/home', page: () => const HomePage()),
        GetPage(name: '/second', page: () => const SecondPage()),
      ],
    );
  }
}

// ============================================================================
// HOME PAGE
// ============================================================================

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Access GetX services
    final storageService = Get.find<StorageService>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('GetX + AppRestarter'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status Card
            Card(
              color: Colors.green.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 48,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '✅ GetX Services Active',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Counter: ${storageService.counter}',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Increment Button
            ElevatedButton.icon(
              onPressed: () {
                storageService.incrementCounter();
                // Force UI update
                (context as Element).markNeedsBuild();
              },
              icon: const Icon(Icons.add),
              label: const Text('Increment Counter'),
            ),
            const SizedBox(height: 8),

            // Navigate Button
            ElevatedButton.icon(
              onPressed: () => Get.toNamed('/second'),
              icon: const Icon(Icons.arrow_forward),
              label: const Text('Go to Second Page'),
            ),
            const SizedBox(height: 24),

            // Restart Options
            const Text(
              'Restart Options',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // ❌ WRONG WAY - Will crash
            Card(
              color: Colors.red.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.error, color: Colors.red),
                        SizedBox(width: 8),
                        Text(
                          '❌ Wrong Way (Will Crash)',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Restart without reinitializing dependencies',
                      style: TextStyle(fontSize: 12),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      onPressed: () {
                        AppRestarter.restartApp(context);
                        // This will crash because dependencies are lost!
                      },
                      icon: const Icon(Icons.warning),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      label: const Text('Restart (No Reinitialization)'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ✅ CORRECT WAY - With reinitialization
            Card(
              color: Colors.green.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.green),
                        SizedBox(width: 8),
                        Text(
                          '✅ Correct Way (Fixed)',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Restart with proper dependency reinitialization',
                      style: TextStyle(fontSize: 12),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      onPressed: () async {
                        await AppRestarter.restartApp(
                          context,
                          config: RestartConfig(
                            onBeforeRestart: () async {
                              debugPrint('🧹 Cleaning up before restart...');
                              // Optional: Clear GetX if needed
                              // await Get.deleteAll(force: true);
                            },
                            onAfterRestart: () async {
                              debugPrint('🔄 Reinitializing dependencies...');
                              // Reinitialize all GetX services
                              await DependencyInjection.init();
                              debugPrint('✅ Restart complete!');
                            },
                          ),
                        );
                      },
                      icon: const Icon(Icons.restart_alt),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                      label: const Text('Restart (With Reinitialization)'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Info Card
            Card(
              color: Colors.blue.shade50,
              child: const Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '💡 How It Works:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text('1. onBeforeRestart: Clean up resources'),
                    Text('2. App widget tree rebuilds'),
                    Text('3. onAfterRestart: Reinitialize dependencies'),
                    Text('4. App continues with fresh state'),
                    SizedBox(height: 8),
                    Text(
                      'The key fix: onAfterRestart is now async!',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// SECOND PAGE
// ============================================================================

class SecondPage extends StatelessWidget {
  const SecondPage({super.key});

  @override
  Widget build(BuildContext context) {
    final storageService = Get.find<StorageService>();

    return Scaffold(
      appBar: AppBar(title: const Text('Second Page')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'GetX services work across pages!',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 16),
            Text(
              'Counter: ${storageService.counter}',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => Get.back(),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }
}
