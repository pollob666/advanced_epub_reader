import 'dart:ui';
import 'package:flutter/material.dart';
import '../utils/reading_theme.dart';
import '../utils/theme_manager.dart';
import '../services/search_controller.dart';
import 'search_highlight_preview.dart';

class SearchSheet extends StatelessWidget {
  final EpubSearchController controller;

  const SearchSheet({super.key, required this.controller});

  /// Get a better accent color for the current theme
  Color _getBetterAccentColor(ReadingTheme theme) {
    // For dark themes, use a more appropriate accent color
    if (theme.name.toLowerCase().contains('dark')) {
      return Colors.orange.shade400; // Better for dark themes
    }
    if (theme.name.toLowerCase().contains('high contrast')) {
      return Colors.yellow; // High contrast yellow
    }
    if (theme.name.toLowerCase().contains('sepia')) {
      return const Color(0xFF8D6E63); // Brown for sepia
    }
    if (theme.name.toLowerCase().contains('green')) {
      return const Color(0xFF4CAF50); // Green theme accent
    }
    if (theme.name.toLowerCase().contains('purple')) {
      return const Color(0xFF9C27B0); // Purple theme accent
    }
    if (theme.name.toLowerCase().contains('orange')) {
      return const Color(0xFFFF9800); // Orange theme accent
    }
    if (theme.name.toLowerCase().contains('blue light')) {
      return const Color(0xFF16213E); // Blue light theme accent
    }
    // Default to theme accent for light theme
    return theme.accentColor;
  }

