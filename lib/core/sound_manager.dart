import 'dart:io' show Platform;
import 'dart:developer';
import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart' show AudioPlayer, AssetSource, ReleaseMode;
import 'package:shared_preferences/shared_preferences.dart';

class HapticManager {
  static final HapticManager _instance = HapticManager._internal();
  static HapticManager get instance => _instance;
  HapticManager._internal();

  bool _hapticsEnabled = true;
  bool _platformSupportsHaptics = true;

  Future<void> initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _hapticsEnabled = prefs.getBool('haptics_enabled') ?? true;
      
      final String? settingsJson = prefs.getString('game_settings');
      if (settingsJson != null) {
        final Map<String, dynamic> settings = Map<String, dynamic>.from(jsonDecode(settingsJson));
        _hapticsEnabled = settings['vibrationEnabled'] ?? _hapticsEnabled;
      }
    } catch (e) {
      _hapticsEnabled = true;
    }

    if (!Platform.isAndroid && !Platform.isIOS) {
      _platformSupportsHaptics = false;
    }
  }

  Future<void> setHapticsEnabled(bool enabled) async {
    _hapticsEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('haptics_enabled', enabled);
  }

  bool get isEnabled => _hapticsEnabled && _platformSupportsHaptics;

  Future<void> lightImpact() async {
    if (!isEnabled) return;
    await HapticFeedback.lightImpact();
  }

  Future<void> mediumImpact() async {
    if (!isEnabled) return;
    await HapticFeedback.mediumImpact();
  }

  Future<void> heavyImpact() async {
    if (!isEnabled) return;
    await HapticFeedback.heavyImpact();
  }

  Future<void> selectionClick() async {
    if (!isEnabled) return;
    await HapticFeedback.selectionClick();
  }

  Future<void> successPattern() async {
    if (!isEnabled) return;
    await HapticFeedback.mediumImpact();
    await Future.delayed(const Duration(milliseconds: 60));
    await HapticFeedback.lightImpact();
  }

  Future<void> errorPattern() async {
    if (!isEnabled) return;
    await HapticFeedback.heavyImpact();
    await Future.delayed(const Duration(milliseconds: 80));
    await HapticFeedback.mediumImpact();
  }

  Future<void> correctAnswerPattern() async {
    if (!isEnabled) return;
    await HapticFeedback.mediumImpact();
    await Future.delayed(const Duration(milliseconds: 40));
    await HapticFeedback.lightImpact();
  }

  Future<void> wrongAnswerPattern() async {
    if (!isEnabled) return;
    await HapticFeedback.heavyImpact();
    await Future.delayed(const Duration(milliseconds: 50));
    await HapticFeedback.heavyImpact();
  }

  Future<void> levelUpPattern() async {
    if (!isEnabled) return;
    await HapticFeedback.heavyImpact();
    await Future.delayed(const Duration(milliseconds: 120));
    await HapticFeedback.mediumImpact();
    await Future.delayed(const Duration(milliseconds: 80));
    await HapticFeedback.mediumImpact();
  }

  Future<void> streakPattern(int count) async {
    if (!isEnabled) return;
    final intensity = (count / 10).clamp(0.0, 1.0);
    if (intensity < 0.3) {
      await HapticFeedback.lightImpact();
    } else if (intensity < 0.7) {
      await HapticFeedback.mediumImpact();
    } else {
      await HapticFeedback.heavyImpact();
    }
  }

  Future<void> milestonePattern() async {
    if (!isEnabled) return;
    for (int i = 0; i < 3; i++) {
      await HapticFeedback.mediumImpact();
      await Future.delayed(const Duration(milliseconds: 100));
    }
  }

  Future<void> transitionPattern() async {
    if (!isEnabled) return;
    await HapticFeedback.selectionClick();
  }

  Future<void> timerWarningPattern() async {
    if (!isEnabled) return;
    await HapticFeedback.lightImpact();
  }

  Future<void> vibrate() async {
    if (!isEnabled) return;
    await HapticFeedback.vibrate();
  }

  Future<void> achievementPattern() async {
    if (!isEnabled) return;
    await HapticFeedback.mediumImpact();
    await Future.delayed(const Duration(milliseconds: 100));
    await HapticFeedback.heavyImpact();
    await Future.delayed(const Duration(milliseconds: 150));
    await HapticFeedback.heavyImpact();
  }
}

