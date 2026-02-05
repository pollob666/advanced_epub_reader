import 'package:flutter/material.dart';
import '../utils/reading_theme.dart';
// removed unused imports after fullscreen and sheets cleanup
import 'theme_sheet.dart';
import 'typography_sheet.dart';
import '../services/page_calculation_service.dart';
import 'page_jump_sheet.dart';
import 'search_sheet.dart';
import '../services/search_controller.dart';

/// Widget for reading controls (navigation, theme toggle, etc.)
class ReadingControls extends StatelessWidget {
  /// Current chapter index
  final int currentChapterIndex;

  /// Total number of chapters
  final int totalChapters;

  /// Current position within the chapter (0.0 to 1.0)
  final double currentPosition;

  /// Current page across the entire book
  final int currentBookPage;

  /// Total pages in the entire book
  final int totalBookPages;

  /// ValueNotifier for reactive page updates
  final ValueNotifier<int>? pageNotifier;

  /// Callback when previous chapter is requested
  final VoidCallback? onPreviousChapter;

  /// Callback when next chapter is requested
  final VoidCallback? onNextChapter;

  /// Callback when table of contents is toggled
  final VoidCallback? onToggleTableOfContents;

  /// Callback when user selects a book page to jump to
  final ValueChanged<int>? onGoToPage;

  // Fullscreen removed

  /// Current reading theme
  final ReadingTheme theme;

  /// Search controller for built-in search functionality
  final EpubSearchController? searchController;

  /// Callback when bookmarks button is tapped
  final VoidCallback? onShowBookmarks;

  /// Callback when notes button is tapped
  final VoidCallback? onShowNotes;