  @override
  Widget build(BuildContext context) {
    final ReadingTheme rtheme = ThemeManager.getCurrentTheme();
    final Color betterAccentColor = _getBetterAccentColor(rtheme);
    final TextEditingController textController = TextEditingController(
      text: controller.query.value,
    );

    // Set up the close callback
    controller.requestClosePanel = () {
      controller.clear();
      if (Navigator.of(context).canPop()) Navigator.of(context).pop();
    };

    // Get better background color for dark themes to create separation
    Color getSheetBackgroundColor() {
      if (rtheme.name.toLowerCase().contains('dark')) {
        // For dark themes, use a slightly lighter background
        return Color.lerp(rtheme.backgroundColor, Colors.white, 0.05) ??
            rtheme.backgroundColor;
      }
      if (rtheme.name.toLowerCase().contains('high contrast')) {
        // For high contrast, use a slightly different shade
        return Color.lerp(rtheme.backgroundColor, Colors.grey.shade800, 0.1) ??
            rtheme.backgroundColor;
      }
      // For other themes, use the theme background
      return rtheme.backgroundColor;
    }

    // Get better shadow color for dark themes
    Color getShadowColor() {
      if (rtheme.name.toLowerCase().contains('dark') ||
          rtheme.name.toLowerCase().contains('high contrast')) {
        return Colors.white.withOpacity(0.1); // White shadow for dark themes
      }
      return Colors.black.withOpacity(0.1); // Black shadow for light themes
    }

    // Get better drag handle color for visibility
    Color getDragHandleColor(ReadingTheme theme) {
      if (theme.name.toLowerCase().contains('dark')) {
        // For dark themes, use a lighter color for better contrast
        return Colors.grey.shade400;
      }
      if (theme.name.toLowerCase().contains('high contrast')) {
        // For high contrast, use white for maximum visibility
        return Colors.white;
      }
      if (theme.name.toLowerCase().contains('sepia')) {
        // For sepia, use a darker brown
        return const Color(0xFF5D4037);
      }
      if (theme.name.toLowerCase().contains('green')) {
        // For green theme, use a darker green
        return const Color(0xFF2E7D32);
      }
      if (theme.name.toLowerCase().contains('purple')) {
        // For purple theme, use a darker purple
        return const Color(0xFF4A148C);
      }
      if (theme.name.toLowerCase().contains('orange')) {
        // For orange theme, use a darker orange
        return const Color(0xFFE65100);
      }
      if (theme.name.toLowerCase().contains('blue light')) {
        // For blue light theme, use a darker blue
        return const Color(0xFF1A1A2E);
      }
      // For light theme, use a darker color
      return Colors.grey.shade600;
    }

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
                color: getSheetBackgroundColor().withOpacity(0.95),
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
                    color: getShadowColor(),
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
                        color: getDragHandleColor(rtheme),
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
                                    'Search in Book',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.copyWith(
                                          color: rtheme.textColor,
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Search input field
                            Container(
                              decoration: BoxDecoration(
                                color: rtheme.backgroundColor,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: rtheme.dividerColor,
                                  width: 1,
                                ),
                              ),
                              child: TextField(
                                controller: textController,
                                style: TextStyle(
                                  color: rtheme.textColor,
                                  fontSize: 16,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'Search in book...',
                                  hintStyle: TextStyle(
                                    color: rtheme.secondaryTextColor,
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 14,
                                  ),
                                  prefixIcon: Icon(
                                    Icons.search,
                                    color: rtheme.secondaryTextColor,
                                    size: 20,
                                  ),
                                  suffixIcon: controller.query.value.isNotEmpty
                                      ? IconButton(
                                          icon: Icon(
                                            Icons.clear,
                                            color: rtheme.secondaryTextColor,
                                            size: 20,
                                          ),
                                          onPressed: () {
                                            textController.clear();
                                            controller.clear();
                                          },
                                        )
                                      : null,
                                ),
                                onSubmitted: (v) {
                                  if (v.trim().length >= 2) {
                                    controller.setQuery(v);
                                  }
                                },
                                onChanged: (v) {
                                  if (v.trim().length >= 2) {
                                    controller.setQuery(v);
                                  } else if (v.trim().isEmpty) {
                                    controller.clear();
                                  }
                                },
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Navigation buttons
                            ValueListenableBuilder<List<EpubSearchMatch>>(
                              valueListenable: controller.results,
                              builder: (context, hits, _) {
                                return ValueListenableBuilder<int>(
                                  valueListenable: controller.currentIndex,
                                  builder: (context, currentIndex, _) {
                                    final totalResults = hits.length;
                                    final currentResult = currentIndex + 1;

                                    return Row(
                                      children: [
                                        Expanded(
                                          child: Container(
                                            height: 44,
                                            decoration: BoxDecoration(
                                              color: totalResults > 0
                                                  ? betterAccentColor
                                                        .withOpacity(0.1)
                                                  : rtheme.backgroundColor,
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              border: Border.all(
                                                color: totalResults > 0
                                                    ? betterAccentColor
                                                    : rtheme.dividerColor,
                                                width: 1,
                                              ),
                                            ),
                                            child: Material(
                                              color: Colors.transparent,
                                              child: InkWell(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                onTap: totalResults > 0
                                                    ? controller.previous
                                                    : null,
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Icon(
                                                      Icons.keyboard_arrow_up,
                                                      color: totalResults > 0
                                                          ? betterAccentColor
                                                          : rtheme
                                                                .secondaryTextColor,
                                                      size: 20,
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Text(
                                                      'Previous',
                                                      style: TextStyle(
                                                        color: totalResults > 0
                                                            ? betterAccentColor
                                                            : rtheme
                                                                  .secondaryTextColor,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        // Results counter
                                        Container(
                                          height: 44,
                                          child: Center(
                                            child: Text(
                                              totalResults > 0
                                                  ? '$currentResult of $totalResults'
                                                  : '0 of 0',
                                              style: TextStyle(
                                                color: rtheme.textColor,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Container(
                                            height: 44,
                                            decoration: BoxDecoration(
                                              color: totalResults > 0
                                                  ? betterAccentColor
                                                        .withOpacity(0.1)
                                                  : rtheme.backgroundColor,
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              border: Border.all(
                                                color: totalResults > 0
                                                    ? betterAccentColor
                                                    : rtheme.dividerColor,
                                                width: 1,
                                              ),
                                            ),
                                            child: Material(
                                              color: Colors.transparent,
                                              child: InkWell(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                onTap: totalResults > 0
                                                    ? controller.next
                                                    : null,
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Icon(
                                                      Icons.keyboard_arrow_down,
                                                      color: totalResults > 0
                                                          ? betterAccentColor
                                                          : rtheme
                                                                .secondaryTextColor,
                                                      size: 20,
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Text(
                                                      'Next',
                                                      style: TextStyle(
                                                        color: totalResults > 0
                                                            ? betterAccentColor
                                                            : rtheme
                                                                  .secondaryTextColor,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                            ),
                            const SizedBox(height: 12),

                            // Results list
                            Expanded(
                              child: ValueListenableBuilder<List<EpubSearchMatch>>(
                                valueListenable: controller.results,
                                builder: (context, hits, _) {
                                  return ValueListenableBuilder<int>(
                                    valueListenable: controller.currentIndex,
                                    builder: (context, currentIndex, _) {
                                      if (hits.isEmpty) {
                                        return Center(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.search_off,
                                                size: 48,
                                                color:
                                                    rtheme.secondaryTextColor,
                                              ),
                                              const SizedBox(height: 16),
                                              Text(
                                                controller.query.value
                                                            .trim()
                                                            .length <
                                                        2
                                                    ? 'Enter at least 2 characters'
                                                    : 'No results found',
                                                style: TextStyle(
                                                  color: rtheme.textColor,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                controller.query.value
                                                            .trim()
                                                            .length <
                                                        2
                                                    ? 'Start typing to search'
                                                    : 'Try a different search term',
                                                style: TextStyle(
                                                  color:
                                                      rtheme.secondaryTextColor,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      }

                                      final q = controller.query.value.trim();
                                      if (q.length < 2) {
                                        return const SizedBox.shrink();
                                      }
                                      return ListView.builder(
                                        controller: scrollController,
                                        itemCount: hits.length,
                                        padding: const EdgeInsets.only(
                                          bottom: 16,
                                        ),
                                        shrinkWrap: true,
                                        itemBuilder: (context, index) {
                                          final h = hits[index];
                                          final isCurrentResult =
                                              index == currentIndex;
                                          return Container(
                                            margin: const EdgeInsets.only(
                                              bottom: 8,
                                            ),
                                            decoration: BoxDecoration(
                                              color: isCurrentResult
                                                  ? betterAccentColor
                                                        .withOpacity(0.1)
                                                  : rtheme.backgroundColor,
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              border: Border.all(
                                                color: isCurrentResult
                                                    ? betterAccentColor
                                                    : rtheme.dividerColor,
                                                width: isCurrentResult ? 2 : 1,
                                              ),
                                            ),
                                            child: Material(
                                              color: Colors.transparent,
                                              child: InkWell(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                onTap: () {
                                                  controller
                                                          .currentIndex
                                                          .value =
                                                      index;
                                                  controller.onNavigateToMatch
                                                      ?.call(h);
                                                  Navigator.pop(context);
                                                },
                                                child: Padding(
                                                  padding: const EdgeInsets.all(
                                                    16,
                                                  ),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Row(
                                                        children: [
                                                          Container(
                                                            padding:
                                                                const EdgeInsets.symmetric(
                                                                  horizontal: 8,
                                                                  vertical: 4,
                                                                ),
                                                            decoration: BoxDecoration(
                                                              color: rtheme
                                                                  .accentColor
                                                                  .withOpacity(
                                                                    0.1,
                                                                  ),
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                    6,
                                                                  ),
                                                            ),
                                                            child: Text(
                                                              'Chapter ${h.chapterIndex + 1}',
                                                              style: TextStyle(
                                                                color: rtheme
                                                                    .accentColor,
                                                                fontSize: 12,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                              ),
                                                            ),
                                                          ),
                                                          const Spacer(),
                                                          Icon(
                                                            Icons
                                                                .arrow_forward_ios,
                                                            size: 14,
                                                            color: rtheme
                                                                .secondaryTextColor,
                                                          ),
                                                        ],
                                                      ),
                                                      const SizedBox(height: 8),
                                                      SizedBox(
                                                        height: 80,
                                                        child:
                                                            SearchHighlightedPreview(
                                                              text:
                                                                  h.previewText,
                                                              query: q,
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
                                    },
                                  );
                                },
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
