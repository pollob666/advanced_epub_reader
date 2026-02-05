import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/annotation.dart';

/// Service for managing text annotations and highlights
class AnnotationService {
  static const String _annotationsKey = 'epub_annotations';

  /// Saves an annotation
  static Future<void> saveAnnotation(Annotation annotation) async {
    final annotations = await getAnnotations(annotation.bookId);

    // Remove existing annotation with same ID if exists
    annotations.removeWhere((a) => a.id == annotation.id);

    // Add new annotation
    annotations.add(annotation);

    // Save all annotations for this book
    await _saveAnnotationsForBook(annotation.bookId, annotations);
  }

  /// Deletes an annotation
  static Future<void> deleteAnnotation(
    String annotationId,
    String bookId,
  ) async {
    final annotations = await getAnnotations(bookId);
    annotations.removeWhere((a) => a.id == annotationId);
    await _saveAnnotationsForBook(bookId, annotations);
  }

  /// Gets all annotations for a specific book
  static Future<List<Annotation>> getAnnotations(String bookId) async {
    final prefs = await SharedPreferences.getInstance();
    final annotationsJson = prefs.getString('${_annotationsKey}_$bookId');

    if (annotationsJson == null) return [];

    try {
      final List<dynamic> annotationsList = json.decode(annotationsJson);
      return annotationsList
          .map((json) => Annotation.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Gets a specific annotation by ID
  static Future<Annotation?> getAnnotation(
    String annotationId,
    String bookId,
  ) async {
    final annotations = await getAnnotations(bookId);
    try {
      return annotations.firstWhere((a) => a.id == annotationId);
    } catch (e) {
      return null;
    }
  }

  /// Gets annotations by chapter index
  static Future<List<Annotation>> getAnnotationsByChapter(
    String bookId,
    int chapterIndex,
  ) async {
    final annotations = await getAnnotations(bookId);
    return annotations.where((a) => a.chapterIndex == chapterIndex).toList();
  }

  /// Gets annotations by type
  static Future<List<Annotation>> getAnnotationsByType(
    String bookId,
    AnnotationType type,
  ) async {
    final annotations = await getAnnotations(bookId);
    return annotations.where((a) => a.type == type).toList();
  }

  /// Gets annotations by tag
  static Future<List<Annotation>> getAnnotationsByTag(
    String bookId,
    String tag,
  ) async {
    final annotations = await getAnnotations(bookId);
    return annotations.where((a) => a.tags.contains(tag)).toList();
  }

  /// Gets annotations by color
  static Future<List<Annotation>> getAnnotationsByColor(
    String bookId,
    String color,
  ) async {
    final annotations = await getAnnotations(bookId);
    return annotations.where((a) => a.color == color).toList();
  }

  /// Searches annotations by text content or note
  static Future<List<Annotation>> searchAnnotations(
    String bookId,
    String query,
  ) async {
    final annotations = await getAnnotations(bookId);
    final lowercaseQuery = query.toLowerCase();

    return annotations.where((a) {
      return a.selectedText.toLowerCase().contains(lowercaseQuery) ||
          (a.note?.toLowerCase().contains(lowercaseQuery) ?? false) ||
          a.tags.any((tag) => tag.toLowerCase().contains(lowercaseQuery));
    }).toList();
  }

  /// Gets all unique tags across all annotations for a book
  static Future<List<String>> getAllTags(String bookId) async {
    final annotations = await getAnnotations(bookId);
    final tags = <String>{};

    for (final annotation in annotations) {
      tags.addAll(annotation.tags);
    }

    return tags.toList()..sort();
  }

  /// Gets all unique colors used in annotations for a book
  static Future<List<String>> getAllColors(String bookId) async {
    final annotations = await getAnnotations(bookId);
    final colors = <String>{};

    for (final annotation in annotations) {
      colors.add(annotation.color);
    }

    return colors.toList()..sort();
  }

  /// Gets annotation statistics for a book
  static Future<Map<String, dynamic>> getAnnotationStats(String bookId) async {
    final annotations = await getAnnotations(bookId);

    if (annotations.isEmpty) {
      return {
        'total': 0,
        'byType': <String, int>{},
        'byChapter': <int, int>{},
        'byTag': <String, int>{},
        'byColor': <String, int>{},
        'recent': <Annotation>[],
      };
    }

    // Count by type
    final byType = <String, int>{};
    for (final annotation in annotations) {
      byType[annotation.type.name] = (byType[annotation.type.name] ?? 0) + 1;
    }

    // Count by chapter
    final byChapter = <int, int>{};
    for (final annotation in annotations) {
      byChapter[annotation.chapterIndex] =
          (byChapter[annotation.chapterIndex] ?? 0) + 1;
    }

    // Count by tag
    final byTag = <String, int>{};
    for (final annotation in annotations) {
      for (final tag in annotation.tags) {
        byTag[tag] = (byTag[tag] ?? 0) + 1;
      }
    }

    // Count by color
    final byColor = <String, int>{};
    for (final annotation in annotations) {
      byColor[annotation.color] = (byColor[annotation.color] ?? 0) + 1;
    }

    // Get recent annotations (last 10)
    final recent = annotations.toList()
      ..sort((a, b) => b.lastModified.compareTo(a.lastModified));
    final recentAnnotations = recent.take(10).toList();

    return {
      'total': annotations.length,
      'byType': byType,
      'byChapter': byChapter,
      'byTag': byTag,
      'byColor': byColor,
      'recent': recentAnnotations,
    };
  }

  /// Gets overlapping annotations at a specific position
  static Future<List<Annotation>> getOverlappingAnnotations(
    String bookId,
    int chapterIndex,
    double position,
  ) async {
    final annotations = await getAnnotationsByChapter(bookId, chapterIndex);

    return annotations.where((a) {
      return position >= a.startPosition && position <= a.endPosition;
    }).toList();
  }

  /// Gets annotations within a range
  static Future<List<Annotation>> getAnnotationsInRange(
    String bookId,
    int chapterIndex,
    double startPosition,
    double endPosition,
  ) async {
    final annotations = await getAnnotationsByChapter(bookId, chapterIndex);

    return annotations.where((a) {
      // Check if annotations overlap with the range
      return (a.startPosition <= endPosition && a.endPosition >= startPosition);
    }).toList();
  }

  /// Exports annotations for a book to JSON
  static Future<String> exportAnnotations(String bookId) async {
    final annotations = await getAnnotations(bookId);
    return json.encode(annotations.map((a) => a.toJson()).toList());
  }

  /// Imports annotations for a book from JSON
  static Future<void> importAnnotations(String bookId, String jsonData) async {
    try {
      final List<dynamic> annotationsList = json.decode(jsonData);
      final annotations = annotationsList
          .map((json) => Annotation.fromJson(json as Map<String, dynamic>))
          .toList();

      // Update book IDs to match current book
      for (final annotation in annotations) {
        final updatedAnnotation = annotation.copyWith(bookId: bookId);
        await saveAnnotation(updatedAnnotation);
      }
    } catch (e) {
      throw Exception('Failed to import annotations: $e');
    }
  }

  /// Clears all annotations for a book
  static Future<void> clearAnnotations(String bookId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('${_annotationsKey}_$bookId');
  }

  /// Clears annotations by type for a book
  static Future<void> clearAnnotationsByType(
    String bookId,
    AnnotationType type,
  ) async {
    final annotations = await getAnnotations(bookId);
    final filteredAnnotations = annotations
        .where((a) => a.type != type)
        .toList();
    await _saveAnnotationsForBook(bookId, filteredAnnotations);
  }

  /// Updates annotation tags
  static Future<void> updateAnnotationTags(
    String annotationId,
    String bookId,
    List<String> newTags,
  ) async {
    final annotation = await getAnnotation(annotationId, bookId);
    if (annotation != null) {
      final updatedAnnotation = annotation.copyWith(
        tags: newTags,
        lastModified: DateTime.now(),
      );
      await saveAnnotation(updatedAnnotation);
    }
  }

  /// Updates annotation note
  static Future<void> updateAnnotationNote(
    String annotationId,
    String bookId,
    String? newNote,
  ) async {
    final annotation = await getAnnotation(annotationId, bookId);
    if (annotation != null) {
      final updatedAnnotation = annotation.copyWith(
        note: newNote,
        lastModified: DateTime.now(),
      );
      await saveAnnotation(updatedAnnotation);
    }
  }

  /// Saves annotations for a specific book
  static Future<void> _saveAnnotationsForBook(
    String bookId,
    List<Annotation> annotations,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final annotationsJson = json.encode(
      annotations.map((a) => a.toJson()).toList(),
    );
    await prefs.setString('${_annotationsKey}_$bookId', annotationsJson);
  }
}
