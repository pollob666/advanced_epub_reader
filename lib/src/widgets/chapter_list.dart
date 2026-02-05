import 'package:flutter/material.dart';
import '../models/epub_book.dart';
import '../models/epub_chapter.dart';
import '../utils/reading_theme.dart';

/// Widget for displaying a list of chapters
class ChapterList extends StatelessWidget {
  /// The EPUB book to display chapters for
  final EpubBook book;

  /// Current chapter index
  final int currentChapterIndex;

  /// Callback when a chapter is selected
  final Function(int)? onChapterSelected;

  /// Whether to show chapter details
  final bool showDetails;

  /// Whether to show chapter statistics
  final bool showStatistics;

  /// Current reading theme
  final ReadingTheme theme;

  const ChapterList({
    super.key,
    required this.book,
    required this.currentChapterIndex,
    this.onChapterSelected,
    this.showDetails = true,
    this.showStatistics = true,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: theme.backgroundColor,
      child: Column(
        children: [
          // Header
          _buildHeader(),

          // Divider
          Container(height: 1.0, color: theme.dividerColor),

          // Chapter list
          Expanded(child: _buildChapterList()),
        ],
      ),
    );
  }

  /// Builds the header
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          // Title
          Expanded(
            child: Text(
              'Chapters (${book.chapters.length})',
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

  /// Builds the chapter list
  Widget _buildChapterList() {
    if (book.chapters.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      itemCount: book.chapters.length,
      itemBuilder: (context, index) {
        final chapter = book.chapters[index];
        return _buildChapterItem(chapter, index);
      },
    );
  }

  /// Builds a chapter item
  Widget _buildChapterItem(EpubChapter chapter, int index) {
    final isCurrentChapter = index == currentChapterIndex;

    return Container(
      margin: EdgeInsets.only(left: chapter.level * 16.0, bottom: 8.0),
      child: Card(
        color: isCurrentChapter
            ? theme.accentColor.withOpacity(0.1)
            : theme.backgroundColor,
        elevation: isCurrentChapter ? 2.0 : 1.0,
        child: ListTile(
          contentPadding: const EdgeInsets.all(16.0),
          leading: _buildChapterLeading(chapter, index, isCurrentChapter),
          title: _buildChapterTitle(chapter, isCurrentChapter),
          subtitle: showDetails ? _buildChapterSubtitle(chapter) : null,
          trailing: showStatistics ? _buildChapterTrailing(chapter) : null,
          onTap: () {
            onChapterSelected?.call(index);
          },
        ),
      ),
    );
  }

  /// Builds the chapter leading widget
  Widget _buildChapterLeading(
    EpubChapter chapter,
    int index,
    bool isCurrentChapter,
  ) {
    return Container(
      width: 40.0,
      height: 40.0,
      decoration: BoxDecoration(
        color: isCurrentChapter
            ? theme.accentColor
            : theme.secondaryTextColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Center(
        child: Text(
          '${index + 1}',
          style: TextStyle(
            color: isCurrentChapter ? theme.backgroundColor : theme.textColor,
            fontWeight: FontWeight.bold,
            fontSize: 16.0,
          ),
        ),
      ),
    );
  }

  /// Builds the chapter title
  Widget _buildChapterTitle(EpubChapter chapter, bool isCurrentChapter) {
    return Text(
      chapter.title,
      style: TextStyle(
        color: isCurrentChapter ? theme.accentColor : theme.textColor,
        fontWeight: isCurrentChapter ? FontWeight.bold : FontWeight.normal,
        fontSize: 16.0,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  /// Builds the chapter subtitle
  Widget _buildChapterSubtitle(EpubChapter chapter) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (chapter.isNested)
          Text(
            'Sub-chapter of ${chapter.parentId}',
            style: TextStyle(
              color: theme.secondaryTextColor,
              fontSize: 12.0,
              fontStyle: FontStyle.italic,
            ),
          ),
        if (chapter.hasChildren)
          Text(
            '${chapter.childrenIds.length} sub-chapters',
            style: TextStyle(color: theme.secondaryTextColor, fontSize: 12.0),
          ),
        if (chapter.anchors.isNotEmpty)
          Text(
            '${chapter.anchors.length} anchor points',
            style: TextStyle(color: theme.secondaryTextColor, fontSize: 12.0),
          ),
      ],
    );
  }

  /// Builds the chapter trailing widget
  Widget _buildChapterTrailing(EpubChapter chapter) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Word count
        Text(
          '${chapter.wordCount} words',
          style: TextStyle(color: theme.secondaryTextColor, fontSize: 12.0),
        ),

        // Reading time
        Text(
          '~${chapter.estimatedReadingTime} min',
          style: TextStyle(color: theme.secondaryTextColor, fontSize: 12.0),
        ),

        // Level indicator
        if (chapter.level > 0)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
            decoration: BoxDecoration(
              color: theme.dividerColor,
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Text(
              'L${chapter.level}',
              style: TextStyle(
                color: theme.textColor,
                fontSize: 10.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
      ],
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
            'No chapters available',
            style: TextStyle(color: theme.secondaryTextColor, fontSize: 16.0),
          ),
          const SizedBox(height: 8.0),
          Text(
            'This book doesn\'t have any chapters defined.',
            style: TextStyle(color: theme.secondaryTextColor, fontSize: 14.0),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
