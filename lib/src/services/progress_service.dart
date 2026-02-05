import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/reading_progress.dart';

/// Service for managing reading progress
class ProgressService {
  static const String _progressKey = 'epub_reading_progress';

  /// Saves reading progress
  static Future<void> saveProgress(ReadingProgress progress) async {
    final prefs = await SharedPreferences.getInstance();
    final progressJson = progress.toJson();
    await prefs.setString(
      '${_progressKey}_${progress.bookId}',
      json.encode(progressJson),
    );
  }

  /// Gets reading progress for a specific book
  static Future<ReadingProgress?> getProgress(String bookId) async {
    final prefs = await SharedPreferences.getInstance();
    final progressJson = prefs.getString('${_progressKey}_$bookId');

    if (progressJson == null) return null;

    try {
      final Map<String, dynamic> progressMap = json.decode(progressJson);
      return ReadingProgress.fromJson(progressMap);
    } catch (e) {
      return null;
    }
  }

  /// Updates reading progress
  static Future<void> updateProgress({
    required String bookId,
    int? currentChapterIndex,
    double? chapterProgress,
    double? bookProgress,
    int? currentPage,
    int? totalPages,
    int? additionalReadingTime,
  }) async {
    final existingProgress = await getProgress(bookId);

    if (existingProgress != null) {
      final updatedProgress = existingProgress.copyWith(
        currentChapterIndex:
            currentChapterIndex ?? existingProgress.currentChapterIndex,
        chapterProgress: chapterProgress ?? existingProgress.chapterProgress,
        bookProgress: bookProgress ?? existingProgress.bookProgress,
        currentPage: currentPage ?? existingProgress.currentPage,
        totalPages: totalPages ?? existingProgress.totalPages,
        totalReadingTime: additionalReadingTime != null
            ? existingProgress.totalReadingTime + additionalReadingTime
            : existingProgress.totalReadingTime,
        lastReadAt: DateTime.now(),
      );

      await saveProgress(updatedProgress);
    } else {
      // Create new progress if none exists
      final newProgress = ReadingProgress.initial(bookId).copyWith(
        currentChapterIndex: currentChapterIndex ?? 0,
        chapterProgress: chapterProgress ?? 0.0,
        bookProgress: bookProgress ?? 0.0,
        currentPage: currentPage,
        totalPages: totalPages,
        totalReadingTime: additionalReadingTime ?? 0,
      );

      await saveProgress(newProgress);
    }
  }

  /// Calculates and updates book progress based on chapter progress
  static Future<void> updateBookProgress(
    String bookId,
    int totalChapters,
  ) async {
    final progress = await getProgress(bookId);
    if (progress == null) return;

    final bookProgress =
        (progress.currentChapterIndex + progress.chapterProgress) /
        totalChapters;

    await updateProgress(
      bookId: bookId,
      bookProgress: bookProgress.clamp(0.0, 1.0),
    );
  }

  /// Gets reading statistics for a book
  static Future<Map<String, dynamic>> getReadingStats(String bookId) async {
    final progress = await getProgress(bookId);

    if (progress == null) {
      return {
        'totalReadingTime': 0,
        'averageReadingSpeed': 0.0,
        'estimatedTimeToFinish': null,
        'lastReadAt': null,
        'daysSinceLastRead': null,
      };
    }

    final now = DateTime.now();
    final daysSinceLastRead = now.difference(progress.lastReadAt).inDays;

    return {
      'totalReadingTime': progress.totalReadingTime,
      'averageReadingSpeed': progress.readingSpeed ?? 0.0,
      'estimatedTimeToFinish': progress.estimatedTimeToFinish,
      'lastReadAt': progress.lastReadAt,
      'daysSinceLastRead': daysSinceLastRead,
    };
  }

  /// Gets reading progress for all books
  static Future<List<ReadingProgress>> getAllProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    final progressKeys = keys.where((key) => key.startsWith(_progressKey));

