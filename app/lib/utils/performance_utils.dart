// lib/utils/performance_utils.dart

/// Utility class untuk performance monitoring dan async timing
///
/// Digunakan untuk mengukur waktu eksekusi async operations
/// dan membantu debugging performance issues
class PerformanceUtils {
  /// Measure waktu eksekusi async operation dengan logging
  ///
  /// Example:
  /// ```dart
  /// final products = await PerformanceUtils.measureAsync(
  ///   'Fetch Products',
  ///   () => _productService.getProducts(),
  /// );
  /// ```
  static Future<T> measureAsync<T>(
    String label,
    Future<T> Function() operation,
  ) async {
    final stopwatch = Stopwatch()..start();
    print('⏱️  [$label] Starting...');

    try {
      final result = await operation();
      stopwatch.stop();
      final elapsed = stopwatch.elapsedMilliseconds;

      // Color code based on duration
      if (elapsed < 1000) {
        print('✅ [$label] Completed in ${elapsed}ms (Fast)');
      } else if (elapsed < 3000) {
        print('⚠️  [$label] Completed in ${elapsed}ms (Acceptable)');
      } else {
        print('❌ [$label] Completed in ${elapsed}ms (Slow!)');
      }

      return result;
    } catch (e) {
      stopwatch.stop();
      print('💥 [$label] Failed in ${stopwatch.elapsedMilliseconds}ms');
      print('   Error: $e');
      rethrow;
    }
  }

  /// Measure waktu eksekusi synchronous operation
  ///
  /// Example:
  /// ```dart
  /// final result = PerformanceUtils.measureSync(
  ///   'Sort Orders',
  ///   () => orders.sort((a, b) => a.date.compareTo(b.date)),
  /// );
  /// ```
  static T measureSync<T>(String label, T Function() operation) {
    final stopwatch = Stopwatch()..start();
    print('⏱️  [$label] Starting...');

    try {
      final result = operation();
      stopwatch.stop();
      final elapsed = stopwatch.elapsedMilliseconds;

      if (elapsed < 16) {
        print('✅ [$label] Completed in ${elapsed}ms (< 1 frame)');
      } else if (elapsed < 100) {
        print('⚠️  [$label] Completed in ${elapsed}ms (Multiple frames)');
      } else {
        print('❌ [$label] Completed in ${elapsed}ms (Blocking!)');
      }

      return result;
    } catch (e) {
      stopwatch.stop();
      print('💥 [$label] Failed in ${stopwatch.elapsedMilliseconds}ms');
      print('   Error: $e');
      rethrow;
    }
  }

  /// Log memory usage (requires import 'dart:developer')
  ///
  /// Example:
  /// ```dart
  /// PerformanceUtils.logMemoryUsage('After loading products');
  /// ```
  static void logMemoryUsage(String label) {
    // Note: Actual memory measurement requires dart:developer
    // This is a placeholder for manual memory tracking
    print('📊 [$label] Memory checkpoint');
    print('   Use DevTools Memory tab for actual measurements');
  }

  /// Start a named timer for manual timing
  static final Map<String, Stopwatch> _timers = {};

  /// Start a timer with a name
  static void startTimer(String name) {
    _timers[name] = Stopwatch()..start();
    print('⏱️  [$name] Timer started');
  }

  /// Stop a timer and log elapsed time
  static void stopTimer(String name) {
    final timer = _timers[name];
    if (timer == null) {
      print('⚠️  [$name] Timer not found');
      return;
    }

    timer.stop();
    final elapsed = timer.elapsedMilliseconds;
    print('⏹️  [$name] Timer stopped: ${elapsed}ms');
    _timers.remove(name);
  }

  /// Get elapsed time without stopping
  static int? getElapsed(String name) {
    return _timers[name]?.elapsedMilliseconds;
  }

  /// Log navigation performance
  static void logNavigation(String from, String to, int durationMs) {
    if (durationMs < 200) {
      print('🚀 Navigation: $from → $to (${durationMs}ms) ✅');
    } else if (durationMs < 500) {
      print('🚀 Navigation: $from → $to (${durationMs}ms) ⚠️');
    } else {
      print('🚀 Navigation: $from → $to (${durationMs}ms) ❌ Slow!');
    }
  }

  /// Print a performance summary
  static void printSummary(Map<String, int> timings) {
    print('\n📊 ===== PERFORMANCE SUMMARY =====');
    timings.forEach((key, value) {
      final status = value < 1000
          ? '✅'
          : value < 3000
          ? '⚠️'
          : '❌';
      print('   $status $key: ${value}ms');
    });
    print('==================================\n');
  }
}
