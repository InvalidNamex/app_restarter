# AppRestarter

A powerful Flutter package that allows you to restart your application programmatically with advanced features like callbacks, animations, delayed restart, and conditional logic.

## ✨ Features

- 🔄 **Simple Restart**: Restart your app with a single function call
- 🎨 **Custom Animations**: Smooth transitions with customizable animation builders
- ⏱️ **Delayed Restart**: Schedule restarts with optional delays
- 🎯 **Conditional Restart**: Execute restarts based on custom conditions
- 🔔 **Lifecycle Callbacks**: Run code before and after restart
- 🚀 **Zero Dependencies**: Pure Flutter implementation
- 📱 **All Platforms**: Works on Android, iOS, Web, macOS, Windows, and Linux

## 📊 Comparison with flutter_phoenix

| Feature | app_restarter | flutter_phoenix |
|---------|--------------|-----------------|
| Basic Restart | ✅ | ✅ |
| Custom Animations | ✅ | ❌ |
| Lifecycle Callbacks | ✅ | ❌ |
| Delayed Restart | ✅ | ❌ |
| Conditional Restart | ✅ | ❌ |
| Error Handling | ✅ | ⚠️ |
| Active Maintenance | ✅ | ⚠️ |

## 🚀 Getting Started

Add `app_restarter` to your `pubspec.yaml`:

```yaml
dependencies:
  app_restarter: ^0.1.0
```

## 📖 Usage

### Basic Setup

Wrap your root widget with `AppRestarter`:

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
```

### Simple Restart

```dart
ElevatedButton(
  onPressed: () {
    AppRestarter.restartApp(context);
  },
  child: Text('Restart App'),
)
```

### Restart with Callbacks

```dart
AppRestarter.restartApp(
  context,
  config: RestartConfig(
    onBeforeRestart: () async {
      // Save user data, clear cache, etc.
      await saveUserData();
      print('Preparing to restart...');
    },
    onAfterRestart: () {
      // Re-initialize services, show welcome message, etc.
      print('Restart complete!');
    },
  ),
);
```

### Delayed Restart

```dart
AppRestarter.restartApp(
  context,
  config: RestartConfig(
    delay: Duration(seconds: 2),
  ),
);
```

### Conditional Restart

```dart
AppRestarter.restartApp(
  context,
  config: RestartConfig(
    condition: () => userIsLoggedOut,
  ),
);
```

### Custom Animations

```dart
AppRestarter(
  transitionDuration: Duration(milliseconds: 500),
  transitionBuilder: (context, animation, child) {
    return FadeTransition(
      opacity: animation,
      child: ScaleTransition(
        scale: Tween<double>(begin: 0.8, end: 1.0).animate(animation),
        child: child,
      ),
    );
  },
  child: MyApp(),
)
```

### All Features Combined

```dart
AppRestarter.restartApp(
  context,
  config: RestartConfig(
    delay: Duration(seconds: 1),
    condition: () => shouldRestart,
    onBeforeRestart: () async {
      await cleanup();
    },
    onAfterRestart: () {
      initialize();
    },
  ),
);
```

## 🎯 Common Use Cases

### Theme Switching
```dart
void switchTheme() async {
  await saveThemePreference(newTheme);
  AppRestarter.restartApp(context);
}
```

### Language Change
```dart
void changeLanguage(String locale) async {
  await setLocale(locale);
  AppRestarter.restartApp(
    context,
    config: RestartConfig(
      onBeforeRestart: () async {
        await clearCache();
      },
    ),
  );
}
```

### User Logout
```dart
void logout() {
  AppRestarter.restartApp(
    context,
    config: RestartConfig(
      onBeforeRestart: () async {
        await clearUserData();
        await clearAuthTokens();
      },
      delay: Duration(milliseconds: 500),
    ),
  );
}
```

## 💡 Best Practices

1. **Always wrap at the root level**: Place `AppRestarter` above `MaterialApp` or `CupertinoApp`
2. **Use callbacks for cleanup**: Leverage `onBeforeRestart` to save state or clear sensitive data
3. **Provide user feedback**: Show loading indicators or messages during restart
4. **Test conditions carefully**: Ensure your condition functions are reliable
5. **Keep animations smooth**: Use reasonable durations (300-500ms recommended)

## 🔧 Troubleshooting

### Error: "AppRestarter.restartApp() called with a context that does not contain an AppRestarter"

**Solution**: Make sure `AppRestarter` wraps your root widget:

```dart
// ❌ Wrong
void main() {
  runApp(MyApp());
}

// ✅ Correct
void main() {
  runApp(
    AppRestarter(child: MyApp()),
  );
}
```

### Restart not working as expected

**Solution**: Ensure you're using the correct context. The context must be a descendant of `AppRestarter`.

## 🔄 Migration from flutter_phoenix

Migrating from `flutter_phoenix` is straightforward:

```dart
// Before (flutter_phoenix)
Phoenix.rebirth(context);

// After (app_restarter)
AppRestarter.restartApp(context);
```

```dart
// Before (flutter_phoenix)
Phoenix(child: MyApp())

// After (app_restarter)
AppRestarter(child: MyApp())
```

## 📝 Additional Information

This package uses `KeyedSubtree` and `UniqueKey` to force a rebuild of the widget tree from the root. This effectively resets the state of all widgets in the tree without terminating the underlying OS process.

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🌟 Show Your Support

If you find this package helpful, please give it a ⭐ on [GitHub](https://github.com/InvalidNamex/app_restarter)!
