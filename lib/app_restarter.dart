import 'package:flutter/material.dart';

/// Configuration for restarting the application.
class RestartConfig {
  /// Callback executed before the restart begins.
  ///
  /// This is useful for cleanup operations, saving state, or clearing
  /// dependency injection containers (e.g., GetX's `Get.deleteAll()`).
  final Future<void> Function()? onBeforeRestart;

  /// Callback executed after the restart completes.
  ///
  /// This is now asynchronous to support dependency reinitialization.
  /// For GetX apps, use this to reinitialize services with `DependencyInjection.init()`.
  final Future<void> Function()? onAfterRestart;

  /// Optional delay before restarting.
  final Duration? delay;

  /// Optional condition that must be true for restart to proceed.
  final bool Function()? condition;

  const RestartConfig({
    this.onBeforeRestart,
    this.onAfterRestart,
    this.delay,
    this.condition,
  });
}

/// A widget that allows restarting the entire application.
///
/// Wrap your root widget (usually [MaterialApp] or [CupertinoApp]) with [AppRestarter].
/// Then call [AppRestarter.restartApp(context)] to restart the app.
class AppRestarter extends StatefulWidget {
  final Widget child;

  /// Duration of the transition animation when restarting.
  final Duration transitionDuration;

  /// Builder for custom transition animations.
  final AnimatedSwitcherTransitionBuilder? transitionBuilder;

  const AppRestarter({
    super.key,
    required this.child,
    this.transitionDuration = const Duration(milliseconds: 300),
    this.transitionBuilder,
  });

  @override
  AppRestarterState createState() => AppRestarterState();

  /// Triggers a restart of the application.
  ///
  /// This finds the [AppRestarter] in the widget tree and calls its restart method.
  ///
  /// Optional parameters:
  /// - [config]: Configuration for the restart operation including callbacks and conditions.
  static Future<void> restartApp(
    BuildContext context, {
    RestartConfig? config,
  }) async {
    final inherited = context
        .dependOnInheritedWidgetOfExactType<_AppRestarterInherited>();

    if (inherited == null) {
      throw FlutterError(
        'AppRestarter.restartApp() called with a context that does not contain an AppRestarter.\n'
        'Make sure your root widget is wrapped with AppRestarter.',
      );
    }

    // Check condition if provided
    if (config?.condition != null && !config!.condition!()) {
      return;
    }

    // Execute onBeforeRestart callback
    if (config?.onBeforeRestart != null) {
      await config!.onBeforeRestart!();
    }

    // Apply delay if specified
    if (config?.delay != null) {
      await Future.delayed(config!.delay!);
    }

    // Perform the restart
    inherited.restart();

    // Execute onAfterRestart callback
    if (config?.onAfterRestart != null) {
      // Wait for the next frame to ensure the restart has completed
      await WidgetsBinding.instance.endOfFrame;
      // Now execute the async callback
      await config!.onAfterRestart!();
    }
  }
}

class AppRestarterState extends State<AppRestarter> {
  Key _key = UniqueKey();

  /// Restarts the app by generating a new [UniqueKey].
  void restartApp() {
    setState(() {
      _key = UniqueKey(); // changes the key, triggers rebuild from root
    });
  }

  @override
  Widget build(BuildContext context) {
    return _AppRestarterInherited(
      restart: restartApp,
      child: AnimatedSwitcher(
        duration: widget.transitionDuration,
        transitionBuilder:
            widget.transitionBuilder ??
            (Widget child, Animation<double> animation) {
              return FadeTransition(opacity: animation, child: child);
            },
        child: KeyedSubtree(key: _key, child: widget.child),
      ),
    );
  }
}

class _AppRestarterInherited extends InheritedWidget {
  final VoidCallback restart;

  const _AppRestarterInherited({required super.child, required this.restart});

  @override
  bool updateShouldNotify(_AppRestarterInherited oldWidget) => false;
}
