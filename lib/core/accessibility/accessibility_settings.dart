import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum ColorBlindMode { none, protanopia, deuteranopia, tritanopia }

class AccessibilitySettings {
  final double textScale;
  final ColorBlindMode colorBlindMode;
  final bool highContrast;
  final bool screenReaderEnabled;
  final bool reduceMotion;
  final bool reduceTransparency;
  final bool largeTargetMode;
  final double hapticIntensity;
  final bool audioFeedback;
  final double audioVolume;

  const AccessibilitySettings({
    this.textScale = 1.0,
    this.colorBlindMode = ColorBlindMode.none,
    this.highContrast = false,
    this.screenReaderEnabled = false,
    this.reduceMotion = false,
    this.reduceTransparency = false,
    this.largeTargetMode = false,
    this.hapticIntensity = 1.0,
    this.audioFeedback = true,
    this.audioVolume = 0.8,
  });

  AccessibilitySettings copyWith({
    double? textScale,
    ColorBlindMode? colorBlindMode,
    bool? highContrast,
    bool? screenReaderEnabled,
    bool? reduceMotion,
    bool? reduceTransparency,
    bool? largeTargetMode,
    double? hapticIntensity,
    bool? audioFeedback,
    double? audioVolume,
  }) {
    return AccessibilitySettings(
      textScale: textScale ?? this.textScale,
      colorBlindMode: colorBlindMode ?? this.colorBlindMode,
      highContrast: highContrast ?? this.highContrast,
      screenReaderEnabled: screenReaderEnabled ?? this.screenReaderEnabled,
      reduceMotion: reduceMotion ?? this.reduceMotion,
      reduceTransparency: reduceTransparency ?? this.reduceTransparency,
      largeTargetMode: largeTargetMode ?? this.largeTargetMode,
      hapticIntensity: hapticIntensity ?? this.hapticIntensity,
      audioFeedback: audioFeedback ?? this.audioFeedback,
      audioVolume: audioVolume ?? this.audioVolume,
    );
  }

  Map<String, dynamic> toJson() => {
    'textScale': textScale,
    'colorBlindMode': colorBlindMode.index,
    'high-contrast': highContrast,
    'screenReaderEnabled': screenReaderEnabled,
    'reduceMotion': reduceMotion,
    'reduceTransparency': reduceTransparency,
    'largeTargetMode': largeTargetMode,
    'hapticIntensity': hapticIntensity,
    'audioFeedback': audioFeedback,
    'audioVolume': audioVolume,
  };

  factory AccessibilitySettings.fromJson(Map<String, dynamic> json) {
    return AccessibilitySettings(
      textScale: (json['textScale'] as num?)?.toDouble() ?? 1.0,
      colorBlindMode: ColorBlindMode.values[json['colorBlindMode'] ?? 0],
      highContrast: json['high-contrast'] ?? false,
      screenReaderEnabled: json['screenReaderEnabled'] ?? false,
      reduceMotion: json['reduceMotion'] ?? false,
      reduceTransparency: json['reduceTransparency'] ?? false,
      largeTargetMode: json['largeTargetMode'] ?? false,
      hapticIntensity: (json['hapticIntensity'] as num?)?.toDouble() ?? 1.0,
      audioFeedback: json['audioFeedback'] ?? true,
      audioVolume: (json['audioVolume'] as num?)?.toDouble() ?? 0.8,
    );
  }
}

final accessibilitySettingsProvider =
    StateNotifierProvider<AccessibilitySettingsNotifier, AccessibilitySettings>(
      (ref) => AccessibilitySettingsNotifier(),
    );

class AccessibilitySettingsNotifier
    extends StateNotifier<AccessibilitySettings> {
  AccessibilitySettingsNotifier() : super(const AccessibilitySettings());

  void setTextScale(double scale) {
    state = state.copyWith(textScale: scale.clamp(0.8, 2.0));
  }

  void setColorBlindMode(ColorBlindMode mode) {
    state = state.copyWith(colorBlindMode: mode);
  }

  void setHighContrast(bool enabled) {
    state = state.copyWith(highContrast: enabled);
  }

  void setScreenReaderEnabled(bool enabled) {
    state = state.copyWith(screenReaderEnabled: enabled);
  }

  void setReduceMotion(bool enabled) {
    state = state.copyWith(reduceMotion: enabled);
  }

  void setReduceTransparency(bool enabled) {
    state = state.copyWith(reduceTransparency: enabled);
  }

  void setLargeTargetMode(bool enabled) {
    state = state.copyWith(largeTargetMode: enabled);
  }

  void setHapticIntensity(double intensity) {
    state = state.copyWith(hapticIntensity: intensity.clamp(0.0, 1.0));
  }

  void setAudioFeedback(bool enabled) {
    state = state.copyWith(audioFeedback: enabled);
  }

  void setAudioVolume(double volume) {
    state = state.copyWith(audioVolume: volume.clamp(0.0, 1.0));
  }

  void loadSettings(Map<String, dynamic> json) {
    state = AccessibilitySettings.fromJson(json);
  }

  void reset() {
    state = const AccessibilitySettings();
  }
}

