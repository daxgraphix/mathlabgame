import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/performance/performance_models.dart';
import '../../../core/performance/isar_service.dart';
import 'game_session_provider.dart';
import 'session_stats_provider.dart';

class PerformanceTrends {
  final List<PerformanceDataPoint> dataPoints;

  PerformanceTrends({this.dataPoints = const []});

  double get averageAccuracy => dataPoints.isEmpty 
      ? 0.0 
      : dataPoints.map((e) => e.accuracy).reduce((a, b) => a + b) / dataPoints.length;

  double get peakAccuracy => dataPoints.isEmpty
      ? 0.0
      : dataPoints.map((e) => e.accuracy).reduce((a, b) => a > b ? a : b);

  double get averageHeat => dataPoints.isEmpty
      ? 1.0
      : dataPoints.map((e) => e.avgHeatIndex ?? 1.0).reduce((a, b) => a + b) / dataPoints.length;

  List<double> get heatHistory => dataPoints
      .map((e) => e.avgHeatIndex ?? 1.0)
      .toList();

  List<double> get accuracyHistory => dataPoints.map((e) => e.accuracy).toList();

  List<DateTime> get timestamps => dataPoints.map((e) => e.timestamp).toList();

  Map<String, double> get averageTimeByMode {
    final result = <String, double>{};
    final counts = <String, int>{};
    for (final point in dataPoints) {
      if (point.mode != null && point.averageTime > 0) {
        result[point.mode!] = (result[point.mode!] ?? 0) + point.averageTime;
        counts[point.mode!] = (counts[point.mode!] ?? 0) + 1;
      }
    }
    for (final key in result.keys) {
      result[key] = result[key]! / (counts[key] ?? 1);
    }
    return result;
  }

  List<int> get timingTrend {
    if (dataPoints.length < 2) return dataPoints.map((e) => e.averageTime).toList();
    final windowSize = dataPoints.length > 20 ? 5 : 3;
    final trends = <int>[];
    for (int i = 0; i < dataPoints.length; i++) {
      final start = (i - windowSize + 1).clamp(0, i);
      final window = dataPoints.sublist(start, i + 1);
      final avg = window.map((e) => e.averageTime).reduce((a, b) => a + b) / window.length;
      trends.add(avg.round());
    }
    return trends;
  }

  int? get averageTimeToFirstAnswer {
    final values = dataPoints.map((e) => e.timeToFirstAnswer).whereType<int>().toList();
    if (values.isEmpty) return null;
    return (values.reduce((a, b) => a + b) / values.length).round();
  }
}

class PerformanceTrendsNotifier extends StateNotifier<PerformanceTrends> {
  final IsarService _isarService;
  static const int _batchSize = 5;
  final List<PerformanceDataPoint> _pendingPoints = [];

  PerformanceTrendsNotifier(this._isarService) : super(PerformanceTrends()) {
    _loadData();
  }

  Future<void> _loadData() async {
    final data = await _isarService.getAllPerformanceData();
    state = PerformanceTrends(dataPoints: data);
  }

  void addDataPoint({
    required double accuracy,
    required int averageTimeMs,
    required int streak,
    double? avgHeatIndex,
    String? mode,
    int? timeToFirstAnswer,
  }) {
    final point = PerformanceDataPoint(
      timestamp: DateTime.now(),
      accuracy: accuracy,
      averageTime: averageTimeMs,
      streak: streak,
      avgHeatIndex: avgHeatIndex,
      mode: mode,
      timeToFirstAnswer: timeToFirstAnswer,
    );

    _pendingPoints.add(point);
    state = PerformanceTrends(dataPoints: [...state.dataPoints, point]);

    if (_pendingPoints.length >= _batchSize) {
      _flush();
    }
  }

  Future<void> _flush() async {
    if (_pendingPoints.isEmpty) return;
    final batch = List<PerformanceDataPoint>.from(_pendingPoints);
    _pendingPoints.clear();
    await _isarService.savePerformanceDataBatch(batch);
  }

  Future<void> flush() async {
    await _flush();
  }
}

final isarServiceProvider = Provider<IsarService>((ref) => IsarService());

final performanceTrendsProvider = StateNotifierProvider<PerformanceTrendsNotifier, PerformanceTrends>((ref) {
  final isar = ref.watch(isarServiceProvider);
  return PerformanceTrendsNotifier(isar);
});

class PlayerPerformanceNotifier extends StateNotifier<void> {
  final Ref ref;
  PlayerPerformanceNotifier(this.ref) : super(null);

  void recordAnswer({
    required String operation,
    required bool isCorrect,
    required int responseTimeMs,
    int hintsUsed = 0,
    List<String> concepts = const [],
  }) {
    final heatIndex = ref.read(gameSessionProvider)?.heatIndex ?? 1.0;
    final streak = ref.read(sessionStatsProvider).currentStreak;
    
    // For single answers, we treat accuracy as 100 or 0
    ref.read(performanceTrendsProvider.notifier).addDataPoint(
      accuracy: isCorrect ? 100.0 : 0.0,
      averageTimeMs: responseTimeMs,
      streak: streak,
      avgHeatIndex: heatIndex,
      mode: operation,
    );
  }
}

final playerPerformanceProvider = StateNotifierProvider<PlayerPerformanceNotifier, void>((ref) {
  return PlayerPerformanceNotifier(ref);
});
