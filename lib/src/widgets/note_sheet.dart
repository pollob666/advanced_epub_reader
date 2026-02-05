import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/reading_theme.dart';
import '../utils/theme_manager.dart';

class NoteSheet extends StatefulWidget {
  final String selectedText;
  final Function(String content, String? color) onSave;

  const NoteSheet({
    super.key,
    required this.selectedText,
    required this.onSave,
  });

  @override
  State<NoteSheet> createState() => _NoteSheetState();
}

class _NoteSheetState extends State<NoteSheet> with TickerProviderStateMixin {
  late TextEditingController _noteController;
  late FocusNode _focusNode;
  late AnimationController _slideController;
  late AnimationController _scaleController;
  late Animation<double> _slideAnimation;
  late Animation<double> _scaleAnimation;

  String? _selectedColor;
  bool _isExpanded = false;

  // Color palette for note highlighting
  final List<Color> _colorPalette = [
    const Color(0xFFFFEB3B), // Yellow
    const Color(0xFFFF9800), // Orange
    const Color(0xFFE91E63), // Pink
    const Color(0xFF9C27B0), // Purple
    const Color(0xFF3F51B5), // Indigo
    const Color(0xFF2196F3), // Blue
    const Color(0xFF00BCD4), // Cyan
    const Color(0xFF4CAF50), // Green
  ];

