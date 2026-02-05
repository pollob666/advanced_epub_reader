import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/reading_theme.dart';

class PageJumpSheet extends StatefulWidget {
  final ValueNotifier<int> currentPageNotifier;
  final int totalPages;
  final ReadingTheme theme;
  final ValueChanged<int> onPageSelected;

  const PageJumpSheet({
    super.key,
    required this.currentPageNotifier,
    required this.totalPages,
    required this.theme,
    required this.onPageSelected,
  });

  @override
  State<PageJumpSheet> createState() => _PageJumpSheetState();
}

class _PageJumpSheetState extends State<PageJumpSheet>
    with SingleTickerProviderStateMixin {
  late TextEditingController _controller;
  late AnimationController _animationController;
  late Animation<double> _shakeAnimation;
  String? _error;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.currentPageNotifier.value.toString(),
    );
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 10).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticIn),
    );
    // Auto-focus the TextField when the sheet opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _animationController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _validate(String value) {
    if (value.isEmpty) {
      setState(() {
        _error = 'Please enter a page number';
        _animationController.forward().then(
          (_) => _animationController.reverse(),
        );
        HapticFeedback.lightImpact();
      });
      return;
    }
    final page = int.tryParse(value);
    if (page == null) {
      setState(() {
        _error = 'Please enter a valid number';
        _animationController.forward().then(
          (_) => _animationController.reverse(),
        );
        HapticFeedback.lightImpact();
      });
      return;
    }
    if (page < 1 || page > widget.totalPages) {
      setState(() {
        _error = 'Page must be between 1 and ${widget.totalPages}';
        _animationController.forward().then(
          (_) => _animationController.reverse(),
        );
        HapticFeedback.lightImpact();
      });
      return;
    }
    setState(() => _error = null);
  }

  void _submit() {
    final page = int.tryParse(_controller.text);
    if (page != null && _error == null) {
      HapticFeedback.selectionClick();
      widget.onPageSelected(page);
      Navigator.of(context).pop();
    }
  }

  /// Get better accent color for the current theme (same as search sheet)
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

  /// Get better background color for dark themes (same as search sheet)
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

  /// Get better shadow color for dark themes (same as search sheet)
  Color _getShadowColor(ReadingTheme theme) {
    if (theme.name.toLowerCase().contains('dark') ||
        theme.name.toLowerCase().contains('high contrast')) {
      return Colors.white.withOpacity(0.1);
    }
    return Colors.black.withOpacity(0.1);
  }

  /// Get better drag handle color for visibility (same as search sheet)
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
    final betterAccentColor = _getBetterAccentColor(widget.theme);
    final sheetBackgroundColor = _getSheetBackgroundColor(widget.theme);
    final shadowColor = _getShadowColor(widget.theme);
    final dragHandleColor = _getDragHandleColor(widget.theme);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        child: BackdropFilter(
          filter:
              widget.theme.name.toLowerCase().contains('dark') ||
                  widget.theme.name.toLowerCase().contains('high contrast')
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
                color: widget.theme.dividerColor.withOpacity(0.3),
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
              bottom: false,
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  20,
                  8,
                  20,
                  16 + MediaQuery.of(context).padding.bottom,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Drag handle
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: dragHandleColor,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),

                    // Header
                    Text(
                      'Go to Book Page',
                      style: TextStyle(
                        color: widget.theme.textColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Current page info
                    ValueListenableBuilder<int>(
                      valueListenable: widget.currentPageNotifier,
                      builder: (context, currentPage, child) {
                        return Text(
                          'Current page: $currentPage of ${widget.totalPages}',
                          style: TextStyle(
                            color: widget.theme.secondaryTextColor,
                            fontSize: 14,
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),

                    // Page input field
                    AnimatedBuilder(
                      animation: _shakeAnimation,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(_shakeAnimation.value, 0),
                          child: child,
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: sheetBackgroundColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: widget.theme.dividerColor,
                            width: 1,
                          ),
                        ),
                        child: TextField(
                          controller: _controller,
                          focusNode: _focusNode,
                          keyboardType: TextInputType.number,
                          style: TextStyle(
                            color: widget.theme.textColor,
                            fontSize: 16,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Page number (1 - ${widget.totalPages})',
                            hintStyle: TextStyle(
                              color: widget.theme.secondaryTextColor,
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            prefixIcon: Icon(
                              Icons.navigation,
                              color: widget.theme.secondaryTextColor,
                              size: 20,
                            ),
                            errorText: _error,
                            errorStyle: TextStyle(
                              color: Colors.redAccent,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          onChanged: _validate,
                          onSubmitted: (_) => _submit(),
                          textInputAction: TextInputAction.done,
                          autofillHints: const [AutofillHints.telephoneNumber],
                          enableSuggestions: false,
                          autocorrect: false,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Action buttons
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 44,
                            decoration: BoxDecoration(
                              color: sheetBackgroundColor,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: widget.theme.dividerColor,
                                width: 1,
                              ),
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(10),
                                onTap: () {
                                  HapticFeedback.lightImpact();
                                  Navigator.of(context).pop();
                                },
                                child: Center(
                                  child: Text(
                                    'Cancel',
                                    style: TextStyle(
                                      color: widget.theme.textColor,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Container(
                            height: 44,
                            decoration: BoxDecoration(
                              color: _error == null
                                  ? betterAccentColor.withOpacity(0.1)
                                  : sheetBackgroundColor,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: _error == null
                                    ? betterAccentColor
                                    : widget.theme.dividerColor,
                                width: 1,
                              ),
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(10),
                                onTap: _error == null ? _submit : null,
                                child: Center(
                                  child: Text(
                                    'Go',
                                    style: TextStyle(
                                      color: _error == null
                                          ? betterAccentColor
                                          : widget.theme.secondaryTextColor,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
