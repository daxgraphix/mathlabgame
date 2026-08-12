# Performance Architecture

## Global Performance Mode
The `lowPerformanceMode` is a global setting managed by `SettingsNotifier` in `lib/core/providers.dart`. It is persisted via `SharedPreferences` and allows the application to adapt its UI complexity for lower-end devices.

### How to use
Access the setting via Riverpod:
```dart
final lowPerformanceMode = ref.watch(settingsProvider.select((s) => s.lowPerformanceMode));
```

### Affected Components
When `lowPerformanceMode` is enabled:
1.  **Glassmorphism**: `PremiumGlassOverlay` and `GlassmorphicContainer` disable `BackdropFilter` (blur effects) and simplify gradients/shadows.
2.  **Animations**:
    *   `MainNavigationScaffold` background mesh painter is disabled.
    *   `AchievementsScreen` entry animations and particles are disabled.
    *   `OnboardingScreen` mesh background and floating symbols are disabled.
3.  **Visual Effects**:
    *   `AchievementParticlesPainter` is disabled.
    *   High-radius shadows are removed from text and containers.
    *   Complex gradients are replaced with simpler solid colors or basic linear gradients.

## Render Service
The `RenderService` (`lib/core/utils/render_service.dart`) provides a centralized way to capture widgets as images for PDF or Image exports.

### Methods
*   `captureFromKey(GlobalKey key)`: Captures a widget currently in the widget tree.
*   `safeCaptureWithOverlay(...)`: Safely renders a widget off-screen using an `OverlayEntry` to capture it without interrupting the user's view. This is used for generating high-quality reports in `ReportsScreen`.
