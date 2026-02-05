import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/highlight.dart';

/// Service for managing text highlights in EPUB books
class HighlightService {
  static const String _storageKey = 'epub_highlights';

  /// Saves a highlight to local storage
  static Future<void> saveHighlight(Highlight highlight) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final highlights = await getHighlights(highlight.bookId);

      // Add new highlight
      highlights.add(highlight);

      // Save to storage
      final highlightsJson = highlights.map((h) => h.toJson()).toList();
      await prefs.setString(_storageKey, jsonEncode(highlightsJson));

      debugPrint(
        'Highlight saved: ${highlight.text.substring(0, highlight.text.length > 20 ? 20 : highlight.text.length)}...',
      );
    } catch (e) {
      debugPrint('Error saving highlight: $e');
    }
  }

  /// Retrieves all highlights for a specific book
  static Future<List<Highlight>> getHighlights(String bookId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final highlightsJson = prefs.getString(_storageKey);

      if (highlightsJson == null) return [];

      final List<dynamic> highlightsList = jsonDecode(highlightsJson);
      final highlights = highlightsList
          .map((json) => Highlight.fromJson(json))
          .where((highlight) => highlight.bookId == bookId)
          .toList();

      return highlights;
    } catch (e) {
      debugPrint('Error retrieving highlights: $e');
      return [];
    }
  }

  /// Deletes a specific highlight
  static Future<void> deleteHighlight(String highlightId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final highlightsJson = prefs.getString(_storageKey);

      if (highlightsJson == null) return;

      final List<dynamic> highlightsList = jsonDecode(highlightsJson);
      final highlights = highlightsList
          .map((json) => Highlight.fromJson(json))
          .where((highlight) => highlight.id != highlightId)
          .toList();

      // Save updated list
      final updatedHighlightsJson = highlights.map((h) => h.toJson()).toList();
      await prefs.setString(_storageKey, jsonEncode(updatedHighlightsJson));

      debugPrint('Highlight deleted: $highlightId');
    } catch (e) {
      debugPrint('Error deleting highlight: $e');
    }
  }

  /// Updates an existing highlight
  static Future<void> updateHighlight(Highlight updatedHighlight) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final highlights = await getHighlights(updatedHighlight.bookId);

      // Find and update the highlight
      final index = highlights.indexWhere((h) => h.id == updatedHighlight.id);
      if (index != -1) {
        highlights[index] = updatedHighlight;

        // Save updated list
        final highlightsJson = highlights.map((h) => h.toJson()).toList();
        await prefs.setString(_storageKey, jsonEncode(highlightsJson));

        debugPrint('Highlight updated: ${updatedHighlight.id}');
      }
    } catch (e) {
      debugPrint('Error updating highlight: $e');
    }
  }

  /// Clears all highlights for a specific book
  static Future<void> clearBookHighlights(String bookId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final highlightsJson = prefs.getString(_storageKey);

      if (highlightsJson == null) return;

      final List<dynamic> highlightsList = jsonDecode(highlightsJson);
      final highlights = highlightsList
          .map((json) => Highlight.fromJson(json))
          .where((highlight) => highlight.bookId != bookId)
          .toList();

      // Save updated list
      final updatedHighlightsJson = highlights.map((h) => h.toJson()).toList();
      await prefs.setString(_storageKey, jsonEncode(updatedHighlightsJson));

      debugPrint('All highlights cleared for book: $bookId');
    } catch (e) {
      debugPrint('Error clearing book highlights: $e');
    }
  }
}
