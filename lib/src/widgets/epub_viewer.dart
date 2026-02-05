import 'package:flutter/material.dart';
import 'chapters_sheet.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import '../models/epub_book.dart';
import '../models/app_bar_style.dart';

import '../models/reading_progress.dart';
import '../services/progress_service.dart';
import '../services/highlight_service.dart';
import 'selection_toolbar.dart';
// Removed unused bookmark/note services in this file
import '../services/page_calculation_service.dart';
import '../models/highlight.dart';
// Removed unused bookmark/note models in this file
import '../utils/reading_theme.dart';
import '../utils/theme_manager.dart';
import 'reading_controls.dart';
import 'table_of_contents.dart';
// Removed: floating menus, replaced with SelectionControls
import 'epub_content_builder.dart';
// Removed: note dialog; notes handled externally
// Page jump dialog not used directly; use PageJumpSheet via ReadingControls
import '../services/search_controller.dart';
import 'highlight_sheet.dart';
import 'bookmark_sheet.dart';
import 'note_sheet.dart';

/// Simplified selection state management
class SelectionState {
  bool _isActive = false;
  String _selectedText = '';

  bool get isActive => _isActive;
  String get selectedText => _selectedText;

  void updateSelection(String text) {
    _selectedText = text;
    _isActive = text.isNotEmpty;
  }

  void clearSelection() {
    _selectedText = '';
    _isActive = false;
  }
}

/// Main widget for viewing EPUB books
class EpubViewer extends StatefulWidget {
  /// The EPUB book to display
  final EpubBook book;

  /// Initial chapter index to start reading from
  final int initialChapterIndex;

  /// Initial position within the chapter (0.0 to 1.0)
  final double initialPosition;

  /// Initial book page to start reading from (1-based, across entire book)
  /// If provided, this takes precedence over initialChapterIndex and initialPosition
  final int? initialBookPage;

  /// Callback when reading progress changes
  final Function(ReadingProgress)? onProgressChanged;

  /// Callback when chapter changes
  final Function(int)? onChapterChanged;

  /// Whether to show reading controls
  final bool showControls;

  /// Whether to show table of contents
  final bool showTableOfContents;

  /// Custom theme for reading
  final ReadingTheme? customTheme;

  /// Callback when user selects text within the reader. Empty string when cleared.
  final ValueChanged<String>? onTextSelected;

  /// Note: Built-in sheets are now used for bookmark, note, highlight, and search functionality.
  /// The following callback parameters are deprecated but kept for backward compatibility.
  @Deprecated('Use built-in sheets instead')
  final ValueChanged<String>? onBookmarkRequested;

  @Deprecated('Use built-in sheets instead')
  final ValueChanged<String>? onNoteRequested;

  @Deprecated('Use built-in sheets instead')
  final void Function(
    String selectedText,
    void Function(Color color) applyHighlight,
  )?
  onHighlightRequested;

  @Deprecated('Use built-in sheets instead')
  final void Function(EpubSearchController controller)? onSearchRequested;

  /// Custom styling for the app bar
  final AppBarStyle? appBarStyle;

  /// Duration to wait before hiding selection toolbar after selection clears (default: 150ms)
  final Duration selectionToolbarHideDelay;

  /// Callback when a bookmark is saved from the built-in bookmark sheet
  final void Function({
    required int chapterIndex,
    required double position,
    required String selectedText,
    String? title,
  })?
  onBookmarkSaved;

  /// Callback when bookmarks list button is tapped
  final VoidCallback? onShowBookmarks;

  /// List of bookmarks to show visual indicators for
  final List<Map<String, dynamic>>? bookmarks;

  /// Callback when a note is saved from the built-in note sheet
  final void Function({
    required int chapterIndex,
    required double position,
    required String selectedText,
    required String noteContent,
    String? color,
  })?
  onNoteSaved;

  /// Callback when notes list button is tapped
  final VoidCallback? onShowNotes;

  /// List of notes to show visual indicators for
  final List<Map<String, dynamic>>? notes;

  const EpubViewer({
    super.key,
    required this.book,
    this.initialChapterIndex = 0,
    this.initialPosition = 0.0,
    this.initialBookPage,
    this.onProgressChanged,
    this.onChapterChanged,
    this.showControls = true,
    this.showTableOfContents = true,
    this.customTheme,
    this.onTextSelected,
    this.onBookmarkRequested,
    this.onNoteRequested,
    this.onHighlightRequested,
    this.onSearchRequested,
    this.appBarStyle,
    this.selectionToolbarHideDelay = const Duration(milliseconds: 10),
    this.onBookmarkSaved,
    this.onShowBookmarks,
    this.bookmarks,
    this.onNoteSaved,
    this.onShowNotes,
    this.notes,
  });

  @override
  State<EpubViewer> createState() => _EpubViewerState();
}

class _EpubViewerState extends State<EpubViewer> with TickerProviderStateMixin {
  late int _currentChapterIndex;
  late double _currentPosition;
  late ReadingProgress _readingProgress;
  late ReadingTheme _currentTheme;

  bool _isLoading = true;
  bool _showControls = false;
  final bool _showTableOfContents = false;
  // Fullscreen mode removed; controls are shown/hidden dynamically by tap
  String _currentContent = '';
  String _renderedContent = '';

  // Page tracking
  int _currentBookPage = 1;
  int _totalBookPages = 1;
  final ScrollController _scrollController = ScrollController();

  // ValueNotifier for reactive page updates without full rebuilds
  late final ValueNotifier<int> _pageNotifier;

  // Reading statistics
  DateTime? _readingStartTime;
  final int _wordsRead = 0;

  // Selection-related fields
  GlobalKey _selectionAreaKey = GlobalKey();
  // Removed: selection tap-down tracking for floating toolbar
  int _selectionResetCounter =
      0; // Bump to force SelectionArea rebuild to clear selection
  final ValueNotifier<BuildContext?> _selectionDescendantContext =
      ValueNotifier<BuildContext?>(null);
  String _selectionFrozenText = '';

  // Root stack key (still used for overlays)
  final GlobalKey _rootStackKey = GlobalKey();
  // Floating selection toolbar placement helpers
  final GlobalKey _toolbarKey = GlobalKey();
  Size? _toolbarSize;
  Offset? _lastPointerGlobalPosition;
  // Apply a top inset at chapter start so the header doesn't cover first lines
  bool _applyTopInsetAtChapterStart = true;

  // Animation controllers for controls and header
  late AnimationController _controlsAnimationController;
  late AnimationController _headerAnimationController;
  List<Map<String, dynamic>>? _chapterHighlights;

  // Search
  late final EpubSearchController _searchController;
  List<String>? _chapterPlainTexts;
  late SelectionState
  _selectionState; // Added from previous fix // lazily built plain-text per chapter
  Timer? _selectionDebounceTimer; // Debounce selection updates
  Timer? _selectionClearTimer; // Gracefully clear selection after drag settles

