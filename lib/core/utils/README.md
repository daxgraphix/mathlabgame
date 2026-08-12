# Utility Services

## RenderService
Located in `lib/core/utils/render_service.dart`.

This service replaces direct `OverlayEntry` manipulation in feature screens, providing a robust way to convert widgets to images.

### Example usage in Reports:
```dart
final image = await RenderService.safeCaptureWithOverlay(
  context,
  MyReportWidget(),
  size: const Size(800, 1200),
);
```
