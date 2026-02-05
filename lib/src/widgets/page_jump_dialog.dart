import 'package:flutter/material.dart';
import '../utils/reading_theme.dart';

/// Dialog for jumping to a specific page within a chapter
class PageJumpDialog extends StatefulWidget {
  /// Current page
  final int currentPage;

  /// Total pages in the chapter
  final int totalPages;

  /// Current reading theme
  final ReadingTheme theme;

  /// Callback when a page is selected
  final Function(int page) onPageSelected;

  const PageJumpDialog({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.theme,
    required this.onPageSelected,
  });

  @override
  State<PageJumpDialog> createState() => _PageJumpDialogState();
}

class _PageJumpDialogState extends State<PageJumpDialog> {
  late TextEditingController _pageController;
  late int _selectedPage;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _selectedPage = widget.currentPage;
    _pageController = TextEditingController(text: _selectedPage.toString());
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: widget.theme.backgroundColor,
      title: Text(
        'Go to Book Page',
        style: TextStyle(
          color: widget.theme.textColor,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Current book page: ${widget.currentPage} of ${widget.totalPages}',
            style: TextStyle(
              color: widget.theme.secondaryTextColor,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _pageController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Book page number',
              labelStyle: TextStyle(color: widget.theme.textColor),
              border: OutlineInputBorder(
                borderSide: BorderSide(color: widget.theme.dividerColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: widget.theme.dividerColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: widget.theme.accentColor),
              ),
              errorText: _errorMessage,
              errorStyle: TextStyle(color: Colors.red),
            ),
            style: TextStyle(color: widget.theme.textColor),
            onChanged: (value) {
              _validatePageInput(value);
            },
          ),
          const SizedBox(height: 8),
          Text(
            'Enter a book page number between 1 and ${widget.totalPages}',
            style: TextStyle(
              color: widget.theme.secondaryTextColor,
              fontSize: 12,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            'Cancel',
            style: TextStyle(color: widget.theme.secondaryTextColor),
          ),
        ),
        ElevatedButton(
          onPressed: _errorMessage == null ? _goToPage : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: widget.theme.accentColor,
            foregroundColor: widget.theme.backgroundColor,
          ),
          child: const Text('Go'),
        ),
      ],
    );
  }

  void _validatePageInput(String value) {
    if (value.isEmpty) {
      setState(() {
        _errorMessage = null;
      });
      return;
    }

    final page = int.tryParse(value);
    if (page == null) {
      setState(() {
        _errorMessage = 'Please enter a valid number';
      });
      return;
    }

    if (page < 1 || page > widget.totalPages) {
      setState(() {
        _errorMessage = 'Page must be between 1 and ${widget.totalPages}';
      });
      return;
    }

    setState(() {
      _errorMessage = null;
      _selectedPage = page;
    });
  }

  void _goToPage() {
    if (_errorMessage == null) {
      widget.onPageSelected(_selectedPage);
      Navigator.of(context).pop();
    }
  }
}
