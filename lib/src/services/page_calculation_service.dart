import 'package:flutter/material.dart';
import '../models/epub_chapter.dart';
import '../utils/theme_manager.dart';

/// Service for calculating page counts and positions in EPUB content
class PageCalculationService {
  // Cache for page calculations to avoid recalculation
  static final Map<String, int> _chapterPageCache = {};
  static final Map<String, int> _bookPageCache = {};

  /// Cache key generator for chapter pages
  static String _getChapterCacheKey(EpubChapter chapter, BuildContext context) {
    final fontSize = ThemeManager.getCurrentFontSize();
    final lineHeight = ThemeManager.getCurrentLineHeight();
    final margin = ThemeManager.getCurrentMargin();
    final screenSize = MediaQuery.of(context).size;

    return '${chapter.id}_${fontSize}_${lineHeight}_${margin}_${screenSize.width}_${screenSize.height}';
  }

  /// Cache key generator for book pages
  static String _getBookCacheKey(
    List<EpubChapter> chapters,
    BuildContext context,
  ) {
    final fontSize = ThemeManager.getCurrentFontSize();
    final lineHeight = ThemeManager.getCurrentLineHeight();
    final margin = ThemeManager.getCurrentMargin();
    final screenSize = MediaQuery.of(context).size;

    return '${chapters.length}_${fontSize}_${lineHeight}_${margin}_${screenSize.width}_${screenSize.height}';
  }

  /// Calculates total pages for a chapter based on content and settings
  static int calculateChapterPages(EpubChapter chapter, BuildContext context) {
    final cacheKey = _getChapterCacheKey(chapter, context);

    // Check cache first
    if (_chapterPageCache.containsKey(cacheKey)) {
      return _chapterPageCache[cacheKey]!;
    }

    final content = chapter.content;

    // Get current reading settings
    final fontSize = ThemeManager.getCurrentFontSize();
    final lineHeight = ThemeManager.getCurrentLineHeight();
    final margin = ThemeManager.getCurrentMargin();

    // Get screen dimensions
    final screenSize = MediaQuery.of(context).size;
    final availableWidth = screenSize.width - (margin * 2);
    final availableHeight =
        screenSize.height - (margin * 2) - 200; // Account for header/footer

    // Calculate characters per line (approximate)
    final charsPerLine = (availableWidth / (fontSize * 0.6))
        .floor(); // 0.6 is average char width

    // Calculate lines per page
    final linesPerPage = (availableHeight / (fontSize * lineHeight)).floor();

    // Calculate total characters
    final totalChars = content.length;

    // Calculate total lines
    final totalLines = (totalChars / charsPerLine).ceil();

    // Calculate total pages
    final totalPages = (totalLines / linesPerPage).ceil();

    // Ensure minimum of 1 page
    final result = totalPages > 0 ? totalPages : 1;

    // Cache the result
    _chapterPageCache[cacheKey] = result;

    return result;
  }

  /// Calculates total pages for an entire book
  static int calculateBookTotalPages(
    List<EpubChapter> chapters,
    BuildContext context,
  ) {
    final cacheKey = _getBookCacheKey(chapters, context);

    // Check cache first
    if (_bookPageCache.containsKey(cacheKey)) {
      return _bookPageCache[cacheKey]!;
    }

    int totalPages = 0;
    for (final chapter in chapters) {
      totalPages += calculateChapterPages(chapter, context);
    }

    // Cache the result
    _bookPageCache[cacheKey] = totalPages;

    return totalPages;
  }

  /// Calculates current page within a chapter based on scroll position
  static int calculateCurrentPage(
    double scrollPosition,
    double maxScrollExtent,
    int totalChapterPages,
  ) {
    if (maxScrollExtent <= 0) return 1;

    final progress = scrollPosition / maxScrollExtent;
    final currentPage = (progress * totalChapterPages).ceil();

    // Ensure page is within bounds
    if (currentPage < 1) return 1;
    if (currentPage > totalChapterPages) return totalChapterPages;

    return currentPage;
  }

