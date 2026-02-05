import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/bookmark.dart';

/// Service for managing bookmarks in EPUB books
class BookmarkService {
  static const String _storageKey = 'epub_bookmarks';

  /// Saves a bookmark to local storage
  static Future<void> saveBookmark(Bookmark bookmark) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final bookmarks = await getBookmarks(bookmark.bookId);

      // Add new bookmark
      bookmarks.add(bookmark);

      // Save to storage
      final bookmarksJson = bookmarks.map((b) => b.toJson()).toList();
      await prefs.setString(_storageKey, jsonEncode(bookmarksJson));

      debugPrint('Bookmark saved: Chapter ${bookmark.chapterIndex + 1}');
    } catch (e) {
      debugPrint('Error saving bookmark: $e');
    }
  }

  /// Retrieves all bookmarks for a specific book
  static Future<List<Bookmark>> getBookmarks(String bookId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final bookmarksJson = prefs.getString(_storageKey);

      if (bookmarksJson == null) return [];

      final List<dynamic> bookmarksList = jsonDecode(bookmarksJson);
      final bookmarks = bookmarksList
          .map((json) => Bookmark.fromJson(json))
          .where((bookmark) => bookmark.bookId == bookId)
          .toList();

      return bookmarks;
    } catch (e) {
      debugPrint('Error retrieving bookmarks: $e');
      return [];
    }
  }

  /// Deletes a specific bookmark
  static Future<void> deleteBookmark(String bookmarkId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final bookmarksJson = prefs.getString(_storageKey);

      if (bookmarksJson == null) return;

      final List<dynamic> bookmarksList = jsonDecode(bookmarksJson);
      final bookmarks = bookmarksList
          .map((json) => Bookmark.fromJson(json))
          .where((bookmark) => bookmark.id != bookmarkId)
          .toList();

      // Save updated list
      final updatedBookmarksJson = bookmarks.map((b) => b.toJson()).toList();
      await prefs.setString(_storageKey, jsonEncode(updatedBookmarksJson));

      debugPrint('Bookmark deleted: $bookmarkId');
    } catch (e) {
      debugPrint('Error deleting bookmark: $e');
    }
  }

  /// Updates an existing bookmark
  static Future<void> updateBookmark(Bookmark updatedBookmark) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final bookmarks = await getBookmarks(updatedBookmark.bookId);

      // Find and update the bookmark
      final index = bookmarks.indexWhere((b) => b.id == updatedBookmark.id);
      if (index != -1) {
        bookmarks[index] = updatedBookmark;

        // Save updated list
        final bookmarksJson = bookmarks.map((b) => b.toJson()).toList();
        await prefs.setString(_storageKey, jsonEncode(bookmarksJson));

        debugPrint('Bookmark updated: ${updatedBookmark.id}');
      }
    } catch (e) {
      debugPrint('Error updating bookmark: $e');
    }
  }

  /// Clears all bookmarks for a specific book
  static Future<void> clearBookBookmarks(String bookId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final bookmarksJson = prefs.getString(_storageKey);

      if (bookmarksJson == null) return;

      final List<dynamic> bookmarksList = jsonDecode(bookmarksJson);
      final bookmarks = bookmarksList
          .map((json) => Bookmark.fromJson(json))
          .where((bookmark) => bookmark.bookId != bookId)
          .toList();

      // Save updated list
      final updatedBookmarksJson = bookmarks.map((b) => b.toJson()).toList();
      await prefs.setString(_storageKey, jsonEncode(updatedBookmarksJson));

      debugPrint('All bookmarks cleared for book: $bookId');
    } catch (e) {
      debugPrint('Error clearing book bookmarks: $e');
    }
  }
}
