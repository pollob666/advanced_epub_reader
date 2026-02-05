import 'package:flutter/material.dart';
import '../utils/reading_theme.dart';

/// Dialog for taking notes on selected text
class NoteDialog extends StatefulWidget {
  final String selectedText;
  final ReadingTheme theme;
  final String? initialNote;

  const NoteDialog({
    super.key,
    required this.selectedText,
    required this.theme,
    this.initialNote,
  });

  @override
  State<NoteDialog> createState() => _NoteDialogState();
}

class _NoteDialogState extends State<NoteDialog> {
  late TextEditingController _noteController;
  late FocusNode _noteFocusNode;

  @override
  void initState() {
    super.initState();
    _noteController = TextEditingController(text: widget.initialNote ?? '');
    _noteFocusNode = FocusNode();

    // Auto-focus the text field
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _noteFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _noteController.dispose();
    _noteFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: widget.theme.backgroundColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400, maxHeight: 500),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(Icons.note_add, color: widget.theme.accentColor, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Take a Note',
                    style: TextStyle(
                      color: widget.theme.textColor,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, color: widget.theme.textColor),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Selected text display
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: widget.theme.backgroundColor,
                border: Border.all(color: widget.theme.dividerColor),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Selected Text:',
                    style: TextStyle(
                      color: widget.theme.secondaryTextColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.selectedText,
                    style: TextStyle(
                      color: widget.theme.textColor,
                      fontSize: 14,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Note input field
            TextField(
              controller: _noteController,
              focusNode: _noteFocusNode,
              maxLines: 5,
              maxLength: 500,
              decoration: InputDecoration(
                labelText: 'Your Note',
                labelStyle: TextStyle(color: widget.theme.secondaryTextColor),
                hintText: 'Write your thoughts, questions, or insights...',
                hintStyle: TextStyle(
                  color: widget.theme.secondaryTextColor.withOpacity(0.6),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: widget.theme.dividerColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: widget.theme.accentColor,
                    width: 2,
                  ),
                ),
                filled: true,
                fillColor: widget.theme.backgroundColor,
              ),
              style: TextStyle(color: widget.theme.textColor, fontSize: 16),
            ),
            const SizedBox(height: 24),

            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: widget.theme.secondaryTextColor),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _noteController.text.trim().isEmpty
                      ? null
                      : () => Navigator.of(
                          context,
                        ).pop(_noteController.text.trim()),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.theme.accentColor,
                    foregroundColor: widget.theme.backgroundColor,
                  ),
                  child: const Text('Save Note'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