  @override
  void initState() {
    super.initState();
    _selectionState = SelectionState(); // Initialize simplified selection state

    // Always initialize with default values first to avoid late initialization errors
    _currentChapterIndex = widget.initialChapterIndex;
    _currentPosition = widget.initialPosition;

    // Handle initial positioning based on initialBookPage or fallback to chapter/position
    if (widget.initialBookPage != null) {
      // Calculate chapter and position from book page
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _initializeFromBookPage(widget.initialBookPage!);
      });
    } else {
      // Use traditional chapter/position initialization
      // Load chapter after initialization
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadChapter(_currentChapterIndex);
      });
    }

    _currentTheme = widget.customTheme ?? ThemeManager.getCurrentTheme();

    // Initialize reading progress synchronously
    _readingProgress = ReadingProgress.initial(widget.book.id);
    _readingStartTime = DateTime.now();

    // Initialize page notifier
    _pageNotifier = ValueNotifier<int>(1);

    // Add listeners for theme changes
    ThemeManager.addThemeListener(_onThemeChanged);
    ThemeManager.addFontSizeListener(_onFontSizeChanged);
    ThemeManager.addFontFamilyListener(_onFontFamilyChanged);
    ThemeManager.addLineHeightListener(_onLineHeightChanged);
    ThemeManager.addMarginListener(_onMarginChanged);
    ThemeManager.addReadingStyleListener(_onReadingStyleChanged);

    // Add scroll listener for page tracking
    _scrollController.addListener(_onScroll);

    // Show controls on start as requested
    _showControls = true;

    // Initialize animation controllers
    _controlsAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _headerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    // Define animations

    // Start selection state watcher for debugging
    // Remove continuous watcher; we manage selection via callbacks and taps
    _controlsAnimationController.forward();
    _headerAnimationController.forward();

    // Initialize search controller
    _searchController = EpubSearchController();
    _searchController.onExecuteQuery = _executeSearch;
    _searchController.onNavigateToMatch = _navigateToMatch;
    // Clear visual highlights when query is cleared
    _searchController.query.addListener(() {
      final q = _searchController.query.value.trim();
      if (q.isEmpty) {
        if (!_selectionState.isActive) {
          // Updated to use simplified state
          setState(() {
            _renderedContent = _currentContent;
          });
        }
      }
    });
  }

  /// Loads and applies all saved highlights for the current book
  Future<void> _loadAndApplySavedHighlights() async {
    try {
      final highlights = await HighlightService.getHighlights(widget.book.id);
      debugPrint('[Highlight] Loading ${highlights.length} saved highlights');
      // Batch apply without rebuilding on each, then rebuild once
      for (final highlight in highlights) {
        if (highlight.chapterIndex == _currentChapterIndex) {
          _applyHighlightToRenderedContent(
            highlight.text,
            highlight.color,
            shouldRebuild: false,
          );
        }
      }
      if (mounted) setState(() {});
    } catch (e) {
      debugPrint('[Highlight] Error loading saved highlights: $e');
    }
  }

  /// Saves a highlight to storage
  Future<void> _saveHighlight(String text, Color color) async {
    try {
      final highlight = Highlight.create(
        bookId: widget.book.id,
        chapterIndex: _currentChapterIndex,
        text: text,
        color: color,
      );

      await HighlightService.saveHighlight(highlight);
      debugPrint('[Highlight] Highlight saved successfully');
    } catch (e) {
      debugPrint('[Highlight] Error saving highlight: $e');
    }
  }

  /// Applies a visual highlight by wrapping the first occurrence of the selected text
  /// in an inline-styled span using the provided color.
  /// If [shouldRebuild] is true (default), setState will be called immediately.
  void _applyHighlightToRenderedContent(
    String selectedText,
    Color color, {
    bool shouldRebuild = true,
  }) {
    debugPrint('[Highlight] _applyHighlightToRenderedContent called');
    debugPrint('[Highlight] selectedText: "$selectedText"');
    debugPrint('[Highlight] color: $color');

    try {
      if (selectedText.trim().isEmpty) {
        debugPrint('[Highlight] Selected text is empty, returning');
        return;
      }

      // Clean and normalize the selected text for better matching
      String normalize(String s) {
        return s
            .replaceAll('\u00A0', ' ') // nbsp
            .replaceAll('&nbsp;', ' ')
            .replaceAll(RegExp('[\u2018\u2019]'), "'") // curly single quotes
            .replaceAll(RegExp('[\u201C\u201D]'), '"') // curly double quotes
            .replaceAll(RegExp('[\u2013\u2014]'), '-') // en/em dash
            .replaceAll(RegExp('\\s+'), ' ')
            .trim();
      }

      final cleanSelectedText = normalize(selectedText);

      // Build style color in rgba
      final rgba =
          'rgba(${color.red}, ${color.green}, ${color.blue}, ${color.opacity})';

      // Try multiple matching strategies
      bool highlightApplied = false;

      // Utility to pick the match closest to the current reading position
      RegExpMatch? pickBestMatch(Iterable<RegExpMatch> matches, String hay) {
        if (matches.isEmpty) return null;
        final int target = (hay.length * _currentPosition)
            .clamp(0, hay.length - 1)
            .toInt();
        RegExpMatch? best;
        int bestDist = 1 << 30;
        for (final m in matches) {
          final d = (m.start - target).abs();
          if (d < bestDist) {
            best = m;
            bestDist = d;
          }
        }
        return best;
      }

      // Strategy 1: Direct text matching (for plain text)
      if (!highlightApplied) {
        final directPattern = RegExp(
          RegExp.escape(cleanSelectedText),
          caseSensitive: false,
        );
        final directMatch = pickBestMatch(
          directPattern.allMatches(_renderedContent),
          _renderedContent,
        );

        if (directMatch != null) {
          debugPrint(
            '[Highlight] Direct match found at ${directMatch.start}-${directMatch.end}',
          );
          final beforeMatch = _renderedContent.substring(0, directMatch.start);
          final afterMatch = _renderedContent.substring(directMatch.end);
          final matchedText = _renderedContent.substring(
            directMatch.start,
            directMatch.end,
          );
          final highlightedText =
              '<span style="background-color: $rgba; padding: 1px 2px; border-radius: 2px; box-shadow: 0 1px 2px rgba(0,0,0,0.1);">$matchedText</span>';

          _renderedContent = beforeMatch + highlightedText + afterMatch;
          highlightApplied = true;
          debugPrint('[Highlight] Direct highlight applied successfully');
        }
      }

      // Strategy 2: Word-by-word matching (for text with HTML tags)
      if (!highlightApplied) {
        final words = cleanSelectedText
            .split(RegExp(r'\s+'))
            .where((w) => w.isNotEmpty)
            .toList();
        if (words.isNotEmpty) {
          // Create a pattern that matches words with any HTML content between them
          final wordPatterns = words.map((word) {
            final w = RegExp.escape(
              word,
            ).replaceAll('-', '[\u2013\u2014-]'); // accept various dashes
            return w;
          }).toList();
          final flexiblePattern = RegExp(
            wordPatterns.join(r'[\s\S]*?'),
            caseSensitive: false,
          );

          final flexibleMatch = pickBestMatch(
            flexiblePattern.allMatches(_renderedContent),
            _renderedContent,
          );
          if (flexibleMatch != null) {
            debugPrint(
              '[Highlight] Flexible match found at ${flexibleMatch.start}-${flexibleMatch.end}',
            );
            final beforeMatch = _renderedContent.substring(
              0,
              flexibleMatch.start,
            );
            final afterMatch = _renderedContent.substring(flexibleMatch.end);
            final matchedText = _renderedContent.substring(
              flexibleMatch.start,
              flexibleMatch.end,
            );
            final highlightedText =
                '<span style="background-color: $rgba; padding: 1px 2px; border-radius: 2px; box-shadow: 0 1px 2px rgba(0,0,0,0.1);">$matchedText</span>';

            _renderedContent = beforeMatch + highlightedText + afterMatch;
            highlightApplied = true;
            debugPrint('[Highlight] Flexible highlight applied successfully');
          }
        }
      }

      // Strategy 3: Strip HTML and match plain text
      if (!highlightApplied) {
        debugPrint('[Highlight] Trying plain text matching...');
        final plainText = normalize(_stripHtmlToPlainText(_renderedContent));
        final plainPattern = RegExp(
          RegExp.escape(cleanSelectedText),
          caseSensitive: false,
        );
        final plainMatch = pickBestMatch(
          plainPattern.allMatches(plainText),
          plainText,
        );

        if (plainMatch != null) {
          debugPrint(
            '[Highlight] Plain text match found at ${plainMatch.start}-${plainMatch.end}',
          );
          // Find the corresponding position in the HTML content
          final plainTextBefore = plainText.substring(0, plainMatch.start);
          final plainTextMatch = plainText.substring(
            plainMatch.start,
            plainMatch.end,
          );

          // Count HTML tags to find the real position
          int htmlPosition = 0;
          int plainPosition = 0;

          while (htmlPosition < _renderedContent.length &&
              plainPosition < plainTextBefore.length) {
            if (_renderedContent[htmlPosition] ==
                plainTextBefore[plainPosition]) {
              plainPosition++;
            } else if (_renderedContent[htmlPosition] == '<') {
              // Skip HTML tag
              while (htmlPosition < _renderedContent.length &&
                  _renderedContent[htmlPosition] != '>') {
                htmlPosition++;
              }
              if (htmlPosition < _renderedContent.length) htmlPosition++;
            } else {
              htmlPosition++;
            }
          }

          // Find the end position
          int htmlEndPosition = htmlPosition;
          int plainEndPosition = plainPosition;
          int matchLength = plainTextMatch.length;

          while (htmlEndPosition < _renderedContent.length &&
              plainEndPosition < plainPosition + matchLength) {
            if (_renderedContent[htmlEndPosition] ==
                plainTextMatch[plainEndPosition - plainPosition]) {
              plainEndPosition++;
            } else if (_renderedContent[htmlEndPosition] == '<') {
              // Skip HTML tag
              while (htmlEndPosition < _renderedContent.length &&
                  _renderedContent[htmlEndPosition] != '>') {
                htmlEndPosition++;
              }
              if (htmlEndPosition < _renderedContent.length) htmlEndPosition++;
            } else {
              htmlEndPosition++;
            }
          }

          if (htmlPosition < _renderedContent.length &&
              htmlEndPosition <= _renderedContent.length) {
            final beforeMatch = _renderedContent.substring(0, htmlPosition);
            final afterMatch = _renderedContent.substring(htmlEndPosition);
            final matchedText = _renderedContent.substring(
              htmlPosition,
              htmlEndPosition,
            );
            final highlightedText =
                '<span style="background-color: $rgba; padding: 1px 2px; border-radius: 2px; box-shadow: 0 1px 2px rgba(0,0,0,0.1);">$matchedText</span>';

            _renderedContent = beforeMatch + highlightedText + afterMatch;
            highlightApplied = true;
            debugPrint('[Highlight] Plain text highlight applied successfully');
          }
        }
      }

      // Strategy 4: Fallback to raw content matching
      if (!highlightApplied) {
        debugPrint('[Highlight] Trying raw content matching...');
        final hay = normalize(_currentContent);
        final rawPattern = RegExp(
          RegExp.escape(cleanSelectedText),
          caseSensitive: false,
        );
        final rawMatch = pickBestMatch(rawPattern.allMatches(hay), hay);

        if (rawMatch != null) {
          debugPrint(
            '[Highlight] Raw content match found at ${rawMatch.start}-${rawMatch.end}',
          );
          // Apply to raw content and update rendered content
          final beforeMatch = _currentContent.substring(0, rawMatch.start);
          final afterMatch = _currentContent.substring(rawMatch.end);
          final matchedText = _currentContent.substring(
            rawMatch.start,
            rawMatch.end,
          );
          final highlightedText =
              '<span style="background-color: $rgba; padding: 1px 2px; border-radius: 2px; box-shadow: 0 1px 2px rgba(0,0,0,0.1);">$matchedText</span>';

          _currentContent = beforeMatch + highlightedText + afterMatch;
          _renderedContent = _currentContent;
          highlightApplied = true;
          debugPrint('[Highlight] Raw content highlight applied successfully');
        }
      }

      if (highlightApplied) {
        debugPrint('[Highlight] Highlight applied successfully');
        // Re-render the content (optionally batched by caller)
        if (shouldRebuild && mounted) setState(() {});
      } else {
        debugPrint('[Highlight] No match found for text: "$cleanSelectedText"');
        debugPrint(
          '[Highlight] Content preview: "${_renderedContent.length > 200 ? '${_renderedContent.substring(0, 200)}...' : _renderedContent}"',
        );
      }
    } catch (e) {
      debugPrint('[Highlight] Error applying highlight: $e');
    }
  }

  /// Initializes the reader from a specific book page
  /// Calculates the corresponding chapter and position, then loads it
  void _initializeFromBookPage(int bookPage) {
    debugPrint(
      '[EpubViewer] _initializeFromBookPage: Initializing from book page $bookPage',
    );

    try {
      // Find which chapter and position this book page corresponds to
      final result = PageCalculationService.findChapterAndPositionForBookPage(
        bookPage,
        widget.book.chapters,
        context,
      );

      if (result != null) {
        final chapterIndex = result['chapterIndex'] as int;
        final position = result['position'] as double;
        final chapterPage = result['chapterPage'] as int;

        debugPrint(
          '[EpubViewer] _initializeFromBookPage: Found chapter $chapterIndex, position $position, chapter page $chapterPage',
        );

        // Set the calculated position
        _currentChapterIndex = chapterIndex;
        _currentPosition = position;

        // Set the page notifier to the target book page
        _pageNotifier.value = bookPage;

        // Load the chapter, then scroll to the specific position
        _loadChapter(chapterIndex).then((_) {
          // After chapter is loaded, wait for scroll controller to be ready
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              // Wait a bit more for the scroll controller to be fully ready
              Future.delayed(const Duration(milliseconds: 100), () {
                if (mounted) {
                  _scrollToPosition(position);
                }
              });
            }
          });
        });

        debugPrint(
          '[EpubViewer] _initializeFromBookPage: Initialization complete',
        );
      } else {
        debugPrint(
          '[EpubViewer] _initializeFromBookPage: Could not find chapter for book page $bookPage, falling back to defaults',
        );
        // Fallback to default initialization
        _currentChapterIndex = widget.initialChapterIndex;
        _currentPosition = widget.initialPosition;
        _loadChapter(_currentChapterIndex);
      }
    } catch (e) {
      debugPrint(
        '[EpubViewer] _initializeFromBookPage: Error during initialization: $e',
      );
      // Fallback to default initialization
      _currentChapterIndex = widget.initialChapterIndex;
      _currentPosition = widget.initialPosition;
      _loadChapter(_currentChapterIndex);
    }
  }

  /// Scrolls to a specific position within the current chapter
  /// position should be between 0.0 and 1.0
  void _scrollToPosition(double position) {
    if (!mounted) {
      debugPrint('[EpubViewer] _scrollToPosition: Cannot scroll - not mounted');
      return;
    }

    if (!_scrollController.hasClients) {
      debugPrint(
        '[EpubViewer] _scrollToPosition: Scroll controller not ready, retrying in 200ms',
      );
      // Retry after a short delay
      Future.delayed(const Duration(milliseconds: 200), () {
        if (mounted) {
          _scrollToPosition(position);
        }
      });
      return;
    }

    try {
      // Calculate the scroll position based on the percentage
      final maxScrollExtent = _scrollController.position.maxScrollExtent;
      final targetScrollPosition = maxScrollExtent * position.clamp(0.0, 1.0);

      debugPrint(
        '[EpubViewer] _scrollToPosition: Scrolling to position $position (${targetScrollPosition.toStringAsFixed(2)}px)',
      );
      debugPrint(
        '[EpubViewer] _scrollToPosition: Max scroll extent: ${maxScrollExtent.toStringAsFixed(2)}px',
      );

      // Animate to the target position
      _scrollController.jumpTo(targetScrollPosition);

      debugPrint('[EpubViewer] _scrollToPosition: Scroll animation started');
    } catch (e) {
      debugPrint(
        '[EpubViewer] _scrollToPosition: Error scrolling to position: $e',
      );
    }
  }

  // Theme change callbacks
  void _onThemeChanged(ReadingTheme newTheme) {
    if (mounted) {
      // Always update the theme, regardless of whether customTheme is provided
      // This allows the parent to control the theme while still responding to changes
      debugPrint(
        'Theme changed from ${_currentTheme.name} to ${newTheme.name}',
      );
      debugPrint(
        'New theme colors - Background: ${newTheme.backgroundColor}, Text: ${newTheme.textColor}',
      );

      setState(() {
        _currentTheme = newTheme;
        // Force content rebuild by incrementing rebuild counter
        _selectionResetCounter++;
      });

      debugPrint(
        'Theme change applied, rebuild counter: $_selectionResetCounter',
      );
    }
  }

  void _onFontSizeChanged(double newSize) {
    if (mounted) {
      // Clear page calculation cache when font size changes
      PageCalculationService.clearCache();

      // Reset scroll position cache
      _lastScrollPosition = 0.0;

      setState(() {
        // Force rebuild to apply new font size
        _selectionResetCounter++;
      });

      // Recalculate page counts and sync current page after layout updates
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _calculatePageCounts();
        _updateCurrentBookPageForChapter();
        _refreshPageDisplay();
        _updateProgress();
      });
    }
  }

  void _onFontFamilyChanged(String newFont) {
    if (mounted) {
      setState(() {
        // Force rebuild to apply new font family - Google Fonts system handles the rest
        _selectionResetCounter++;
      });
    }
  }

  void _onLineHeightChanged(double newHeight) {
    if (mounted) {
      // Clear page calculation cache when line height changes
      PageCalculationService.clearCache();

      setState(() {
        // Force rebuild to apply new line height
        _selectionResetCounter++;
      });

      // Recalculate page counts and sync current page after layout updates
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _calculatePageCounts();
        _updateCurrentBookPageForChapter();
        _refreshPageDisplay();
        _updateProgress();
      });
    }
  }

  void _onMarginChanged(double newMargin) {
    if (mounted) {
      // Clear page calculation cache when margins change
      PageCalculationService.clearCache();

      setState(() {
        // Force rebuild to apply new margins
        _selectionResetCounter++;
      });

      // Recalculate page counts and sync current page after layout updates
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _calculatePageCounts();
        _updateCurrentBookPageForChapter();
        _refreshPageDisplay();
        _updateProgress();
      });
    }
  }

  /// Recomputes the current chapter page and book page based on current scroll.
  void _refreshPageDisplay() {
    if (!_scrollController.hasClients) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final pixels = _scrollController.position.pixels;
    if (maxScroll <= 0) {
      _currentBookPage = PageCalculationService.calculateBookCurrentPage(
        _currentChapterIndex,
        1,
        widget.book.chapters,
        context,
      );
      _pageNotifier.value = _currentBookPage;
      return;
    }

    final chapter = widget.book.chapters[_currentChapterIndex];
    final totalChapterPages = PageCalculationService.calculateChapterPages(
      chapter,
      context,
    );
    final currentChapterPage = PageCalculationService.calculateCurrentPageFast(
      pixels,
      maxScroll,
      totalChapterPages,
    );

    final bookPage = PageCalculationService.calculateBookCurrentPage(
      _currentChapterIndex,
      currentChapterPage,
      widget.book.chapters,
      context,
    );
    _currentBookPage = bookPage;
    _pageNotifier.value = bookPage;
  }

  void _onReadingStyleChanged(String newStyle) {
    if (mounted) {
      setState(() {
        // Force rebuild to apply new reading style
        _selectionResetCounter++;
      });
    }
  }

  /// Handles scroll events to update page tracking
  void _onScroll() {
    if (!mounted || _scrollController.position.maxScrollExtent <= 0) return;

    final now = DateTime.now();
    final scrollPosition = _scrollController.position.pixels;
    final maxScrollExtent = _scrollController.position.maxScrollExtent;

    // Once scrolled away from very top, stop forcing the header inset
    if (_applyTopInsetAtChapterStart &&
        _scrollController.position.pixels > 1.0) {
      setState(() {
        _applyTopInsetAtChapterStart = false;
      });
    }

    // Adaptive throttling based on scroll speed
    if (_lastScrollUpdate != null) {
      final timeDiff = now.difference(_lastScrollUpdate!).inMilliseconds;
      final scrollDiff = (scrollPosition - _lastScrollPosition).abs();

      // If scrolling slowly, update more frequently
      // If scrolling fast, throttle more aggressively
      final minInterval = scrollDiff > 50
          ? 32
          : 16; // 32ms for fast scroll, 16ms for slow

      if (timeDiff < minInterval) {
        return;
      }
    }

    _lastScrollUpdate = now;
    _lastScrollPosition = scrollPosition;

    // Calculate current book page based on scroll position and chapter
    final newBookPage = PageCalculationService.calculateBookCurrentPage(
      _currentChapterIndex,
      _calculateChapterPageFromScroll(scrollPosition, maxScrollExtent),
      widget.book.chapters,
      context,
    );

    // Update page immediately for smooth tracking
    if (newBookPage != _currentBookPage) {
      final oldPage = _currentBookPage;
      // Update both the variable and the notifier
      _currentBookPage = newBookPage;
      _pageNotifier.value = newBookPage;
      debugPrint(
        '[EpubViewer] _onScroll: Book page updated from $oldPage to $newBookPage',
      );
      debugPrint(
        '[EpubViewer] _onScroll: Page notifier value set to: ${_pageNotifier.value}',
      );

      // Light debounce for progress updates
      _debounceProgressUpdate();
    }
  }

  // Adaptive throttling variables
  DateTime? _lastScrollUpdate;
  double _lastScrollPosition = 0.0;

  // Debounce timer for progress updates
  Timer? _progressUpdateTimer;

  void _debounceProgressUpdate() {
    _progressUpdateTimer?.cancel();
    _progressUpdateTimer = Timer(const Duration(milliseconds: 100), () {
      if (mounted) {
        _updateProgress();
      }
    });
  }

  /// Calculates current page within current chapter based on scroll position
  int _calculateChapterPageFromScroll(
    double scrollPosition,
    double maxScrollExtent,
  ) {
    if (maxScrollExtent <= 0) return 1;

    final currentChapter = widget.book.chapters[_currentChapterIndex];
    final totalChapterPages = PageCalculationService.calculateChapterPages(
      currentChapter,
      context,
    );

    // Use fast calculation for smooth scrolling
    final currentPage = PageCalculationService.calculateCurrentPageFast(
      scrollPosition,
      maxScrollExtent,
      totalChapterPages,
    );

    return currentPage;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _currentTheme.backgroundColor,
      body: Stack(
        key: _rootStackKey,
        children: [
          // Main content area
          _buildContentArea(),

          // Header overlay (sits on top of content, within SafeArea)
          if (_showControls)
            Positioned(
              top: MediaQuery.of(context).padding.top,
              left: 0,
              right: 0,
              child: _buildHeader(),
            ),

          // Global tap layer to reliably detect taps; selection-aware
          // Only cover the content area, not the app bar
          Positioned(
            left: 0,
            right: 0,
            top: _showControls
                ? 120
                : MediaQuery.of(context).padding.top +
                      16, // Dynamic based on header visibility
            bottom: 0,
            child: IgnorePointer(
              ignoring: false, // allow taps to clear selection
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTapDown: (details) {
                  _lastPointerGlobalPosition = details.globalPosition;
                },
                onTap: () {
                  // If there's an active selection, clear it first
                  if (_selectionState.isActive) {
                    setState(() {
                      _selectionState.clearSelection();
                      _selectionAreaKey = GlobalKey();
                      _selectionFrozenText = '';
                    });
                    return;
                  }
                  // Otherwise, toggle controls
                  _toggleControls();
                },
                onDoubleTap: () {
                  // Double tap to clear selection
                  if (_selectionState.isActive || _hasActiveSelection()) {
                    debugPrint(
                      '[Selection] Double tap detected, clearing selection',
                    );
                    setState(() {
                      _selectionState.clearSelection();
                      _selectionAreaKey = GlobalKey();
                    });
                  }
                },
                child: const SizedBox.shrink(),
              ),
            ),
          ),

          // Show reading controls; when selection is active also show floating selection toolbar
          _buildControlsOverlay(),
          if (_selectionState.isActive) _buildSelectionToolbarOverlay(),

          // Table of contents overlay
          if (widget.showTableOfContents && _showTableOfContents)
            _buildTableOfContentsOverlay(),

          // Loading indicator
          if (_isLoading) _buildLoadingIndicator(),
        ],
      ),
    );
  }

  /// Builds the main content area
  Widget _buildContentArea() {
    // When controls are visible and the user is at the very start of the chapter,
    // add a top inset so the header doesn't cover the first lines of text.
    final bool isAtTop = !_scrollController.hasClients
        ? true
        : (_scrollController.position.pixels <= 1.0);
    final double topInsetWhenHeaderVisible =
        80.0; // matches visual header height

    return Container(
      color: _currentTheme.backgroundColor,
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            top: (_showControls && (isAtTop || _applyTopInsetAtChapterStart))
                ? topInsetWhenHeaderVisible
                : 0.0,
          ),
          child: _buildContent(),
        ),
      ),
    );
  }

  /// Floating toolbar shown when text is selected (uses frozen text preview, resolves on action)
  Widget _buildSelectionToolbarOverlay() {
    // Position slightly above the last tap/drag point and clamp to screen
    const double verticalPadding = 12.0;
    final RenderBox? stackBox =
        _rootStackKey.currentContext?.findRenderObject() as RenderBox?;
    final Size screenSize = stackBox?.size ?? Size.zero;

    // Measure toolbar size after first frame to compute clamped position
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctx = _toolbarKey.currentContext;
      if (ctx != null) {
        final box = ctx.findRenderObject() as RenderBox?;
        final size = box?.size;
        if (size != null && (_toolbarSize == null || _toolbarSize != size)) {
          if (mounted) {
            setState(() {
              _toolbarSize = size;
            });
          }
        }
      }
    });

    // Default position: center top area if we lack pointer info
    Offset preferred = Offset(screenSize.width / 2, 120);
    if (_lastPointerGlobalPosition != null && stackBox != null) {
      preferred = stackBox.globalToLocal(_lastPointerGlobalPosition!);
    }

    final Size tb = _toolbarSize ?? const Size(180, 44);
    double left = preferred.dx - tb.width / 2;
    double top = preferred.dy - tb.height - verticalPadding;

    // Clamp inside screen with margins
    const double margin = 8.0;
    left = left.clamp(margin, (screenSize.width - tb.width - margin));
    top = top.clamp(margin, (screenSize.height - tb.height - margin));

    String resolveSelected() {
      return _selectionState.selectedText.isNotEmpty
          ? _selectionState.selectedText
          : _selectionFrozenText;
    }

    return Positioned(
      left: left,
      top: top,
      child: SelectionToolbar(
        key: _toolbarKey,
        theme: _currentTheme,
        selectedText: _selectionFrozenText,
        onCopy: () {
          final text = resolveSelected();
          if (text.isEmpty) return;
          Clipboard.setData(ClipboardData(text: text));
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Copied'),
              backgroundColor: _currentTheme.accentColor,
              duration: const Duration(seconds: 1),
            ),
          );
        },
        onBookmark: () {
          final text = resolveSelected();
          if (text.isNotEmpty) {
            _showBookmarkSheet(text);
          }
        },
        onHighlight: () {
          final text = resolveSelected();
          if (text.isNotEmpty) {
            _showHighlightSheet(text);
          }
        },
        onNote: () {
          final text = resolveSelected();
          if (text.isNotEmpty) {
            _showNoteSheet(text);
          }
        },
      ),
    );
  }

  /// Returns true if there is an active text selection inside the content
  bool _hasActiveSelection() {
    try {
      final BuildContext? selCtx = _selectionAreaKey.currentContext;
      final selectionContainer = selCtx != null
          ? SelectionContainer.maybeOf(selCtx)
          : null;
      if (selectionContainer != null) {
        // Access hasSelection if available
        final dynamic dyn = selectionContainer;
        if (dyn.hasSelection is bool) {
          final bool hasSel = dyn.hasSelection as bool;

          return hasSel;
        }
      }
    } catch (_) {
      // Fallback safely if API differs on older Flutter versions
    }
    return false;
  }

  // Removed legacy selection watch

  /// Builds the header with book information
  Widget _buildHeader() {
    // Get styling from appBarStyle or use defaults
    final style = widget.appBarStyle;
    final titleFontFamily =
        style?.titleFontFamily ?? 'Inter, system-ui, -apple-system, sans-serif';
    final titleFontSize = style?.titleFontSize ?? 18.0;
    final titleFontWeight = style?.titleFontWeight ?? FontWeight.bold;
    final subtitleFontFamily =
        style?.subtitleFontFamily ??
        'Inter, system-ui, -apple-system, sans-serif';
    final subtitleFontSize = style?.subtitleFontSize ?? 14.0;
    final subtitleFontWeight = style?.subtitleFontWeight ?? FontWeight.normal;
    final backgroundColor =
        style?.backgroundColor ?? _currentTheme.backgroundColor;
    final textColor = style?.textColor ?? _currentTheme.textColor;
    final borderColor = style?.borderColor ?? _currentTheme.dividerColor;
    final padding = style?.padding ?? const EdgeInsets.all(16.0);

    debugPrint('XXX _buildHeader: appBarStyle = $style');
    debugPrint('XXX _buildHeader: titleFontFamily = $titleFontFamily');
    debugPrint('XXX _buildHeader: subtitleFontFamily = $subtitleFontFamily');

    return GestureDetector(
      onTap: () {}, // Consume taps in header area
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          color: backgroundColor,
          border: Border(bottom: BorderSide(color: borderColor, width: 1.0)),
        ),
        child: Row(
          children: [
            // Back button
            IconButton(
              icon: Icon(Icons.arrow_back, color: textColor),
              onPressed: () => Navigator.of(context).pop(),
            ),

            // Book title and author info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${_formatBookTitle(widget.book.metadata.title)} [DEV]',
                    style: TextStyle(
                      fontSize: titleFontSize,
                      fontWeight: titleFontWeight,
                      color: textColor,
                      fontFamily: titleFontFamily,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'by ${widget.book.metadata.creator ?? 'Unknown Author'}',
                    style: TextStyle(
                      fontSize: subtitleFontSize,
                      fontWeight: subtitleFontWeight,
                      color: textColor,
                      fontFamily: subtitleFontFamily,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Formats book title with proper title case
  String _formatBookTitle(String title) {
    if (title.isEmpty) return title;

    // Split the title into words
    final words = title.split(' ');

    // Words that should always be lowercase (unless they're the first or last word)
    const lowercaseWords = {
      'a',
      'an',
      'and',
      'as',
      'at',
      'but',
      'by',
      'for',
      'if',
      'in',
      'is',
      'it',
      'no',
      'not',
      'of',
      'on',
      'or',
      'so',
      'the',
      'to',
      'up',
      'yet',
    };

    // Format each word
    final formattedWords = words.asMap().entries.map((entry) {
      final index = entry.key;
      final word = entry.value.toLowerCase();

      // Always capitalize the first and last word
      if (index == 0 || index == words.length - 1) {
        return _capitalizeFirst(word);
      }

      // Capitalize words that are not in the lowercase list
      if (!lowercaseWords.contains(word)) {
        return _capitalizeFirst(word);
      }

      // Keep other words lowercase
      return word;
    }).toList();

    return formattedWords.join(' ');
  }

  /// Capitalizes the first letter of a word
  String _capitalizeFirst(String word) {
    if (word.isEmpty) return word;
    return word[0].toUpperCase() + word.substring(1).toLowerCase();
  }

  /// Builds the main content area
  Widget _buildContent() {
    if (_currentContent.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    // Check if current chapter is a cover chapter
    final currentChapter = widget.book.chapters[_currentChapterIndex];
    final isCoverChapter = currentChapter.isCoverChapter;
    final hasCoverImage = widget.book.coverImage != null;

    print('DEBUG: Cover chapter check:');
    print('DEBUG:   Current chapter index: $_currentChapterIndex');
    print('DEBUG:   Chapter title: "${currentChapter.title}"');
    print('DEBUG:   isCoverChapter: $isCoverChapter');
    print('DEBUG:   hasCoverImage: $hasCoverImage');
    print('DEBUG:   Cover image bytes: ${widget.book.coverImage?.length ?? 0}');

    // If this is a cover chapter and we have a cover image, show special cover view
    if (isCoverChapter && hasCoverImage) {
      print('DEBUG: Showing cover view!');
      return _buildCoverView();
    } else {
      print(
        'DEBUG: Not showing cover view - isCoverChapter: $isCoverChapter, hasCoverImage: $hasCoverImage',
      );
    }

    final currentFontFamily = ThemeManager.getCurrentFontFamily();
    final currentFontSize = ThemeManager.getCurrentFontSize();
    final currentLineHeight = ThemeManager.getCurrentLineHeight();

    // Use the new Google Fonts system - no need for old CSS injection
    String contentToRender = _renderedContent.isNotEmpty
        ? _renderedContent
        : _currentContent;

    return Container(
      margin: EdgeInsets.all(ThemeManager.getCurrentMargin()),
      color: _currentTheme.backgroundColor, // Add background color
      child: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          children: [
            // Main HTML content - let EpubContentBuilder handle all font styling
            _buildContentWithFont(
              currentFontFamily,
              currentFontSize,
              currentLineHeight,
              contentToRender,
            ),
          ],
        ),
      ),
    );
  }

  /// Builds a special cover view for cover chapters
  Widget _buildCoverView() {
    print('DEBUG: _buildCoverView called');
    print('DEBUG:   Book title: ${widget.book.metadata.title}');
    print('DEBUG:   Book author: ${widget.book.metadata.creator}');
    print('DEBUG:   Cover image bytes: ${widget.book.coverImage?.length ?? 0}');

    return Container(
      width: double.infinity,
      height: double.infinity,
      color: _currentTheme.backgroundColor,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Cover image
          if (widget.book.coverImage != null) ...[
            Container(
              constraints: const BoxConstraints(maxWidth: 300, maxHeight: 400),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.memory(
                  Uint8List.fromList(widget.book.coverImage!),
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],

          // Book title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              widget.book.metadata.title,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: _currentTheme.textColor,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          // Author
          if (widget.book.metadata.creator != null) ...[
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'by ${widget.book.metadata.creator}',
                style: TextStyle(
                  fontSize: 18,
                  color: _currentTheme.secondaryTextColor,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],

          // Publisher and date
          if (widget.book.metadata.publisher != null ||
              widget.book.metadata.date != null) ...[
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                [
                  if (widget.book.metadata.publisher != null)
                    widget.book.metadata.publisher,
                  if (widget.book.metadata.date != null)
                    widget.book.metadata.date!.year.toString(),
                ].join(' • '),
                style: TextStyle(
                  fontSize: 14,
                  color: _currentTheme.secondaryTextColor,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],

          // Tap to continue hint
          const SizedBox(height: 48),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: _currentTheme.accentColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _currentTheme.accentColor.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Text(
              'Tap anywhere to continue reading',
              style: TextStyle(
                fontSize: 14,
                color: _currentTheme.accentColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds content with the selected font using multiple approaches
  Widget _buildContentWithFont(
    String fontFamily,
    double fontSize,
    double lineHeight,
    String content,
  ) {
    debugPrint('Building content with theme: ${_currentTheme.name}');
    debugPrint(
      'Theme colors - Background: ${_currentTheme.backgroundColor}, Text: ${_currentTheme.textColor}',
    );

    // Prepare lightweight highlight indicators for current chapter
    List<Map<String, dynamic>>? chapterHighlights;
    try {
      chapterHighlights = _chapterHighlights;
    } catch (_) {}

    return EpubContentBuilder.buildContentWithFont(
      fontFamily,
      fontSize,
      lineHeight,
      content,
      _currentTheme,
      _handleLinkTap,
      selectionAreaKey: _selectionAreaKey,
      selectionChildContextNotifier: _selectionDescendantContext,
      rebuildCounter: _selectionResetCounter,
      // Temporarily disable visual bookmarks/notes per request; show only highlights
      bookmarks: null,
      notes: null,
      highlights: () {
        final count = chapterHighlights?.length ?? 0;
        debugPrint('[Perf][EpubViewer] Passing $count highlight(s) to builder');
        return chapterHighlights;
      }(),
      onTextSelected: (text) {
        final bool wasActive = _selectionState.isActive;

        if (text.isEmpty && wasActive) {
          // Don't immediately deactivate during handle drag; wait briefly
          _selectionClearTimer?.cancel();
          _selectionClearTimer = Timer(const Duration(milliseconds: 200), () {
            if (!mounted) return;
            if (_selectionState.isActive &&
                _selectionState.selectedText.isEmpty) {
              setState(() {
                _selectionState.clearSelection();
                _selectionFrozenText = '';
              });
            }
          });
          return; // keep current active state for now
        }

        // Non-empty selection or activation from inactive → update immediately
        _selectionClearTimer?.cancel();
        final bool becomingActive = !wasActive && text.isNotEmpty;
        _selectionState.updateSelection(text);

        if (becomingActive) {
          // Freeze preview text on first activation; do not update on subsequent drag changes
          _selectionFrozenText = text;
          if (mounted) setState(() {});
        }

        widget.onTextSelected?.call(text);
      },
    );
  }

  // Reserved for future: hex conversion if we reintroduce sync highlight mapping

  /// Builds the controls overlay
  Widget _buildControlsOverlay() {
    // Show based on _showControls state
    final shouldShow = _showControls;

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      bottom: shouldShow ? 0 : -200, // Slide down when shown, up when hidden
      left: 0,
      right: 0,
      child: ReadingControls(
        currentChapterIndex: _currentChapterIndex,
        totalChapters: widget.book.chapters.length,
        currentPosition: _currentPosition,
        currentBookPage: _pageNotifier.value,
        totalBookPages: _totalBookPages,
        onPreviousChapter: _previousChapter,
        onNextChapter: _nextChapter,
        onToggleTableOfContents: _toggleTableOfContents,
        onGoToPage: _goToBookPage,
        pageNotifier: _pageNotifier,
        theme: _currentTheme,
        searchController: _searchController,
        onShowBookmarks: _showBookmarksList,
        onShowNotes: _showNotesList,
      ),
    );
  }

  /// Builds the table of contents overlay
  Widget _buildTableOfContentsOverlay() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      bottom: 0,
      child: TableOfContents(
        book: widget.book,
        currentChapterIndex: _currentChapterIndex,
        onChapterSelected: _goToChapter,
        onClose: _toggleTableOfContents,
        theme: _currentTheme,
      ),
    );
  }

  /// Builds the loading indicator
  Widget _buildLoadingIndicator() {
    return Container(
      color: _currentTheme.backgroundColor.withOpacity(0.8),
      child: Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(_currentTheme.accentColor),
        ),
      ),
    );
  }

  /// Updates the current book page based on the current chapter position
  void _updateCurrentBookPageForChapter() {
    try {
      debugPrint(
        '[EpubViewer] _updateCurrentBookPageForChapter: Starting calculation',
      );
      debugPrint(
        '[EpubViewer] _updateCurrentBookPageForChapter: Current chapter index: $_currentChapterIndex',
      );

      // Calculate the starting book page for the current chapter
      int bookPageStart = 1;
      for (int i = 0; i < _currentChapterIndex; i++) {
        final chapterPages = PageCalculationService.calculateChapterPages(
          widget.book.chapters[i],
          context,
        );
        bookPageStart += chapterPages;
        debugPrint(
          '[EpubViewer] _updateCurrentBookPageForChapter: Chapter $i has $chapterPages pages, bookPageStart = $bookPageStart',
        );
      }

      // Update the current book page and notifier
      _currentBookPage = bookPageStart;
      _pageNotifier.value = bookPageStart;
      // Also sync _currentPosition with the actual scroll to reduce off-by-one when returning
      if (_scrollController.hasClients &&
          _scrollController.position.maxScrollExtent > 0) {
        final ratio =
            (_scrollController.position.pixels /
                    _scrollController.position.maxScrollExtent)
                .clamp(0.0, 1.0);
        _currentPosition = ratio;
      }

      debugPrint(
        '[EpubViewer] _updateCurrentBookPageForChapter: Updated _currentBookPage to $bookPageStart',
      );
      debugPrint(
        '[EpubViewer] _updateCurrentBookPageForChapter: Updated pageNotifier.value to ${_pageNotifier.value}',
      );

      // Trigger a rebuild to update the UI
      setState(() {});
    } catch (e) {
      debugPrint(
        '[EpubViewer] _updateCurrentBookPageForChapter: Error calculating book page: $e',
      );
    }
  }

  /// Loads a chapter
  Future<void> _loadChapter(int chapterIndex) async {
    if (chapterIndex < 0 || chapterIndex >= widget.book.chapters.length) {
      return;
    }

    setState(() {
      _isLoading = true;
      _currentChapterIndex = chapterIndex;
      _currentBookPage = 1; // Reset to first page of new chapter
      _applyTopInsetAtChapterStart =
          true; // ensure top inset on new chapter load
      debugPrint(
        '[EpubViewer] _loadChapter: Reset _currentBookPage to 1 for new chapter',
      );
    });

    try {
      final chapter = widget.book.chapters[chapterIndex];

      _currentContent = chapter.content;
      _renderedContent = _currentContent;

      // Calculate page counts for the new chapter
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          debugPrint(
            '[EpubViewer] _loadChapter: Calculating page counts for chapter $_currentChapterIndex',
          );
          debugPrint(
            '[EpubViewer] _loadChapter: Current book page before calculation: $_currentBookPage',
          );
          _calculatePageCounts();
          _updateCurrentBookPageForChapter();
        }
      });

      // Update progress
      await _updateProgress();

      // Load saved highlights for this chapter as lightweight indicators (no regex rewriting)
      try {
        final allHighlights = await HighlightService.getHighlights(
          widget.book.id,
        );
        _chapterHighlights = allHighlights
            .where((h) => h.chapterIndex == _currentChapterIndex)
            .map(
              (h) => {
                'text': h.text,
                'color':
                    '#${h.color.value.toRadixString(16).substring(2).toUpperCase()}',
                'position': 0.0,
              },
            )
            .toList();
        debugPrint(
          '[EpubViewer] Loaded ${_chapterHighlights?.length ?? 0} highlights for chapter $_currentChapterIndex',
        );
      } catch (e) {
        debugPrint('[EpubViewer] Error loading highlights: $e');
        _chapterHighlights = null;
      }

      // Notify callback
      widget.onChapterChanged?.call(chapterIndex);

      setState(() {
        _isLoading = false;
      });

      debugPrint(
        '[EpubViewer] _loadChapter: Chapter $_currentChapterIndex loaded successfully',
      );
      debugPrint(
        '[EpubViewer] _loadChapter: Final current book page: $_currentBookPage',
      );
      debugPrint(
        '[EpubViewer] _loadChapter: Page notifier value: ${_pageNotifier.value}',
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
        _currentContent = 'Error loading chapter: $e';
      });
    }
  }

  /// Calculates page counts for the entire book
  void _calculatePageCounts() {
    if (!mounted) return;

    try {
      // Calculate total pages for entire book
      _totalBookPages = PageCalculationService.calculateBookTotalPages(
        widget.book.chapters,
        context,
      );

      setState(() {});
    } catch (e) {}
  }

  /// Updates reading progress
  Future<void> _updateProgress() async {
    final chapterProgress = _currentPosition;
    final bookProgress =
        (_currentChapterIndex + chapterProgress) / widget.book.chapters.length;

    _readingProgress = _readingProgress.copyWith(
      currentChapterIndex: _currentChapterIndex,
      chapterProgress: chapterProgress,
      bookProgress: bookProgress,
      currentPage: _currentBookPage,
      totalPages: _totalBookPages,
      lastReadAt: DateTime.now(),
    );

    await ProgressService.saveProgress(_readingProgress);
    widget.onProgressChanged?.call(_readingProgress);
  }

  /// Toggles the controls visibility
  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
      if (_showControls) {
        _controlsAnimationController.forward();
        _headerAnimationController.forward();
      } else {
        _controlsAnimationController.reverse();
        _headerAnimationController.reverse();
      }
    });
  }

  /// Toggles the table of contents visibility
  void _toggleTableOfContents() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ChaptersSheet(
        book: widget.book,
        onChapterSelected: (index) {
          _loadChapter(index);
        },
      ),
    );
  }

  /// Goes to a specific chapter
  void _goToChapter(int chapterIndex) {
    _toggleTableOfContents();
    _loadChapter(chapterIndex);
  }

  /// Goes to the previous chapter
  void _previousChapter() {
    if (_currentChapterIndex > 0) {
      _loadChapter(_currentChapterIndex - 1);
    }
  }

  /// Goes to the next chapter
  void _nextChapter() {
    if (_currentChapterIndex < widget.book.chapters.length - 1) {
      _loadChapter(_currentChapterIndex + 1);
    }
  }

  /// Shows the menu
  // Removed legacy menu, now unused

  /// Handles link taps
  void _handleLinkTap(String? url, Map<String, String> attributes, element) {
    // Handle internal links (e.g., to other chapters)
    if (url != null && url.startsWith('#')) {
      // Handle anchor links within the same chapter
      _scrollToAnchor(url.substring(1));
    } else if (url != null && url.startsWith('chapter')) {
      // Handle chapter links
      final chapterMatch = RegExp(r'chapter(\d+)').firstMatch(url);
      if (chapterMatch != null) {
        final chapterIndex = int.parse(chapterMatch.group(1)!) - 1;
        _goToChapter(chapterIndex);
      }
    }
  }

  /// Scrolls to an anchor within the current chapter
  void _scrollToAnchor(String anchor) {
    // Implementation would depend on the specific HTML rendering approach
    // For now, this is a placeholder
  }

  /// Shows the page jump dialog
  // Removed legacy page jump dialog, use page jump sheet via ReadingControls

  // --- Search implementation ---
  Future<List<EpubSearchMatch>> _executeSearch(String query) async {
    if (query.trim().isEmpty) return <EpubSearchMatch>[];

    // Lazy build plain-text cache
    _chapterPlainTexts ??= widget.book.chapters
        .map((c) => _stripHtmlToPlainText(c.content))
        .toList(growable: false);

    final List<EpubSearchMatch> hits = <EpubSearchMatch>[];
    final q = query.toLowerCase();
    for (int i = 0; i < _chapterPlainTexts!.length; i++) {
      final text = _chapterPlainTexts![i].toLowerCase();
      int start = 0;
      int occurrence = 0;
      while (true) {
        final idx = text.indexOf(q, start);
        if (idx == -1) break;
        final end = idx + q.length;
        final previewStart = (idx - 40).clamp(0, text.length);
        final previewEnd = (end + 40).clamp(0, text.length);
        final previewText = _chapterPlainTexts![i]
            .substring(previewStart, previewEnd)
            .replaceAll('\n', ' ')
            .trim();
        hits.add(
          EpubSearchMatch(
            chapterIndex: i,
            startOffset: idx,
            endOffset: end,
            previewText: previewText,
            indexWithinChapter: occurrence,
          ),
        );
        occurrence++;
        start = end;
      }
    }
    return hits;
  }

  Future<void> _navigateToMatch(EpubSearchMatch match) async {
    // Jump to chapter, then attempt to scroll near the text by percentage fallback
    if (match.chapterIndex != _currentChapterIndex) {
      await _loadChapter(match.chapterIndex);
      // Approximate by ratio of startOffset to chapter text length
      final chapterText = _stripHtmlToPlainText(_currentContent);
      final ratio = chapterText.isNotEmpty
          ? (match.startOffset / chapterText.length).clamp(0.0, 1.0)
          : 0.0;
      _scrollToPositionCentered(ratio.toDouble());
      await _applySearchHighlights(
        _searchController.query.value,
        match.indexWithinChapter,
      );
    } else {
      final chapterText = _stripHtmlToPlainText(_currentContent);
      final ratio = chapterText.isNotEmpty
          ? (match.startOffset / chapterText.length).clamp(0.0, 1.0)
          : 0.0;
      _scrollToPositionCentered(ratio.toDouble());
      await _applySearchHighlights(
        _searchController.query.value,
        match.indexWithinChapter,
      );
    }
  }

  void _scrollToPositionCentered(double position) {
    if (!_scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) _scrollToPositionCentered(position);
      });
      return;
    }
    final maxScrollExtent = _scrollController.position.maxScrollExtent;
    final viewport = _scrollController.position.viewportDimension;
    double target =
        (maxScrollExtent * position.clamp(0.0, 1.0)) - (viewport / 2);
    if (target < 0) target = 0;
    if (target > maxScrollExtent) target = maxScrollExtent;
    _scrollController.animateTo(
      target,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  void _showHighlightSheet(String selectedText) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: false,
      backgroundColor: Colors.transparent,
      builder: (ctx) => HighlightSheet(
        selectedText: selectedText,
        onColorSelected: (color) async {
          // Save highlight to storage
          await _saveHighlight(selectedText, color);

          // Add to current chapter highlights for immediate display
          final newHighlight = {
            'text': selectedText,
            'color':
                '#${color.value.toRadixString(16).substring(2).toUpperCase()}',
            'position': 0.0,
          };

          _chapterHighlights ??= [];
          _chapterHighlights!.add(newHighlight);

          // Rebuild to show the highlight
          setState(() {});

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Highlight applied'),
              backgroundColor: color,
              duration: const Duration(seconds: 1),
            ),
          );
        },
      ),
    );
  }

  void _showBookmarkSheet(String selectedText) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => BookmarkSheet(
        selectedText: selectedText,
        onSave: (String? title) {
          // Call the callback with current position data
          widget.onBookmarkSaved?.call(
            chapterIndex: _currentChapterIndex,
            position: _currentPosition,
            selectedText: selectedText,
            title: title,
          );

          Navigator.pop(ctx);
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Bookmark added')));
        },
      ),
    );
  }

  void _showNoteSheet(String selectedText) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => NoteSheet(
        selectedText: selectedText,
        onSave: (String content, String? color) {
          // Call the callback with current position data
          widget.onNoteSaved?.call(
            chapterIndex: _currentChapterIndex,
            position: _currentPosition,
            selectedText: selectedText,
            noteContent: content,
            color: color,
          );

          // Do NOT run expensive inline highlight here; rely on indicators path
          // (same as bookmarks) to avoid lag and wrong-target matches.

          Navigator.pop(ctx);
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Note saved')));
        },
      ),
    );
  }

  void _showBookmarksList() {
    widget.onShowBookmarks?.call();
  }

  void _showNotesList() {
    widget.onShowNotes?.call();
  }

  // Strip HTML tags to plain text for indexing
  String _stripHtmlToPlainText(String html) {
    // Very lightweight stripping suitable for search indexing
    final withoutTags = html.replaceAll(RegExp(r'<[^>]*>'), ' ');
    final withoutEntities = withoutTags
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>');
    return withoutEntities.replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  Future<void> _applySearchHighlights(String query, int emphasizeIndex) async {
    debugPrint(
      '[Search] _applySearchHighlights called with query: "$query", emphasizeIndex: $emphasizeIndex',
    );
    if (query.trim().isEmpty) {
      debugPrint(
        '[Search] Query is empty, clearing search highlights but preserving user highlights',
      );
      // Reload user highlights instead of resetting to raw content
      _loadAndApplySavedHighlights();
      return;
    }
    // For search highlighting, we need to work with clean content to avoid conflicts
    // with existing user highlights. We'll temporarily reset to raw content, apply search
    // highlights, then reapply user highlights on top.
    try {
      // Store current content with user highlights
      // Keep a copy if needed for future merges

      // Reset to raw content for clean search highlighting
      _renderedContent = _currentContent;

      final escaped = RegExp.escape(query.trim());
      final pattern = RegExp(escaped, caseSensitive: false);
      debugPrint('[Search] Pattern: $escaped');

      int occurrence = 0;
      final buffer = StringBuffer();
      int last = 0;
      final matches = pattern.allMatches(_renderedContent);
      debugPrint('[Search] Found ${matches.length} matches');

      for (final m in matches) {
        buffer.write(_renderedContent.substring(last, m.start));
        final mid = _renderedContent.substring(m.start, m.end);
        final style = occurrence == emphasizeIndex
            ? 'background-color: rgba(255,230,0,0.9); outline: 1px solid rgba(0,0,0,0.2);'
            : 'background-color: rgba(255,230,0,0.4);';
        buffer.write('<span style="$style">$mid</span>');
        debugPrint('[Search] Highlighted occurrence $occurrence: "$mid"');
        last = m.end;
        occurrence++;
      }
      buffer.write(_renderedContent.substring(last));

      // Apply search highlights
      _renderedContent = buffer.toString();

      // Now reapply user highlights on top of search highlights
      await _loadAndApplySavedHighlights();

      debugPrint('[Search] Search and user highlights applied successfully');
    } catch (e) {
      debugPrint('[Search] Error applying highlights: $e');
    }
  }

  /// Goes to a specific page within the entire book
  void _goToBookPage(int targetBookPage) {
    if (targetBookPage < 1 || targetBookPage > _totalBookPages) return;

    try {
      // Pre-calculate all chapter page counts to avoid repeated calculations
      final List<int> chapterPageCounts = [];

      for (int i = 0; i < widget.book.chapters.length; i++) {
        final chapterPages = PageCalculationService.calculateChapterPages(
          widget.book.chapters[i],
          context,
        );
        chapterPageCounts.add(chapterPages);
      }

      // Find which chapter contains the target page
      int currentPageCount = 0;
      int targetChapterIndex = 0;

      for (int i = 0; i < chapterPageCounts.length; i++) {
        if (currentPageCount + chapterPageCounts[i] >= targetBookPage) {
          targetChapterIndex = i;
          break;
        }
        currentPageCount += chapterPageCounts[i];
      }

      // If we need to change chapters, do that first
      if (targetChapterIndex != _currentChapterIndex) {
        _loadChapter(targetChapterIndex);
      }

      // Calculate the target scroll position within the chapter
      final chapterPage = targetBookPage - currentPageCount;
      final totalChapterPages = chapterPageCounts[targetChapterIndex];

      if (chapterPage > 0 && chapterPage <= totalChapterPages) {
        final pageProgress = (chapterPage - 1) / totalChapterPages;
        final targetScrollPosition =
            pageProgress * _scrollController.position.maxScrollExtent;

        // Animate to the target position
        _scrollController.animateTo(
          targetScrollPosition,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );

        // Update current book page
        setState(() {
          _currentBookPage = targetBookPage;
        });

        // Update progress
        _updateProgress();
      }
    } catch (e) {}
  }

  // Removed legacy text selection menu in favor of bottom SelectionControls

  @override
  void dispose() {
    // Remove listeners
    ThemeManager.removeThemeListener(_onThemeChanged);
    ThemeManager.removeFontSizeListener(_onFontSizeChanged);
    ThemeManager.removeFontFamilyListener(_onFontFamilyChanged);
    ThemeManager.removeLineHeightListener(_onLineHeightChanged);
    ThemeManager.removeMarginListener(_onMarginChanged);
    ThemeManager.removeReadingStyleListener(_onReadingStyleChanged);

    // Remove scroll listener and dispose controller
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();

    // Cancel any pending progress updates
    _progressUpdateTimer?.cancel();

    // Cancel selection debounce timer
    _selectionDebounceTimer?.cancel();
    _selectionClearTimer?.cancel();

    // Dispose page notifier
    _pageNotifier.dispose();

    // Dispose animation controllers
    _controlsAnimationController.dispose();
    _headerAnimationController.dispose();

    // Hold-to-exit timer removed

    // Update reading progress when disposing
    if (_readingStartTime != null) {
      final readingDuration = DateTime.now()
          .difference(_readingStartTime!)
          .inSeconds;
      if (readingDuration > 0) {
        ProgressService.updateReadingSpeed(
          widget.book.id,
          _wordsRead,
          readingDuration,
        );
      }
    }

    // Dispose search controller
    _searchController.dispose();

    super.dispose();
  }
}