  /// Fast approximation of current page for smooth scrolling
  /// Uses linear interpolation instead of ceiling for better performance
  static int calculateCurrentPageFast(
    double scrollPosition,
    double maxScrollExtent,
    int totalChapterPages,
  ) {
    if (maxScrollExtent <= 0) return 1;

    final progress = scrollPosition / maxScrollExtent;
    // Use ceil to avoid off-by-one when landing near page boundaries
    int currentPage = (progress * totalChapterPages).ceil();

    // Ensure page is within bounds
    if (currentPage < 1) return 1;
    if (currentPage > totalChapterPages) return totalChapterPages;

    return currentPage;
  }

  /// Calculates current page across the entire book
  static int calculateBookCurrentPage(
    int currentChapterIndex,
    int currentChapterPage,
    List<EpubChapter> chapters,
    BuildContext context,
  ) {
    int bookPage = 0;

    // Add pages from previous chapters
    for (int i = 0; i < currentChapterIndex; i++) {
      bookPage += calculateChapterPages(chapters[i], context);
    }

    // Add current chapter page
    bookPage += currentChapterPage;

    return bookPage;
  }

  /// Finds which chapter and position a specific book page corresponds to
  /// Returns a map with 'chapterIndex' and 'position' (0.0 to 1.0)
  static Map<String, dynamic>? findChapterAndPositionForBookPage(
    int targetBookPage,
    List<EpubChapter> chapters,
    BuildContext context,
  ) {
    if (targetBookPage < 1) return null;

    int accumulatedPages = 0;

    for (int i = 0; i < chapters.length; i++) {
      final chapterPages = calculateChapterPages(chapters[i], context);

      // Check if target page is within this chapter
      if (targetBookPage <= accumulatedPages + chapterPages) {
        final chapterPage = targetBookPage - accumulatedPages;

        // Convert chapter page to position (0.0 to 1.0)
        final position = (chapterPage - 1) / chapterPages;

        return {
          'chapterIndex': i,
          'position': position.clamp(0.0, 1.0),
          'chapterPage': chapterPage,
          'totalChapterPages': chapterPages,
        };
      }

      accumulatedPages += chapterPages;
    }

    // If target page is beyond the book, return the last chapter at the end
    if (chapters.isNotEmpty) {
      return {
        'chapterIndex': chapters.length - 1,
        'position': 1.0,
        'chapterPage': calculateChapterPages(chapters.last, context),
        'totalChapterPages': calculateChapterPages(chapters.last, context),
      };
    }

    return null;
  }

  /// Estimates reading time for a specific page
  static Duration estimatePageReadingTime(
    int pageNumber,
    int totalPages,
    Duration totalChapterTime,
  ) {
    final pagesPerSecond = totalPages / totalChapterTime.inSeconds;
    final secondsForPage = 1 / pagesPerSecond;
    return Duration(seconds: secondsForPage.ceil());
  }

  /// Gets page information for display
  static Map<String, dynamic> getPageInfo(
    EpubChapter chapter,
    int currentPage,
    BuildContext context,
  ) {
    final totalPages = calculateChapterPages(chapter, context);

    return {
      'currentPage': currentPage,
      'totalPages': totalPages,
      'pageProgress': currentPage / totalPages,
      'pageProgressPercentage':
          '${((currentPage / totalPages) * 100).toStringAsFixed(1)}%',
    };
  }

  /// Formats page information for display
  static String formatPageDisplay(int currentPage, int totalPages) {
    return '$currentPage / $totalPages';
  }

  /// Formats page progress for display
  static String formatPageProgress(int currentPage, int totalPages) {
    final percentage = ((currentPage / totalPages) * 100).toStringAsFixed(1);
    return '$percentage%';
  }

  /// Clears the page calculation cache
  /// Call this when font size, line height, or margins change
  static void clearCache() {
    _chapterPageCache.clear();
    _bookPageCache.clear();
  }
}