  @override
  void initState() {
    super.initState();
    _noteController = TextEditingController();
    _focusNode = FocusNode();

    // Initialize animations
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _slideAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
    );

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeOutBack),
    );

    // Start entrance animation
    _slideController.forward();
    _scaleController.forward();
  }

  /// Convert a Color to a canonical hex string '#RRGGBB' (no alpha)
  String _toHexNoAlpha(Color color) {
    final int rgb = color.value & 0x00FFFFFF;
    return '#${rgb.toRadixString(16).padLeft(6, '0').toUpperCase()}';
  }

  @override
  void dispose() {
    _noteController.dispose();
    _focusNode.dispose();
    _slideController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  /// Enhanced accent color logic with better theme support
  Color _getBetterAccentColor(ReadingTheme theme) {
    final themeName = theme.name.toLowerCase();

    if (themeName.contains('dark')) {
      return const Color(0xFFFF8A65);
    }
    if (themeName.contains('high contrast')) {
      return const Color(0xFFFFC107);
    }
    if (themeName.contains('sepia')) {
      return const Color(0xFF8D6E63);
    }
    if (themeName.contains('green')) {
      return const Color(0xFF66BB6A);
    }
    if (themeName.contains('purple')) {
      return const Color(0xFFAB47BC);
    }
    if (themeName.contains('orange')) {
      return const Color(0xFFFF7043);
    }
    if (themeName.contains('blue')) {
      return const Color(0xFF42A5F5);
    }

    return theme.accentColor;
  }

  /// Enhanced background with glassmorphism effect
  Color _getSheetBackgroundColor(ReadingTheme theme) {
    final themeName = theme.name.toLowerCase();

    if (themeName.contains('dark')) {
      return Color.lerp(theme.backgroundColor, Colors.white, 0.08) ??
          theme.backgroundColor;
    }
    if (themeName.contains('high contrast')) {
      return Color.lerp(theme.backgroundColor, Colors.grey.shade700, 0.15) ??
          theme.backgroundColor;
    }

    return Color.lerp(theme.backgroundColor, Colors.white, 0.05) ??
        theme.backgroundColor;
  }

  /// Enhanced shadow for better depth
  List<BoxShadow> _getEnhancedShadows(ReadingTheme theme, Color accentColor) {
    final isDark =
        theme.name.toLowerCase().contains('dark') ||
        theme.name.toLowerCase().contains('high contrast');

    return [
      BoxShadow(
        color: isDark
            ? Colors.white.withOpacity(0.08)
            : Colors.black.withOpacity(0.15),
        blurRadius: 20,
        offset: const Offset(0, -4),
        spreadRadius: 0,
      ),
      BoxShadow(
        color: accentColor.withOpacity(0.1),
        blurRadius: 30,
        offset: const Offset(0, -10),
        spreadRadius: -5,
      ),
    ];
  }

  /// Close sheet with animation
  void _closeSheet() {
    _slideController.reverse().then((_) {
      if (mounted) Navigator.pop(context);
    });
  }

  /// Save note with haptic feedback
  void _saveNote() {
    final content = _noteController.text.trim();
    if (content.isNotEmpty) {
      HapticFeedback.lightImpact();
      widget.onSave(content, _selectedColor);
      _closeSheet();
    }
  }

  /// Toggle expanded state for color picker
  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
    HapticFeedback.selectionClick();
  }

  @override
  Widget build(BuildContext context) {
    final ReadingTheme rtheme = ThemeManager.getCurrentTheme();
    final Color accentColor = _getBetterAccentColor(rtheme);
    final Color backgroundColor = _getSheetBackgroundColor(rtheme);
    final bool isDark = rtheme.name.toLowerCase().contains('dark');

    return AnimatedBuilder(
      animation: _slideAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 50 * (1 - _slideAnimation.value)),
          child: Opacity(opacity: _slideAnimation.value, child: child),
        );
      },
      child: DraggableScrollableSheet(
        initialChildSize: 0.55,
        minChildSize: 0.35,
        maxChildSize: 0.85,
        builder: (context, scrollController) {
          return ScaleTransition(
            scale: _scaleAnimation,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(28),
                  topRight: Radius.circular(28),
                ),
                boxShadow: _getEnhancedShadows(rtheme, accentColor),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(28),
                  topRight: Radius.circular(28),
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(
                    sigmaX: isDark ? 15 : 8,
                    sigmaY: isDark ? 15 : 8,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: backgroundColor.withOpacity(0.92),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(28),
                        topRight: Radius.circular(28),
                      ),
                      border: Border.all(
                        color: accentColor.withOpacity(0.2),
                        width: 1.5,
                      ),
                    ),
                    child: SafeArea(
                      top: false,
                      child: Column(
                        children: [
                          _buildDragHandle(rtheme, accentColor),
                          Expanded(
                            child: SingleChildScrollView(
                              controller: scrollController,
                              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildHeader(rtheme),
                                  const SizedBox(height: 20),
                                  _buildSelectedTextPreview(
                                    rtheme,
                                    accentColor,
                                  ),
                                  const SizedBox(height: 20),
                                  _buildColorPicker(rtheme, accentColor),
                                  const SizedBox(height: 20),
                                  _buildNoteInput(
                                    rtheme,
                                    accentColor,
                                    backgroundColor,
                                  ),
                                  const SizedBox(height: 24),
                                  _buildActionButtons(rtheme, accentColor),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// Enhanced drag handle
  Widget _buildDragHandle(ReadingTheme rtheme, Color accentColor) {
    return Container(
      width: 48,
      height: 5,
      margin: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: accentColor.withOpacity(0.3),
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }

  /// Enhanced header with better typography
  Widget _buildHeader(ReadingTheme rtheme) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: rtheme.selectionColor.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.note_add_outlined,
            color: rtheme.textColor.withOpacity(0.8),
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            'Add Note',
            style: TextStyle(
              color: rtheme.textColor,
              fontWeight: FontWeight.w600,
              fontSize: 20,
              letterSpacing: -0.5,
            ),
          ),
        ),
        IconButton(
          icon: Icon(Icons.close_rounded, color: rtheme.secondaryTextColor),
          onPressed: _closeSheet,
          style: IconButton.styleFrom(
            backgroundColor: rtheme.dividerColor.withOpacity(0.1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }

  /// Enhanced selected text preview with better styling
  Widget _buildSelectedTextPreview(ReadingTheme rtheme, Color accentColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            accentColor.withOpacity(0.08),
            accentColor.withOpacity(0.04),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accentColor.withOpacity(0.15), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.format_quote, color: accentColor, size: 16),
              const SizedBox(width: 6),
              Text(
                'Selected Text',
                style: TextStyle(
                  color: accentColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            widget.selectedText,
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: rtheme.textColor.withOpacity(0.85),
              fontSize: 15,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  /// Color picker section
  Widget _buildColorPicker(ReadingTheme rtheme, Color accentColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: _toggleExpanded,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Icon(Icons.palette_outlined, color: accentColor, size: 18),
                const SizedBox(width: 8),
                Text(
                  'Highlight Color',
                  style: TextStyle(
                    color: rtheme.textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                AnimatedRotation(
                  turns: _isExpanded ? 0.25 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    Icons.chevron_right,
                    color: rtheme.secondaryTextColor,
                  ),
                ),
              ],
            ),
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: _isExpanded
              ? Container(
                  margin: const EdgeInsets.only(top: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: rtheme.backgroundColor.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: rtheme.dividerColor.withOpacity(0.3),
                    ),
                  ),
                  child: Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _buildColorOption(null, Colors.transparent, rtheme),
                      ..._colorPalette.map(
                        (color) => _buildColorOption(
                          _toHexNoAlpha(color),
                          color,
                          rtheme,
                        ),
                      ),
                    ],
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }

  /// Individual color option
  Widget _buildColorOption(
    String? colorValue,
    Color color,
    ReadingTheme rtheme,
  ) {
    final isSelected = _selectedColor == colorValue;
    final isTransparent = colorValue == null;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedColor = colorValue;
        });
        HapticFeedback.selectionClick();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: isTransparent ? rtheme.backgroundColor : color,
          border: Border.all(
            color: isSelected
                ? _getBetterAccentColor(rtheme)
                : rtheme.dividerColor,
            width: isSelected ? 3 : 1,
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.4),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        child: isTransparent
            ? Icon(
                Icons.format_color_reset,
                size: 18,
                color: rtheme.textColor.withOpacity(0.7),
              )
            : isSelected
            ? const Icon(Icons.check, color: Colors.white, size: 18)
            : null,
      ),
    );
  }

  /// Enhanced note input field
  Widget _buildNoteInput(
    ReadingTheme rtheme,
    Color accentColor,
    Color backgroundColor,
  ) {
    return Container(
      constraints: const BoxConstraints(minHeight: 120),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            accentColor.withOpacity(0.03),
            accentColor.withOpacity(0.01),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accentColor.withOpacity(0.2), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: accentColor.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: -4,
          ),
        ],
      ),
      child: TextField(
        controller: _noteController,
        focusNode: _focusNode,
        minLines: 4,
        maxLines: 8,
        textInputAction: TextInputAction.newline,
        style: TextStyle(color: rtheme.textColor, fontSize: 16, height: 1.5),
        decoration: InputDecoration(
          labelText: 'Your thoughts...',
          labelStyle: TextStyle(
            color: accentColor.withOpacity(0.8),
            fontWeight: FontWeight.w500,
          ),
          hintText:
              'Share your insights, questions, or reflections about the selected text.',
          hintStyle: TextStyle(
            color: rtheme.secondaryTextColor.withOpacity(0.7),
            fontSize: 15,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(20),
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 16, top: 16),
            child: Icon(
              Icons.edit_note_outlined,
              color: accentColor.withOpacity(0.8),
              size: 22,
            ),
          ),
          alignLabelWithHint: true,
          filled: true,
          fillColor: backgroundColor.withOpacity(0.3),
        ),
      ),
    );
  }

  /// Enhanced action buttons
  Widget _buildActionButtons(ReadingTheme rtheme, Color accentColor) {
    return Row(
      children: [
        // Cancel button
        Expanded(
          flex: 2,
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              color: rtheme.dividerColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: rtheme.dividerColor.withOpacity(0.3)),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: _closeSheet,
                child: Center(
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      color: rtheme.secondaryTextColor,
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Save button
        Expanded(
          flex: 3,
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [accentColor, accentColor.withOpacity(0.8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: accentColor.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: _saveNote,
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.bookmark_add_outlined,
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'Save Note',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
