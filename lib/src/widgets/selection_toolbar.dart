import 'package:flutter/material.dart';
import '../utils/reading_theme.dart';

/// A floating toolbar with modern design shown when text is selected
/// Features improved animations, better visual hierarchy, and proper spacing
class SelectionToolbar extends StatefulWidget {
  final ReadingTheme theme;
  final VoidCallback? onCopy;
  final VoidCallback? onBookmark;
  final VoidCallback? onHighlight;
  final VoidCallback? onNote;
  final String? selectedText;
  final bool showLabels;

  const SelectionToolbar({
    super.key,
    required this.theme,
    this.onCopy,
    this.onBookmark,
    this.onHighlight,
    this.onNote,
    this.selectedText,
    this.showLabels = false,
  });

  @override
  State<SelectionToolbar> createState() => _SelectionToolbarState();
}

class _SelectionToolbarState extends State<SelectionToolbar>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: Material(
              color: Colors.transparent,
              elevation: 0,
              child: Container(
                decoration: BoxDecoration(
                  color: widget.theme.backgroundColor.withOpacity(0.95),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: widget.theme.dividerColor.withOpacity(0.3),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: widget.theme.shadowColor.withOpacity(0.15),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                      spreadRadius: 0,
                    ),
                    BoxShadow(
                      color: widget.theme.shadowColor.withOpacity(0.1),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                      spreadRadius: 0,
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildToolbarButton(
                      context,
                      icon: Icons.content_copy_rounded,
                      label: 'Copy',
                      onTap: widget.onCopy,
                    ),
                    _buildDivider(),
                    _buildToolbarButton(
                      context,
                      icon: Icons.bookmark_outline_rounded,
                      label: 'Bookmark',
                      onTap: widget.onBookmark,
                    ),
                    _buildDivider(),
                    _buildToolbarButton(
                      context,
                      icon: Icons.highlight_rounded,
                      label: 'Highlight',
                      onTap: widget.onHighlight,
                    ),
                    _buildDivider(),
                    _buildToolbarButton(
                      context,
                      icon: Icons.note_add_outlined,
                      label: 'Note',
                      onTap: widget.onNote,
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

  Widget _buildToolbarButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback? onTap,
  }) {
    final isEnabled = onTap != null;

    return Tooltip(
      message: label,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          splashColor: widget.theme.accentColor.withOpacity(0.2),
          highlightColor: widget.theme.accentColor.withOpacity(0.1),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: EdgeInsets.all(widget.showLabels ? 8 : 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.transparent,
            ),
            child: widget.showLabels
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        icon,
                        size: 18,
                        color: isEnabled
                            ? widget.theme.textColor
                            : widget.theme.textColor.withOpacity(0.3),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: isEnabled
                              ? widget.theme.secondaryTextColor
                              : widget.theme.secondaryTextColor.withOpacity(
                                  0.3,
                                ),
                        ),
                      ),
                    ],
                  )
                : Icon(
                    icon,
                    size: 18,
                    color: isEnabled
                        ? widget.theme.textColor
                        : widget.theme.textColor.withOpacity(0.3),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: widget.showLabels ? 36 : 20,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            widget.theme.dividerColor.withOpacity(0.3),
            Colors.transparent,
          ],
        ),
      ),
    );
  }
}

/// Alternative compact version for minimal UI
class CompactSelectionToolbar extends StatelessWidget {
  final ReadingTheme theme;
  final VoidCallback? onCopy;
  final VoidCallback? onBookmark;
  final VoidCallback? onHighlight;
  final VoidCallback? onNote;

  const CompactSelectionToolbar({
    super.key,
    required this.theme,
    this.onCopy,
    this.onBookmark,
    this.onHighlight,
    this.onNote,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: theme.backgroundColor.withOpacity(0.9),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: theme.dividerColor.withOpacity(0.2),
          width: 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildCompactButton(Icons.content_copy_rounded, onCopy),
          const SizedBox(width: 2),
          _buildCompactButton(Icons.bookmark_outline_rounded, onBookmark),
          const SizedBox(width: 2),
          _buildCompactButton(Icons.highlight_rounded, onHighlight),
          const SizedBox(width: 2),
          _buildCompactButton(Icons.note_add_outlined, onNote),
        ],
      ),
    );
  }

  Widget _buildCompactButton(IconData icon, VoidCallback? onTap) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(
            icon,
            size: 16,
            color: onTap != null
                ? theme.textColor
                : theme.textColor.withOpacity(0.3),
          ),
        ),
      ),
    );
  }
}
