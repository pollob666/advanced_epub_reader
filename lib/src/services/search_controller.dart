import 'package:flutter/foundation.dart';

/// Represents a single search match across the book
class EpubSearchMatch {
  final int chapterIndex;
  final int startOffset;
  final int endOffset;
  final String previewText;
  // Occurrence index within its chapter for emphasis highlighting
  final int indexWithinChapter;

  EpubSearchMatch({
    required this.chapterIndex,
    required this.startOffset,
    required this.endOffset,
    required this.previewText,
    required this.indexWithinChapter,
  });
}

/// Controller exposed to client apps to drive in-reader search.
///
/// The reader owns navigation (jumping to matches) while the panel (client)
/// owns the UI. The controller mediates query, results, and navigation.
class EpubSearchController {
  final ValueNotifier<String> query = ValueNotifier<String>('');
  final ValueNotifier<List<EpubSearchMatch>> results =
      ValueNotifier<List<EpubSearchMatch>>(<EpubSearchMatch>[]);
  final ValueNotifier<int> currentIndex = ValueNotifier<int>(-1);

  /// Called by the viewer when it needs to navigate to a specific result
  /// (e.g., when currentIndex changes). The viewer should set this.
  void Function(EpubSearchMatch match)? onNavigateToMatch;

  /// Called by the viewer to request the host panel (demo/app) to close.
  /// The host panel should set this when it opens.
  VoidCallback? requestClosePanel;

  /// Called by the viewer when results change (so client can react if needed)
  VoidCallback? onResultsUpdated;

  /// The viewer should set this to implement how a query is executed.
  /// Returns the computed results.
  Future<List<EpubSearchMatch>> Function(String query)? onExecuteQuery;

  /// Update the query and trigger a search (debounced externally by the panel if desired)
  Future<void> setQuery(String value) async {
    query.value = value;
    if (onExecuteQuery == null) {
      results.value = <EpubSearchMatch>[];
      currentIndex.value = -1;
      return;
    }
    final hits = await onExecuteQuery!.call(value);
    results.value = hits;
    if (hits.isEmpty) {
      currentIndex.value = -1;
    } else {
      currentIndex.value = 0;
      onNavigateToMatch?.call(hits[0]);
    }
    onResultsUpdated?.call();
  }

  void next() {
    final hits = results.value;
    if (hits.isEmpty) return;
    final nextIndex = (currentIndex.value + 1) % hits.length;
    currentIndex.value = nextIndex;
    onNavigateToMatch?.call(hits[nextIndex]);
  }

  void previous() {
    final hits = results.value;
    if (hits.isEmpty) return;
    final prevIndex = (currentIndex.value - 1 + hits.length) % hits.length;
    currentIndex.value = prevIndex;
    onNavigateToMatch?.call(hits[prevIndex]);
  }

  void clear() {
    query.value = '';
    results.value = <EpubSearchMatch>[];
    currentIndex.value = -1;
    onResultsUpdated?.call();
  }

  void dispose() {
    query.dispose();
    results.dispose();
    currentIndex.dispose();
  }
}
