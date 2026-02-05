import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/reading_theme.dart';
import '../utils/theme_manager.dart';
import '../models/epub_book.dart';

class ChaptersSheet extends StatefulWidget {
  final EpubBook book;
  final ValueChanged<int> onChapterSelected;
  final int? currentChapterIndex;

  const ChaptersSheet({
    super.key,
    required this.book,
    required this.onChapterSelected,
    this.currentChapterIndex,
  });

  @override
  State<ChaptersSheet> createState() => _ChaptersSheetState();
}

class _ChaptersSheetState extends State<ChaptersSheet>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  // Do NOT hold the DraggableScrollableSheet controller; use it inline

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
        );

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ReadingTheme theme = ThemeManager.getCurrentTheme();
    final bool isDark = theme.name.toLowerCase().contains('dark');
    final bool isHighContrast = theme.name.toLowerCase().contains(
      'high contrast',
    );

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: _buildSheetContent(
              theme,
              isDark,
              isHighContrast,
              scrollController,
            ),
          ),
        );
      },
    );
  }

  Widget _buildSheetContent(
    ReadingTheme theme,
    bool isDark,
    bool isHighContrast,
    ScrollController scrollController,
  ) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(24),
        topRight: Radius.circular(24),
      ),
      child: BackdropFilter(
        filter: (isDark || isHighContrast)
            ? ImageFilter.blur(sigmaX: 20, sigmaY: 20)
            : ImageFilter.blur(sigmaX: 0, sigmaY: 0),
        child: Container(
          decoration: BoxDecoration(
            color: _getSheetBackgroundColor(theme, isDark, isHighContrast),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
            border: Border.all(
              color: _getBorderColor(theme, isDark, isHighContrast),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: _getShadowColor(isDark, isHighContrast),
                blurRadius: 20,
                offset: const Offset(0, -5),
                spreadRadius: 0,
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: Column(
              children: [
                _buildDragHandle(theme, isDark, isHighContrast),
                _buildHeader(theme),
                _buildChapterCount(theme),
                Expanded(
                  child: _buildChapterList(
                    theme,
                    isDark,
                    isHighContrast,
                    scrollController,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDragHandle(
    ReadingTheme theme,
    bool isDark,
    bool isHighContrast,
  ) {
    return Container(
      width: 48,
      height: 4,
      margin: const EdgeInsets.only(top: 12, bottom: 8),
      decoration: BoxDecoration(
        color: _getDragHandleColor(theme, isDark, isHighContrast),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildHeader(ReadingTheme theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Table of Contents',
              style: TextStyle(
                color: theme.textColor,
                fontSize: 20,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.2,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: theme.textColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${widget.book.chapters.length} chapters',
              style: TextStyle(
                color: theme.textColor.withOpacity(0.7),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChapterCount(ReadingTheme theme) {
    if (widget.currentChapterIndex == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 4, 24, 8),
      child: Row(
        children: [
          Icon(
            Icons.bookmark_rounded,
            size: 16,
            color: (theme.accentColor).withOpacity(0.9),
          ),
          const SizedBox(width: 6),
          Text(
            'Currently on chapter ${widget.currentChapterIndex! + 1}',
            style: TextStyle(
              color: (theme.accentColor).withOpacity(0.8),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChapterList(
    ReadingTheme theme,
    bool isDark,
    bool isHighContrast,
    ScrollController scrollController,
  ) {
    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      physics: const BouncingScrollPhysics(),
      itemCount: widget.book.chapters.length,
      itemBuilder: (context, index) =>
          _buildChapterTile(theme, index, isDark, isHighContrast),
    );
  }

  Widget _buildChapterTile(
    ReadingTheme theme,
    int index,
    bool isDark,
    bool isHighContrast,
  ) {
    final chapter = widget.book.chapters[index];
    final isCurrentChapter = widget.currentChapterIndex == index;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: isCurrentChapter
            ? (theme.accentColor).withOpacity(0.12)
            : Colors.transparent,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: isCurrentChapter
                ? (theme.accentColor)
                : theme.textColor.withOpacity(0.08),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              '${index + 1}',
              style: TextStyle(
                color: isCurrentChapter
                    ? (isDark ? Colors.black : Colors.white)
                    : theme.textColor.withOpacity(0.6),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        title: Text(
          chapter.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: isCurrentChapter ? (theme.accentColor) : theme.textColor,
            fontSize: 15,
            fontWeight: isCurrentChapter ? FontWeight.w600 : FontWeight.w500,
            height: 1.3,
          ),
        ),
        trailing: isCurrentChapter
            ? Icon(
                Icons.play_circle_filled_rounded,
                color: theme.accentColor,
                size: 20,
              )
            : Icon(
                Icons.chevron_right_rounded,
                color: theme.textColor.withOpacity(0.3),
                size: 20,
              ),
        onTap: () => _onChapterTap(index),
      ),
    );
  }

  void _onChapterTap(int index) {
    // Haptic feedback for better UX
    HapticFeedback.lightImpact();

    // Smooth close animation
    _fadeController.reverse().then((_) {
      Navigator.of(context).pop();
      widget.onChapterSelected(index);
    });
  }

  // Color helper methods
  Color _getSheetBackgroundColor(
    ReadingTheme theme,
    bool isDark,
    bool isHighContrast,
  ) {
    if (isDark) {
      return Color.lerp(theme.backgroundColor, Colors.white, 0.08) ??
          theme.backgroundColor;
    }
    if (isHighContrast) {
      return Color.lerp(theme.backgroundColor, Colors.grey.shade800, 0.1) ??
          theme.backgroundColor;
    }
    return theme.backgroundColor.withOpacity(0.98);
  }

  Color _getBorderColor(ReadingTheme theme, bool isDark, bool isHighContrast) {
    if (isDark) return Colors.white.withOpacity(0.15);
    if (isHighContrast) return theme.dividerColor.withOpacity(0.5);
    return theme.dividerColor.withOpacity(0.2);
  }

  Color _getShadowColor(bool isDark, bool isHighContrast) {
    if (isDark || isHighContrast) {
      return Colors.black.withOpacity(0.3);
    }
    return Colors.black.withOpacity(0.15);
  }

  Color _getDragHandleColor(
    ReadingTheme theme,
    bool isDark,
    bool isHighContrast,
  ) {
    if (isDark) return Colors.grey.shade300;
    if (isHighContrast) return Colors.white;
    return Colors.grey.shade500;
  }
}
