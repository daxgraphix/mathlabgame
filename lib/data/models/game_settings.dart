class GameSettings {
  final bool soundEnabled;
  final bool musicEnabled;
  final bool vibrationEnabled;
  final String themeMode;
  final String language;
  final bool notificationsEnabled;
  final bool focusMode;
  final bool lowPerformanceMode;

  const GameSettings({
    this.soundEnabled = true,
    this.musicEnabled = true,
    this.vibrationEnabled = true,
    this.themeMode = 'system',
    this.language = 'en',
    this.notificationsEnabled = true,
    this.focusMode = false,
    this.lowPerformanceMode = false,
  });

  GameSettings copyWith({
    bool? soundEnabled,
    bool? musicEnabled,
    bool? vibrationEnabled,
    String? themeMode,
    String? language,
    bool? notificationsEnabled,
    bool? focusMode,
    bool? lowPerformanceMode,
  }) {
    return GameSettings(
      soundEnabled: soundEnabled ?? this.soundEnabled,
      musicEnabled: musicEnabled ?? this.musicEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      themeMode: themeMode ?? this.themeMode,
      language: language ?? this.language,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      focusMode: focusMode ?? this.focusMode,
      lowPerformanceMode: lowPerformanceMode ?? this.lowPerformanceMode,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'soundEnabled': soundEnabled,
      'musicEnabled': musicEnabled,
      'vibrationEnabled': vibrationEnabled,
      'themeMode': themeMode,
      'language': language,
      'notificationsEnabled': notificationsEnabled,
      'focusMode': focusMode,
      'lowPerformanceMode': lowPerformanceMode,
    };
  }

  factory GameSettings.fromJson(Map<String, dynamic> json) {
    return GameSettings(
      soundEnabled: json['soundEnabled'] ?? true,
      musicEnabled: json['musicEnabled'] ?? true,
      vibrationEnabled: json['vibrationEnabled'] ?? true,
      themeMode: json['themeMode'] ?? 'system',
      language: json['language'] ?? 'en',
      notificationsEnabled: json['notificationsEnabled'] ?? true,
      focusMode: json['focusMode'] ?? false,
      lowPerformanceMode: json['lowPerformanceMode'] ?? false,
    );
  }
}
