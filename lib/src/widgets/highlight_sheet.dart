import 'dart:ui';
import 'package:flutter/material.dart';
import '../utils/reading_theme.dart';
import '../utils/theme_manager.dart';
import 'custom_color_picker.dart';

class HighlightSheet extends StatefulWidget {
  final String selectedText;
  final ValueChanged<Color> onColorSelected;

  const HighlightSheet({
    super.key,
    required this.selectedText,
    required this.onColorSelected,
  });

  @override
  State<HighlightSheet> createState() => _HighlightSheetState();
}

class _HighlightSheetState extends State<HighlightSheet> {
  int? _selectedIndex;

  void _applyColorAndClose(Color color) {
    debugPrint('[HighlightSheet] Applying color from sheet: $color');
    widget.onColorSelected(color);
    Navigator.pop(context);
  }

  /// Get vibrant, visible highlight colors
  List<Color> _getHighlightColors() {
    return [
      const Color(0xFFFDD835), // Bright Yellow
      const Color(0xFFFF7043), // Deep Orange
      const Color(0xFFEC407A), // Pink
      const Color(0xFF66BB6A), // Green
      const Color(0xFF42A5F5), // Blue
      const Color(0xFFAB47BC), // Purple
      const Color(0xFF26C6DA), // Cyan
      const Color(0xFF9CCC65), // Light Green
    ];
  }

  /// Get better background color for dark themes to create separation
  Color _getSheetBackgroundColor(ReadingTheme theme) {
    if (theme.name.toLowerCase().contains('dark')) {
      // For dark themes, use a slightly lighter background
      return Color.lerp(theme.backgroundColor, Colors.white, 0.05) ??
          theme.backgroundColor;
    }
    if (theme.name.toLowerCase().contains('high contrast')) {
      // For high contrast, use a slightly different shade
      return Color.lerp(theme.backgroundColor, Colors.grey.shade800, 0.1) ??
          theme.backgroundColor;
    }
    // For other themes, use the theme background
    return theme.backgroundColor;
  }

  /// Get better shadow color for dark themes
  Color _getShadowColor(ReadingTheme theme) {
    if (theme.name.toLowerCase().contains('dark') ||
        theme.name.toLowerCase().contains('high contrast')) {
      return Colors.white.withOpacity(0.1); // White shadow for dark themes
    }
    return Colors.black.withOpacity(0.1); // Black shadow for light themes
  }

  /// Get better drag handle color for visibility
  Color _getDragHandleColor(ReadingTheme theme) {
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

  @override
  Widget build(BuildContext context) {
    final ReadingTheme theme = ThemeManager.getCurrentTheme();
    final colors = _getHighlightColors();
    final sheetBackgroundColor = _getSheetBackgroundColor(theme);
    final shadowColor = _getShadowColor(theme);
    final dragHandleColor = _getDragHandleColor(theme);

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          child: BackdropFilter(
            filter:
                theme.name.toLowerCase().contains('dark') ||
                    theme.name.toLowerCase().contains('high contrast')
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
                  color: theme.dividerColor.withOpacity(0.3),
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

                    // Header (centered, consistent across sheets)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                      child: Center(
                        child: Text(
                          'Choose highlight color',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: theme.textColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),

                    // Scrollable content
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            const SizedBox(height: 32),

                            // Color selection
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                              ),
                              child: GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 4,
                                      crossAxisSpacing: 24,
                                      mainAxisSpacing: 24,
                                      childAspectRatio: 1,
                                    ),
                                itemCount: colors.length,
                                itemBuilder: (context, index) {
                                  final color = colors[index];
                                  final isSelected = _selectedIndex == index;

                                  return GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _selectedIndex = index;
                                      });

                                      // Add slight delay for visual feedback
                                      Future.delayed(
                                        const Duration(milliseconds: 150),
                                        () {
                                          _applyColorAndClose(color);
                                        },
                                      );
                                    },
                                    child: AnimatedScale(
                                      scale: isSelected ? 1.1 : 1.0,
                                      duration: const Duration(
                                        milliseconds: 150,
                                      ),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: color.withOpacity(0.4),
                                              blurRadius: isSelected ? 16 : 10,
                                              offset: const Offset(0, 6),
                                              spreadRadius: isSelected ? 3 : 1,
                                            ),
                                          ],
                                        ),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: color,
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color:
                                                  theme.backgroundColor
                                                          .computeLuminance() <
                                                      0.5
                                                  ? Colors.white.withOpacity(
                                                      0.9,
                                                    )
                                                  : Colors.white,
                                              width: isSelected ? 3 : 2.5,
                                            ),
                                          ),
                                          child: isSelected
                                              ? Icon(
                                                  Icons.check,
                                                  color:
                                                      theme.backgroundColor
                                                              .computeLuminance() <
                                                          0.5
                                                      ? Colors.white
                                                      : Colors.white,
                                                  size: 26,
                                                )
                                              : null,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),

                            const SizedBox(height: 24),

                            // Custom color picker
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.palette_outlined,
                                        size: 18,
                                        color: theme.secondaryTextColor,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Custom color picker',
                                        style: TextStyle(
                                          color: theme.secondaryTextColor,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Adjust hue with the bar, then fine‑tune tone in the square. Tap Apply to use.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: theme.secondaryTextColor
                                          .withOpacity(0.8),
                                      fontSize: 12,
                                      height: 1.3,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  const SizedBox(height: 14),
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: theme.backgroundColor.withOpacity(
                                        0.6,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: theme.dividerColor.withOpacity(
                                          0.35,
                                        ),
                                        width: 1,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: theme.shadowColor.withOpacity(
                                            0.06,
                                          ),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: CustomColorPicker(
                                      initialColor: Colors.red,
                                      onColorChanged: (color) {
                                        debugPrint(
                                          '[HighlightSheet] CustomColorPicker onApply tapped with color: $color',
                                        );
                                        _applyColorAndClose(color);
                                      },
                                      theme: theme,
                                      autoApply: false,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 24),

                            // Selected text preview
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    'Selected Text:',
                                    style: TextStyle(
                                      color: theme.secondaryTextColor,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    widget.selectedText,
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: theme.textColor,
                                      fontSize: 14,
                                      height: 1.4,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 32),
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
