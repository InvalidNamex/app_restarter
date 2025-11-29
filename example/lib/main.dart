import 'package:flutter/material.dart';
import 'package:app_restarter/app_restarter.dart';

void main() {
  runApp(
    AppRestarter(
      // Custom transition animation
      transitionDuration: const Duration(milliseconds: 500),
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.8, end: 1.0).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
            ),
            child: child,
          ),
        );
      },
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AppRestarter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      darkTheme: ThemeData.dark(useMaterial3: true),
      home: const MyHomePage(title: 'AppRestarter Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  bool _allowRestart = true;
  String _lastAction = 'None';

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // Counter Display
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    const Text(
                      'Counter Value:',
                      style: TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$_counter',
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _incrementCounter,
                      icon: const Icon(Icons.add),
                      label: const Text('Increment Counter'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Last Action Display
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Last Action: $_lastAction',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Basic Restart
            const Text(
              '1. Basic Restart',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: () {
                setState(() => _lastAction = 'Basic Restart');
                AppRestarter.restartApp(context);
              },
              icon: const Icon(Icons.restart_alt),
              label: const Text('Simple Restart'),
            ),
            const SizedBox(height: 24),

            // Restart with Callbacks
            const Text(
              '2. Restart with Callbacks',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: () async {
                setState(() => _lastAction = 'Restart with Callbacks');
                await AppRestarter.restartApp(
                  context,
                  config: RestartConfig(
                    onBeforeRestart: () async {
                      _showMessage('Preparing to restart...');
                      await Future.delayed(const Duration(milliseconds: 500));
                    },
                    onAfterRestart: () {
                      _showMessage('Restart complete!');
                    },
                  ),
                );
              },
              icon: const Icon(Icons.settings_backup_restore),
              label: const Text('Restart with Callbacks'),
            ),
            const SizedBox(height: 24),

            // Delayed Restart
            const Text(
              '3. Delayed Restart',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: () {
                setState(() => _lastAction = 'Delayed Restart (2s)');
                _showMessage('Restarting in 2 seconds...');
                AppRestarter.restartApp(
                  context,
                  config: const RestartConfig(
                    delay: Duration(seconds: 2),
                  ),
                );
              },
              icon: const Icon(Icons.timer),
              label: const Text('Delayed Restart (2s)'),
            ),
            const SizedBox(height: 24),

            // Conditional Restart
            const Text(
              '4. Conditional Restart',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              title: const Text('Allow Restart'),
              value: _allowRestart,
              onChanged: (value) {
                setState(() => _allowRestart = value);
              },
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: () {
                setState(() => _lastAction = 'Conditional Restart Attempted');
                AppRestarter.restartApp(
                  context,
                  config: RestartConfig(
                    condition: () => _allowRestart,
                    onBeforeRestart: () async {
                      _showMessage('Condition met! Restarting...');
                    },
                  ),
                );
                if (!_allowRestart) {
                  _showMessage('Restart blocked by condition!');
                }
              },
              icon: const Icon(Icons.check_circle),
              label: const Text('Conditional Restart'),
            ),
            const SizedBox(height: 24),

            // Combined Features
            const Text(
              '5. All Features Combined',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: () {
                setState(() => _lastAction = 'Full Featured Restart');
                AppRestarter.restartApp(
                  context,
                  config: RestartConfig(
                    delay: const Duration(seconds: 1),
                    condition: () => _allowRestart,
                    onBeforeRestart: () async {
                      _showMessage('Saving state...');
                      await Future.delayed(const Duration(milliseconds: 300));
                    },
                    onAfterRestart: () {
                      _showMessage('App restarted successfully!');
                    },
                  ),
                );
              },
              icon: const Icon(Icons.auto_awesome),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                foregroundColor: Colors.white,
              ),
              label: const Text('Full Featured Restart'),
            ),
            const SizedBox(height: 24),

            // Info Card
            Card(
              color: Colors.amber.shade50,
              child: const Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '💡 Tips:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text('• Increment the counter to see state reset'),
                    Text('• Toggle "Allow Restart" to test conditions'),
                    Text('• Watch for snackbar messages during restart'),
                    Text('• Notice the smooth fade animation'),
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