    final allProgress = <ReadingProgress>[];

    for (final key in progressKeys) {
      final progressJson = prefs.getString(key);
      if (progressJson != null) {
        try {
          final Map<String, dynamic> progressMap = json.decode(progressJson);
          final progress = ReadingProgress.fromJson(progressMap);
          allProgress.add(progress);
        } catch (e) {
          // Skip invalid progress data
        }
      }
    }

    // Sort by last read date (most recent first)
    allProgress.sort((a, b) => b.lastReadAt.compareTo(a.lastReadAt));

    return allProgress;
  }

  /// Gets recently read books
  static Future<List<ReadingProgress>> getRecentlyReadBooks({
    int limit = 10,
  }) async {
    final allProgress = await getAllProgress();
    return allProgress.take(limit).toList();
  }

  /// Gets books by reading status
  static Future<Map<String, List<ReadingProgress>>> getBooksByStatus() async {
    final allProgress = await getAllProgress();

    final currentlyReading = <ReadingProgress>[];
    final finished = <ReadingProgress>[];
    final notStarted = <ReadingProgress>[];

    for (final progress in allProgress) {
      if (progress.isFinished) {
        finished.add(progress);
      } else if (progress.bookProgress > 0.0) {
        currentlyReading.add(progress);
      } else {
        notStarted.add(progress);
      }
    }

    return {
      'currentlyReading': currentlyReading,
      'finished': finished,
      'notStarted': notStarted,
    };
  }

  /// Resets reading progress for a book
  static Future<void> resetProgress(String bookId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('${_progressKey}_$bookId');
  }

  /// Exports reading progress for a book to JSON
  static Future<String> exportProgress(String bookId) async {
    final progress = await getProgress(bookId);
    if (progress == null) return '{}';
    return json.encode(progress.toJson());
  }

  /// Imports reading progress for a book from JSON
  static Future<void> importProgress(String bookId, String jsonData) async {
    try {
      final Map<String, dynamic> progressMap = json.decode(jsonData);
      final progress = ReadingProgress.fromJson(progressMap);

      // Update book ID to match current book
      final updatedProgress = progress.copyWith(bookId: bookId);
      await saveProgress(updatedProgress);
    } catch (e) {
      throw Exception('Failed to import reading progress: $e');
    }
  }

  /// Calculates estimated time to finish based on current progress and reading speed
  static Future<Duration?> calculateEstimatedTimeToFinish(
    String bookId,
    int totalWords,
  ) async {
    final progress = await getProgress(bookId);
    if (progress == null ||
        progress.readingSpeed == null ||
        progress.readingSpeed! <= 0) {
      return null;
    }

    final wordsRead = (totalWords * progress.bookProgress).round();
    final wordsRemaining = totalWords - wordsRead;
    final minutesRemaining = wordsRemaining / progress.readingSpeed!;

    return Duration(minutes: minutesRemaining.ceil());
  }

  /// Updates reading speed based on recent reading session
  static Future<void> updateReadingSpeed(
    String bookId,
    int wordsRead,
    int timeSpentSeconds,
  ) async {
    if (timeSpentSeconds <= 0) return;

    final wordsPerMinute = (wordsRead / timeSpentSeconds * 60).roundToDouble();

    final progress = await getProgress(bookId);
    if (progress != null) {
      // Calculate weighted average with existing reading speed
      final existingSpeed = progress.readingSpeed ?? wordsPerMinute;
      final newSpeed = (existingSpeed * 0.7) + (wordsPerMinute * 0.3);

      await updateProgress(
        bookId: bookId,
        additionalReadingTime: timeSpentSeconds,
      );

      // Update the reading speed separately since it's not in the updateProgress method
      final updatedProgress = progress.copyWith(
        readingSpeed: newSpeed,
        totalReadingTime: progress.totalReadingTime + timeSpentSeconds,
        lastReadAt: DateTime.now(),
      );

      await saveProgress(updatedProgress);
    }
  }
}
