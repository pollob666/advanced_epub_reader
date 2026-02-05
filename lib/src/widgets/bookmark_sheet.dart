import 'dart:ui';
import 'package:flutter/material.dart';
import '../utils/reading_theme.dart';
import '../utils/theme_manager.dart';

class BookmarkSheet extends StatefulWidget {
  final String selectedText;
  final void Function(String? title) onSave;

  const BookmarkSheet({
    super.key,
    required this.selectedText,
    required this.onSave,
  });

  @override
  State<BookmarkSheet> createState() => _BookmarkSheetState();
}

class _BookmarkSheetState extends State<BookmarkSheet> {
  late TextEditingController _titleController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  String get title => _titleController.text.trim();

  /// Get a better accent color for the current theme
  Color _getBetterAccentColor(ReadingTheme theme) {
    if (theme.name.toLowerCase().contains('dark')) {
      return Colors.orange.shade400;
    }
    if (theme.name.toLowerCase().contains('high contrast')) {
      return Colors.yellow;
    }
    if (theme.name.toLowerCase().contains('sepia')) {
      return const Color(0xFF8D6E63);
    }
    if (theme.name.toLowerCase().contains('green')) {
      return const Color(0xFF4CAF50);
    }
    if (theme.name.toLowerCase().contains('purple')) {
      return const Color(0xFF9C27B0);
    }
    if (theme.name.toLowerCase().contains('orange')) {
      return const Color(0xFFFF9800);
    }
    if (theme.name.toLowerCase().contains('blue light')) {
      return const Color(0xFF16213E);
    }
    return theme.accentColor;
  }

  /// Get better background color for dark themes to create separation
  Color _getSheetBackgroundColor(ReadingTheme theme) {
    if (theme.name.toLowerCase().contains('dark')) {
      return Color.lerp(theme.backgroundColor, Colors.white, 0.05) ??
          theme.backgroundColor;
    }
    if (theme.name.toLowerCase().contains('high contrast')) {
      return Color.lerp(theme.backgroundColor, Colors.grey.shade800, 0.1) ??
          theme.backgroundColor;
    }
    return theme.backgroundColor;
  }

  /// Get better shadow color for dark themes
  Color _getShadowColor(ReadingTheme theme) {
    if (theme.name.toLowerCase().contains('dark') ||
        theme.name.toLowerCase().contains('high contrast')) {
      return Colors.white.withOpacity(0.1);
    }
    return Colors.black.withOpacity(0.1);
  }

  /// Get better drag handle color for visibility
  Color _getDragHandleColor(ReadingTheme theme) {
    if (theme.name.toLowerCase().contains('dark')) {
      return Colors.grey.shade400;
    }
    if (theme.name.toLowerCase().contains('high contrast')) {
      return Colors.white;
    }
    if (theme.name.toLowerCase().contains('sepia')) {
      return const Color(0xFF5D4037);
    }
    if (theme.name.toLowerCase().contains('green')) {
      return const Color(0xFF2E7D32);
    }
    if (theme.name.toLowerCase().contains('purple')) {
      return const Color(0xFF4A148C);
    }
    if (theme.name.toLowerCase().contains('orange')) {
      return const Color(0xFFE65100);
    }
    if (theme.name.toLowerCase().contains('blue light')) {
      return const Color(0xFF1A1A2E);
    }
    return Colors.grey.shade600;
  }

  @override
  Widget build(BuildContext context) {
    final ReadingTheme rtheme = ThemeManager.getCurrentTheme();
    final Color betterAccentColor = _getBetterAccentColor(rtheme);
    final Color sheetBackgroundColor = _getSheetBackgroundColor(rtheme);
    final Color shadowColor = _getShadowColor(rtheme);
    final Color dragHandleColor = _getDragHandleColor(rtheme);

    return DraggableScrollableSheet(
      initialChildSize: 0.4,
      minChildSize: 0.25,
      maxChildSize: 0.75,
      builder: (context, scrollController) {
        return ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          child: BackdropFilter(
            filter:
                rtheme.name.toLowerCase().contains('dark') ||
                    rtheme.name.toLowerCase().contains('high contrast')
                ? ImageFilter.blur(sigmaX: 10, sigmaY: 10)
                : ImageFilter.blur(sigmaX: 0, sigmaY: 0),
            child: Container(
              decoration: BoxDecoration(
                color: sheetBackgroundColor.withOpacity(0.95),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                border: Border.all(
                  color: rtheme.dividerColor.withOpacity(0.3),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: shadowColor,
                    blurRadius: 15,
                    offset: const Offset(0, -3),
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  children: [
                    // Drag handle
                    Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: dragHandleColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    // Content
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header with title and close button
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'Add Bookmark',
                                    style: TextStyle(
                                      color: rtheme.textColor,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(
                                    Icons.close,
                                    color: rtheme.secondaryTextColor,
                                  ),
                                  onPressed: () => Navigator.pop(context),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Selected text preview
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: rtheme.selectionColor.withOpacity(0.25),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                widget.selectedText,
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: rtheme.secondaryTextColor,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Title input field
                            Container(
                              decoration: BoxDecoration(
                                color: sheetBackgroundColor,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: rtheme.dividerColor,
                                  width: 1,
                                ),
                              ),
                              child: TextField(
                                controller: _titleController,
                                style: TextStyle(
                                  color: rtheme.textColor,
                                  fontSize: 16,
                                ),
                                decoration: InputDecoration(
                                  labelText: 'Optional title',
                                  labelStyle: TextStyle(
                                    color: rtheme.secondaryTextColor,
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 14,
                                  ),
                                  prefixIcon: Icon(
                                    Icons.title,
                                    color: rtheme.secondaryTextColor,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Save button
                            Container(
                              height: 44,
                              decoration: BoxDecoration(
                                color: betterAccentColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: betterAccentColor,
                                  width: 1,
                                ),
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(10),
                                  onTap: () => widget.onSave(title),
                                  child: Center(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.bookmark_add_outlined,
                                          color: betterAccentColor,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Save Bookmark',
                                          style: TextStyle(
                                            color: betterAccentColor,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
