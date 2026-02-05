import 'package:flutter/material.dart';
import '../utils/reading_theme.dart';

/// Widget for handling text selection and related actions
class TextSelectionMenu extends StatelessWidget {
  final String selectedText;
  final ReadingTheme theme;
  final VoidCallback? onHighlight;
  final VoidCallback? onBookmark;
  final VoidCallback? onCopy;
  final VoidCallback? onTakeNote;

  const TextSelectionMenu({
    super.key,
    required this.selectedText,
    required this.theme,
    this.onHighlight,
    this.onBookmark,
    this.onCopy,
    this.onTakeNote,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(),
          const SizedBox(height: 16.0),
          _buildSelectedText(),
          const SizedBox(height: 16.0),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Text(
      'Selected Text',
      style: TextStyle(
        color: theme.textColor,
        fontWeight: FontWeight.bold,
        fontSize: 18.0,
      ),
    );
  }

  Widget _buildSelectedText() {
    return Text(
      selectedText,
      style: TextStyle(color: theme.textColor),
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        // First row: Highlight and Bookmark
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                icon: Icon(Icons.highlight, color: theme.backgroundColor),
                label: Text(
                  'Highlight',
                  style: TextStyle(color: theme.backgroundColor),
                ),
                onPressed: onHighlight,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.highlightColor,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                icon: Icon(Icons.bookmark, color: theme.backgroundColor),
                label: Text(
                  'Bookmark',
                  style: TextStyle(color: theme.backgroundColor),
                ),
                onPressed: onBookmark,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.accentColor,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Second row: Take Note and Copy
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                icon: Icon(Icons.note_add, color: theme.backgroundColor),
                label: Text(
                  'Take Note',
                  style: TextStyle(color: theme.backgroundColor),
                ),
                onPressed: onTakeNote,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.highlightColor.withOpacity(0.7),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                icon: Icon(Icons.copy, color: theme.backgroundColor),
                label: Text(
                  'Copy',
                  style: TextStyle(color: theme.backgroundColor),
                ),
                onPressed: onCopy,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.secondaryTextColor,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