class SoundManager {
  static final SoundManager _instance = SoundManager._internal();
  static SoundManager get instance => _instance;
  SoundManager._internal();

  bool _isMuted = false;
  bool _soundEnabled = true;
  double _volume = 1.0;
  bool _isInitialized = false;
  double _currentHeatIndex = 1.0;
  
  // Audio Pooling for overlapping sounds
  final Map<String, List<AudioPlayer>> _multiPlayerPool = {};
  final Map<String, int> _poolIndices = {};
  static const int _maxSimultaneous = 3;

  // Dedicated BGM players for crossfading
  late AudioPlayer _bgmPlayerA;
  late AudioPlayer _bgmPlayerB;
  bool _usingPlayerA = true;
  String? _currentBgm;

  Future<void> initialize() async {
    if (_isInitialized) return;
    await _loadPreferences();
    
    _bgmPlayerA = AudioPlayer()..setReleaseMode(ReleaseMode.loop);
    _bgmPlayerB = AudioPlayer()..setReleaseMode(ReleaseMode.loop);
    
    _isInitialized = true;
  }

  Future<void> _loadPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isMuted = prefs.getBool('sound_muted') ?? false;
      _soundEnabled = prefs.getBool('sound_enabled') ?? true;
      _volume = prefs.getDouble('sound_volume') ?? 1.0;

