import 'package:flutter/material.dart';
import '../models/epub_book.dart';
import '../utils/reading_theme.dart';

/// Widget for displaying the table of contents
class TableOfContents extends StatelessWidget {
  /// The EPUB book to display TOC for
  final EpubBook book;

  /// Current chapter index
  final int currentChapterIndex;

  /// Callback when a chapter is selected
  final Function(int)? onChapterSelected;

  /// Callback when the TOC is closed
  final VoidCallback? onClose;

  /// Current reading theme
  final ReadingTheme theme;

  const TableOfContents({
    super.key,
    required this.book,
    required this.currentChapterIndex,
    this.onChapterSelected,
    this.onClose,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: theme.backgroundColor,
      child: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(),

            // Divider
            Container(height: 1.0, color: theme.dividerColor),

            // Table of contents
            Expanded(child: _buildTableOfContents()),
          ],
        ),
      ),
    );
  }

  /// Builds the header
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          // Close button
          IconButton(
            icon: Icon(Icons.close, color: theme.textColor),
            onPressed: onClose,
          ),

          // Title
          Expanded(
            child: Text(
              'Table of Contents',
              style: TextStyle(
                color: theme.textColor,
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // Book title
          Expanded(
            child: Text(
              book.metadata.title,
              style: TextStyle(color: theme.secondaryTextColor, fontSize: 14.0),
              textAlign: TextAlign.right,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the table of contents
  Widget _buildTableOfContents() {
    if (book.tableOfContents.isEmpty && book.chapters.isEmpty) {
      return _buildEmptyState();
    }

    // Use table of contents if available, otherwise fall back to chapters
    final tocItems = book.tableOfContents.isNotEmpty
        ? _buildTocFromMetadata()
        : _buildTocFromChapters();

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      itemCount: tocItems.length,
      itemBuilder: (context, index) {
        final item = tocItems[index];
        return _buildTocItem(item, index);
      },
    );
  }

  /// Builds TOC items from metadata
  List<TocItem> _buildTocFromMetadata() {
    final items = <TocItem>[];

    for (int i = 0; i < book.tableOfContents.length; i++) {
      final toc = book.tableOfContents[i];
      final label = toc['label'] as String? ?? 'Chapter ${i + 1}';
      final src = toc['src'] as String? ?? '';

      // Find corresponding chapter index
      int chapterIndex = i;
      if (src.isNotEmpty) {
        // Try to match src with chapter file paths
        for (int j = 0; j < book.chapters.length; j++) {
          if (book.chapters[j].filePath.contains(src) ||
              src.contains(book.chapters[j].filePath)) {
            chapterIndex = j;
            break;
          }
        }
      }

      items.add(
        TocItem(
          label: label,
          chapterIndex: chapterIndex,
          level: 0,
          hasChildren: false,
        ),
      );
    }

    return items;
  }

  /// Builds TOC items from chapters
  List<TocItem> _buildTocFromChapters() {
    return book.chapters.asMap().entries.map((entry) {
      final index = entry.key;
      final chapter = entry.value;

      return TocItem(
        label: chapter.title,
        chapterIndex: index,
        level: chapter.level,
        hasChildren: chapter.hasChildren,
      );
    }).toList();
  }

  /// Builds a TOC item
  Widget _buildTocItem(TocItem item, int index) {
    final isCurrentChapter = item.chapterIndex == currentChapterIndex;

    return Container(
      margin: EdgeInsets.only(left: item.level * 16.0, bottom: 4.0),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: isCurrentChapter
            ? Icon(Icons.bookmark, color: theme.accentColor, size: 20.0)
            : null,
        title: Text(
          item.label,
          style: TextStyle(
            color: isCurrentChapter ? theme.accentColor : theme.textColor,
            fontWeight: isCurrentChapter ? FontWeight.bold : FontWeight.normal,
            fontSize: 16.0,
          ),
        ),
        subtitle: item.hasChildren
            ? Text(
                '${item.childrenCount} sub-chapters',
                style: TextStyle(
                  color: theme.secondaryTextColor,
                  fontSize: 12.0,
                ),
              )
            : null,
        trailing: isCurrentChapter
            ? Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8.0,
                  vertical: 4.0,
                ),
                decoration: BoxDecoration(
                  color: theme.accentColor,
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Text(
                  'Current',
                  style: TextStyle(
                    color: theme.backgroundColor,
                    fontSize: 10.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            : null,
        onTap: () {
          onChapterSelected?.call(item.chapterIndex);
        },
      ),
    );
  }

  /// Builds empty state
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.book_outlined,
            size: 64.0,
            color: theme.secondaryTextColor,
          ),
          const SizedBox(height: 16.0),
          Text(
            'No table of contents available',
            style: TextStyle(color: theme.secondaryTextColor, fontSize: 16.0),
          ),
          const SizedBox(height: 8.0),
          Text(
            'This book doesn\'t have a structured table of contents.',
            style: TextStyle(color: theme.secondaryTextColor, fontSize: 14.0),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Represents a table of contents item
class TocItem {
  /// The label/title of the item
  final String label;

  /// The chapter index this item represents
  final int chapterIndex;

  /// The nesting level of this item
  final int level;

  /// Whether this item has children
  final bool hasChildren;

  /// Number of children (if any)
  int get childrenCount => hasChildren ? 1 : 0;

  const TocItem({
    required this.label,
    required this.chapterIndex,
    this.level = 0,
    this.hasChildren = false,
  });
}
