# Restarter

A Flutter package that allows you to restart your application programmatically. This is useful for scenarios like:
- Changing themes or languages dynamically.
- Resetting the app state during testing or debugging.
- Handling critical errors where a full restart is the safest recovery.

## Features

- Restart the entire application with a single function call.
- Simple API: `AppRestarter.restartApp(context)`.
- Lightweight and easy to integrate.

## Getting started

Add `app_restarter` to your `pubspec.yaml`:

```yaml
dependencies:
  app_restarter: ^0.0.1
```

## Usage

1. Wrap your root widget (usually `MaterialApp` or `CupertinoApp`) with `AppRestarter`.

```dart
import 'package:flutter/material.dart';
import 'package:app_restarter/app_restarter.dart';

void main() {
  runApp(
    AppRestarter(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage(),
    );
  }
}
```

2. Call `AppRestarter.restartApp(context)` whenever you want to restart the app.

```dart
ElevatedButton(
  onPressed: () {
    AppRestarter.restartApp(context);
  },
  child: Text('Restart App'),
)
```

## Additional Information

This package uses `KeyedSubtree` and `UniqueKey` to force a rebuild of the widget tree from the root. This effectively resets the state of all widgets in the tree.