  const ReadingControls({
    super.key,
    required this.currentChapterIndex,
    required this.totalChapters,
    required this.currentPosition,
    required this.currentBookPage,
    required this.totalBookPages,
    this.onPreviousChapter,
    this.onNextChapter,
    this.onToggleTableOfContents,
    this.onGoToPage,

    this.pageNotifier,
    required this.theme,
    this.searchController,
    this.onShowBookmarks,
    this.onShowNotes,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      padding: const EdgeInsets.only(top: 24.0),
      decoration: BoxDecoration(
        color: theme.backgroundColor,
        border: Border(top: BorderSide(color: theme.dividerColor, width: 0.5)),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor,
            blurRadius: 4.0,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: SafeArea(
        top: false, // Disable top SafeArea to avoid extra space
        bottom: true,
        child: Column(
          mainAxisSize: MainAxisSize.min, // Ensure Column takes minimum height
          children: [
            // Top row: Page info centered with navigation arrows on sides
            Row(
              children: [
                // Left navigation arrow
                IconButton(
                  icon: Icon(
                    Icons.chevron_left,
                    color: currentChapterIndex > 0
                        ? theme.textColor
                        : theme.secondaryTextColor.withOpacity(0.5),
                    size: 26.0,
                  ),
                  onPressed: currentChapterIndex > 0 ? onPreviousChapter : null,
                  tooltip: 'Previous Chapter',
                  style: IconButton.styleFrom(minimumSize: const Size(40, 40)),
                ),
                // Spacer to push page info to center
                const Spacer(),
                // Page info (centered)
                _buildPageInfo(),
                // Spacer to push right navigation to right
                const Spacer(),
                // Right navigation arrow
                IconButton(
                  icon: Icon(
                    Icons.chevron_right,
                    color: currentChapterIndex < totalChapters - 1
                        ? theme.textColor
                        : theme.secondaryTextColor.withOpacity(0.5),
                    size: 26.0,
                  ),
                  onPressed: currentChapterIndex < totalChapters - 1
                      ? onNextChapter
                      : null,
                  tooltip: 'Next Chapter',
                  style: IconButton.styleFrom(
                    padding: const EdgeInsets.all(6.0),
                    minimumSize: const Size(40, 40),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            // Bottom row: Individual buttons for each section
            _buildBottomBar(context),
          ],
        ),
      ),
    );
  }

  /// Builds the page information display
  Widget _buildPageInfo() {
    debugPrint('[ReadingControls] _buildPageInfo: Building page info display');
    debugPrint(
      '[ReadingControls] _buildPageInfo: currentBookPage = $currentBookPage',
    );
    debugPrint(
      '[ReadingControls] _buildPageInfo: totalBookPages = $totalBookPages',
    );
    debugPrint(
      '[ReadingControls] _buildPageInfo: pageNotifier?.value = ${pageNotifier?.value}',
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Chapter progress text
        Text(
          'Chapter ${currentChapterIndex + 1} of $totalChapters',
          style: TextStyle(
            color: theme.secondaryTextColor,
            fontSize: 12.0,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4.0),
        // Book page progress - reactive to page changes
        pageNotifier != null
            ? ValueListenableBuilder<int>(
                valueListenable: pageNotifier!,
                builder: (context, currentPage, child) {
                  debugPrint(
                    '[ReadingControls] ValueListenableBuilder: currentPage = $currentPage',
                  );
                  return Text(
                    'Page ${PageCalculationService.formatPageDisplay(currentPage, totalBookPages)}',
                    style: TextStyle(
                      color: theme.textColor,
                      fontSize: 16.0,
                      fontWeight: FontWeight.w600,
                    ),
                  );
                },
              )
            : Text(
                'Page ${PageCalculationService.formatPageDisplay(currentBookPage, totalBookPages)}',
                style: TextStyle(
                  color: theme.textColor,
                  fontSize: 16.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ],
    );
  }

  /// Builds the bottom bar with individual buttons
  Widget _buildBottomBar(BuildContext context) {
    debugPrint('[ReadingControls] _buildBottomBar: Building bottom bar');
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildBottomBarButton(
          context,
          icon: Icons.palette,
          title: 'Theme',
          onTap: () => _showThemeSheet(context),
        ),
        _buildBottomBarButton(
          context,
          icon: Icons.manage_search,
          title: 'Search',
          onTap: () {
            if (searchController != null) {
              _showSearchSheet(context);
            }
          },
        ),
        _buildBottomBarButton(
          context,
          icon: Icons.navigation,
          title: 'Jump',
          onTap: () => _showPageJumpSheet(context),
        ),
        _buildBottomBarButton(
          context,
          icon: Icons.text_fields,
          title: 'Typography',
          onTap: () => _showTypographySheet(context),
        ),
        _buildBottomBarButton(
          context,
          icon: Icons.bookmark_outline,
          title: 'Bookmarks',
          onTap: onShowBookmarks ?? () {},
        ),
        _buildBottomBarButton(
          context,
          icon: Icons.note_alt,
          title: 'Notes',
          onTap: onShowNotes ?? () {},
        ),
        _buildBottomBarButton(
          context,
          icon: Icons.list,
          title: 'Chapters',
          onTap: onToggleTableOfContents ?? () {},
        ),
        // Removed fullscreen toggle button
      ],
    );
  }

  Widget _buildBottomBarButton(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min, // Ensure Column wraps content
      children: [
        IconButton(
          icon: Icon(icon, color: theme.textColor, size: 20.0),
          onPressed: onTap,
          tooltip: title,
          style: IconButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: const Size(36, 36),
            backgroundColor: theme.backgroundColor,
            foregroundColor: theme.textColor,
          ),
        ),
        Text(
          title,
          style: TextStyle(
            color: theme.secondaryTextColor,
            fontSize: 8.0,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // Sheet methods for each section
  void _showThemeSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => ThemeSheet(theme: theme),
    );
  }

  void _showTypographySheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => TypographySheet(theme: theme),
    );
  }

  void _showPageJumpSheet(BuildContext context) {
    final currentPage = pageNotifier?.value ?? currentBookPage;
    debugPrint(
      '[ReadingControls] _showPageJumpSheet: pageNotifier?.value = ${pageNotifier?.value}',
    );
    debugPrint(
      '[ReadingControls] _showPageJumpSheet: currentBookPage = $currentBookPage',
    );
    debugPrint(
      '[ReadingControls] _showPageJumpSheet: Final currentPage = $currentPage',
    );

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => PageJumpSheet(
        currentPageNotifier: pageNotifier ?? ValueNotifier(currentBookPage),
        totalPages: totalBookPages,
        theme: theme,
        onPageSelected: (page) {
          onGoToPage?.call(page);
        },
      ),
    );
  }

  void _showSearchSheet(BuildContext context) {
    if (searchController != null) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (ctx) => SearchSheet(controller: searchController!),
      );
    }
  }

  // Fullscreen helpers removed
}
