import 'package:flutter/material.dart';

/// A widget that allows restarting the entire application.
///
/// Wrap your root widget (usually [MaterialApp] or [CupertinoApp]) with [AppRestarter].
/// Then call [AppRestarter.restartApp(context)] to restart the app.
class AppRestarter extends StatefulWidget {
  final Widget child;

  const AppRestarter({super.key, required this.child});

  @override
  AppRestarterState createState() => AppRestarterState();

  /// Triggers a restart of the application.
  ///
  /// This finds the [AppRestarter] in the widget tree and calls its restart method.
  static void restartApp(BuildContext context) {
    final _AppRestarterInherited? inherited =
        context.dependOnInheritedWidgetOfExactType<_AppRestarterInherited>();
    inherited?.restart();
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
      child: KeyedSubtree(
        key: _key,
        child: widget.child,
      ),
    );
  }
}

class _AppRestarterInherited extends InheritedWidget {
  final VoidCallback restart;

  const _AppRestarterInherited({
    required super.child,
    required this.restart,
  });

  @override
  bool updateShouldNotify(_AppRestarterInherited oldWidget) => false;
}
