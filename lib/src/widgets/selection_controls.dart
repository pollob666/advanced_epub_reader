import 'package:flutter/material.dart';
import '../utils/reading_theme.dart';

/// Bottom selection controller shown when text is selected.
/// Mirrors the style and behavior of `ReadingControls` but with selection actions.
class SelectionControls extends StatelessWidget {
  final ReadingTheme theme;
  final String selectedText;
  final VoidCallback? onCopy;
  final VoidCallback? onHighlight;
  final VoidCallback? onBookmark;
  final VoidCallback? onNote;
  final VoidCallback? onCancelSelection;

  const SelectionControls({
    super.key,
    required this.theme,
    required this.selectedText,
    this.onCopy,
    this.onHighlight,
    this.onBookmark,
    this.onNote,
    this.onCancelSelection,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      padding: const EdgeInsets.only(top: 12.0),
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
        top: false,
        bottom: true,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildSelectedPreview(context),
            const SizedBox(height: 8),
            _buildActionsRow(context),
            const SizedBox(height: 6),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedPreview(BuildContext context) {
    if (selectedText.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          Expanded(
            child: Text(
              selectedText,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: theme.secondaryTextColor, fontSize: 12.0),
            ),
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: onCancelSelection,
            child: Text(
              'Cancel',
              style: TextStyle(
                color: theme.accentColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionsRow(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildActionButton(
          context,
          icon: Icons.content_copy,
          title: 'Copy',
          onTap: onCopy,
        ),
        _buildActionButton(
          context,
          icon: Icons.highlight,
          title: 'Highlight',
          onTap: onHighlight,
        ),
        _buildActionButton(
          context,
          icon: Icons.note_add_outlined,
          title: 'Note',
          onTap: onNote,
        ),
        _buildActionButton(
          context,
          icon: Icons.bookmark_outline,
          title: 'Bookmark',
          onTap: onBookmark,
        ),
      ],
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback? onTap,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
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
}