      final String? settingsJson = prefs.getString('game_settings');
      if (settingsJson != null) {
        final Map<String, dynamic> settings = Map<String, dynamic>.from(jsonDecode(settingsJson));
        _soundEnabled = settings['soundEnabled'] ?? _soundEnabled;
        _isMuted = !_soundEnabled;
      }
    } catch (e) {
      _isMuted = false;
      _soundEnabled = true;
      _volume = 1.0;
    }
  }

  Future<void> _savePreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('sound_muted', _isMuted);
      await prefs.setBool('sound_enabled', _soundEnabled);
      await prefs.setDouble('sound_volume', _volume);
    } catch (e) {
      // Ignore preference save errors
    }
  }

  double get volume => _volume;
  bool get isMuted => _isMuted;
  bool get soundEnabled => _soundEnabled;

  Future<void> setMuted(bool muted) async {
    _isMuted = muted;
    _soundEnabled = !muted;
    if (muted) {
      await _bgmPlayerA.setVolume(0);
      await _bgmPlayerB.setVolume(0);
    } else {
      await _bgmPlayerA.setVolume(_volume * 0.4);
      await _bgmPlayerB.setVolume(_volume * 0.4);
    }
    await _savePreferences();
  }

  Future<void> setVolume(double volume) async {
    _volume = volume.clamp(0.0, 1.0);
    if (!_isMuted && _soundEnabled) {
      await _bgmPlayerA.setVolume(_volume * 0.4);
      await _bgmPlayerB.setVolume(_volume * 0.4);
    }
    await _savePreferences();
  }

  Future<void> playEffect(String effect, {bool randomizePitch = false}) async {
    if (_isMuted || !_soundEnabled) return;
    await _playSound(effect, randomizePitch: randomizePitch);
  }

  Future<void> playClick() async {
    if (_isMuted || !_soundEnabled) {
      HapticManager.instance.selectionClick();
      return;
    }
    await _playSound('click', randomizePitch: true);
    await HapticManager.instance.selectionClick();
  }

  Future<void> playCorrect() async {
    if (_isMuted || !_soundEnabled) {
      HapticManager.instance.correctAnswerPattern();
      return;
    }
    await _playSound('correct');
    await HapticManager.instance.correctAnswerPattern();
  }

  Future<void> playIncorrect() async {
    if (_isMuted || !_soundEnabled) {
      HapticManager.instance.wrongAnswerPattern();
      return;
    }
    await _playSound('incorrect');
    await HapticManager.instance.wrongAnswerPattern();
  }

  Future<void> playLevelUp() async {
    if (_isMuted || !_soundEnabled) {
      HapticManager.instance.levelUpPattern();
      return;
    }
    await _playSound('level_up');
    await HapticManager.instance.levelUpPattern();
  }

  Future<void> playAchievement() async {
    if (_isMuted || !_soundEnabled) {
      HapticManager.instance.achievementPattern();
      return;
    }
    await _playSound('achievement');
    await HapticManager.instance.achievementPattern();
  }

  Future<void> playBackgroundMusic(String trackName) async {
    if (_isMuted || !_soundEnabled || _currentBgm == trackName) return;
    
    _currentBgm = trackName;
    final nextPlayer = _usingPlayerA ? _bgmPlayerB : _bgmPlayerA;
    final currentPlayer = _usingPlayerA ? _bgmPlayerA : _bgmPlayerB;

    try {
      await nextPlayer.setVolume(0);
      await nextPlayer.play(AssetSource('sounds/$trackName.mp3'));
      
      // Crossfade
      for (int i = 0; i <= 10; i++) {
        await Future.delayed(const Duration(milliseconds: 100));
        await nextPlayer.setVolume((i / 10) * _volume * 0.4);
        await currentPlayer.setVolume(((10 - i) / 10) * _volume * 0.4);
      }
      
      await currentPlayer.stop();
      _usingPlayerA = !_usingPlayerA;
    } catch (e) {
      log('BGM Error: $e');
    }
  }

  Future<void> stopBackgroundMusic() async {
    await _bgmPlayerA.stop();
    await _bgmPlayerB.stop();
    _currentBgm = null;
  }

  Future<void> _playSound(String key, {bool randomizePitch = false}) async {
    if (!_isInitialized) return;
    final soundFile = _getSoundFile(key);
    
    try {
      final players = _multiPlayerPool.putIfAbsent(key, () => []);
      final index = _poolIndices[key] ?? 0;
      
      AudioPlayer player;
      if (players.length < _maxSimultaneous) {
        player = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
        players.add(player);
      } else {
        player = players[index % _maxSimultaneous];
      }
      
      _poolIndices[key] = (index + 1) % _maxSimultaneous;

      await player.stop();
      await player.setVolume(_volume);
      
      double rate = 1.0 + (_currentHeatIndex - 1.0) * 0.1;
      if (randomizePitch) {
        rate += (math.Random().nextDouble() - 0.5) * 0.15;
      }
      await player.setPlaybackRate(rate.clamp(0.5, 2.0));
      
      await player.play(AssetSource('sounds/$soundFile'));
    } catch (e) {
      log('SFX Error ($key): $e');
    }
  }

  void updateHeat(double heatIndex) {
    _currentHeatIndex = heatIndex.clamp(1.0, 4.0);
    final rate = 1.0 + (_currentHeatIndex - 1.0) * 0.1;
    _bgmPlayerA.setPlaybackRate(rate);
    _bgmPlayerB.setPlaybackRate(rate);
  }

  String _getSoundFile(String key) {
    switch (key) {
      case 'click': return 'click.wav';
      case 'correct': return 'completion.wav';
      case 'incorrect': return 'bling.wav';
      case 'level_up': return 'levelup.wav';
      case 'achievement': return 'bling.wav';
      case 'startup': return 'click.wav';
      case 'game_start': return 'click.wav';
      case 'timer_warning': return 'click.wav';
      case 'hint': return 'click.wav';
      default: return 'click.wav';
    }
  }

  Future<void> playStartupSound() async => playEffect('startup');
  Future<void> playSuccess() async => playCorrect();
  Future<void> playComplete() async => playCorrect();
  Future<void> playTransition() async => playClick();
  Future<void> playNavigation() async => playClick();
  Future<void> playButtonPress() async => playClick();
  Future<void> playGameStart() async => playEffect('game_start');
  Future<void> playWrongAnswer() async => playIncorrect();
  Future<void> playCorrectAnswer() async => playCorrect();
  Future<void> playTimerTick() async => playEffect('timer_warning');
  Future<void> playHint() async => playEffect('hint');
}