class AccessibilityTheme {
  static Color adjustForColorBlind(Color color, ColorBlindMode mode) {
    if (mode == ColorBlindMode.none) return color;

    final hsl = HSLColor.fromColor(color);
    switch (mode) {
      case ColorBlindMode.protanopia:
        return _simulateProtanopia(hsl).toColor();
      case ColorBlindMode.deuteranopia:
        return _simulateDeuteranopia(hsl).toColor();
      case ColorBlindMode.tritanopia:
        return _simulateTritanopia(hsl).toColor();
      case ColorBlindMode.none:
        return color;
    }
  }

  static HSLColor _simulateProtanopia(HSLColor hsl) {
    // Protanopia: difficulty with red (adjust hue away from 0/360)
    double newHue = hsl.hue;
    if (newHue < 60 || newHue > 300) {
      newHue = 60 + (newHue > 300 ? (newHue - 300) : newHue) * 0.1;
    }
    return hsl.withHue(newHue.clamp(0.0, 360.0)).withSaturation(hsl.saturation * 0.8);
  }

  static HSLColor _simulateDeuteranopia(HSLColor hsl) {
    // Deuteranopia: difficulty with green (adjust hue away from 120)
    double newHue = hsl.hue;
    if (newHue > 60 && newHue < 180) {
      newHue = 60 - (newHue - 60) * 0.1;
    }
    return hsl.withHue(newHue.clamp(0.0, 360.0)).withSaturation(hsl.saturation * 0.8);
  }

  static HSLColor _simulateTritanopia(HSLColor hsl) {
    // Tritanopia: difficulty with blue (adjust hue away from 240)
    double newHue = hsl.hue;
    if (newHue > 180 && newHue < 300) {
      newHue = 180 - (newHue - 180) * 0.1;
    }
    return hsl.withHue(newHue.clamp(0.0, 360.0)).withSaturation(hsl.saturation * 0.8);
  }

  static List<Color> getAccessiblePalette(ColorBlindMode mode) {
    final baseColors = [
      Colors.green,
      Colors.blue,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
    ];
    return baseColors.map((c) => adjustForColorBlind(c, mode)).toList();
  }
}

class ResponsiveBreakpoints {
  static const double mobile = 320;
  static const double tablet = 768;
  static const double desktop = 1024;
  static const double wide = 1440;
}

class ScreenSizeInfo {
  final double width;
  final double height;
  final double devicePixelRatio;
  final bool isMobile;
  final bool isTablet;
  final bool isDesktop;
  final bool isPortrait;
  final bool isLandscape;

  ScreenSizeInfo({
    required this.width,
    required this.height,
    required this.devicePixelRatio,
  }) : isMobile = width < ResponsiveBreakpoints.tablet,
       isTablet =
           width >= ResponsiveBreakpoints.tablet &&
           width < ResponsiveBreakpoints.desktop,
       isDesktop = width >= ResponsiveBreakpoints.desktop,
       isPortrait = height > width,
       isLandscape = width > height;

  double get shortestSide => width < height ? width : height;
  double get longestSide => width > height ? width : height;
  bool get isWideScreen => longestSide >= ResponsiveBreakpoints.wide;
}

class ScreenSizeNotifier extends StateNotifier<ScreenSizeInfo> {
  ScreenSizeNotifier()
    : super(ScreenSizeInfo(width: 375, height: 812, devicePixelRatio: 1.0));

  void updateSize(double width, double height, double pixelRatio) {
    state = ScreenSizeInfo(
      width: width,
      height: height,
      devicePixelRatio: pixelRatio,
    );
  }
}

final screenSizeProvider =
    StateNotifierProvider<ScreenSizeNotifier, ScreenSizeInfo>((ref) {
      return ScreenSizeNotifier();
    });

class AccessibilityWrapper extends ConsumerWidget {
  final Widget child;

  const AccessibilityWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(accessibilitySettingsProvider);

    return MediaQuery(
      data: MediaQuery.of(
        context,
      ).copyWith(textScaler: TextScaler.linear(settings.textScale)),
      child: child,
    );
  }
}

class SemanticAnnouncer extends StatefulWidget {
  final String message;
  final Duration duration;

  const SemanticAnnouncer({
    super.key,
    required this.message,
    this.duration = const Duration(seconds: 3),
  });

  @override
  State<SemanticAnnouncer> createState() => _SemanticAnnouncerState();
}

class _SemanticAnnouncerState extends State<SemanticAnnouncer> {
  @override
  Widget build(BuildContext context) =>
      Semantics(liveRegion: true, child: Text(widget.message));
}
