## 0.2.0

* **Major Feature Release** - Enhanced with powerful new capabilities
* Added lifecycle callbacks (`onBeforeRestart`, `onAfterRestart`)
* **BREAKING**: Changed `onAfterRestart` from `VoidCallback` to `Future<void> Function()` for async support
* **GetX Compatibility**: Full support for GetX state management with dependency reinitialization
* Added custom animation support with `transitionBuilder`
* Added delayed restart capability
* Added conditional restart logic
* Added comprehensive error handling
* Improved documentation with examples and migration guide
* Added GetX integration guide and example (`example/lib/getx_example.dart`)
* Updated example app with demonstrations of all features

## 0.0.1

* Initial release of the `app_restarter` package.
* Includes `AppRestarter` widget for programmatic app restart.
