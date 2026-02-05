import 'package:flutter/material.dart';
import '../models/epub_book.dart';
import '../utils/reading_theme.dart';
import '../utils/theme_manager.dart';

/// Widget for the EPUB viewer menu and settings
class EpubViewerMenu extends StatelessWidget {
  final EpubBook book;
  final ReadingTheme theme;
  final VoidCallback? onClose;

  const EpubViewerMenu({
    super.key,
    required this.book,
    required this.theme,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildMenuHeader(),
          const SizedBox(height: 16.0),
          _buildMenuItems(context),
          const SizedBox(height: 16.0),
          _buildSettingsButtons(),
        ],
      ),
    );
  }

  Widget _buildMenuHeader() {
    return Row(
      children: [
        Icon(Icons.menu_book, color: theme.accentColor, size: 24),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Reading Menu',
                style: TextStyle(
                  color: theme.textColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              Text(
                book.metadata.title,
                style: TextStyle(color: theme.secondaryTextColor, fontSize: 14),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        IconButton(
          icon: Icon(Icons.close, color: theme.textColor),
          onPressed: onClose,
        ),
      ],
    );
  }

  Widget _buildMenuItems(BuildContext context) {
    return Column(
      children: [
        // Settings
        ListTile(
          leading: Icon(Icons.settings, color: theme.accentColor),
          title: Text('Settings', style: TextStyle(color: theme.textColor)),
          onTap: () {
            Navigator.pop(context);
            _showSettings(context);
          },
        ),
        // Bookmarks
        ListTile(
          leading: Icon(Icons.bookmark, color: theme.accentColor),
          title: Text('Bookmarks', style: TextStyle(color: theme.textColor)),
          onTap: () {
            Navigator.pop(context);
            _showBookmarks(context);
          },
        ),
        // Annotations
        ListTile(
          leading: Icon(Icons.note, color: theme.accentColor),
          title: Text('Annotations', style: TextStyle(color: theme.textColor)),
          onTap: () {
            Navigator.pop(context);
            _showAnnotations(context);
          },
        ),
        // Book Info
        ListTile(
          leading: Icon(Icons.info, color: theme.accentColor),
          title: Text('Book Info', style: TextStyle(color: theme.textColor)),
          onTap: () {
            Navigator.pop(context);
            _showBookInfo(context);
          },
        ),
      ],
    );
  }

  Widget _buildSettingsButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              final settings = ThemeManager.exportThemeSettings();
              debugPrint('Exported settings: $settings');
              // You can show a snackbar here if needed
            },
            icon: const Icon(Icons.download),
            label: const Text('Export Settings'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              // Reset to default theme
              final defaultTheme = ThemeManager.getCurrentTheme();
              ThemeManager.resetToDefaults();
              // You can show a snackbar here if needed
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Reset Defaults'),
          ),
        ),
      ],
    );
  }

  void _showSettings(BuildContext context) {
    // Implementation for settings
    debugPrint('Show settings');
  }

  void _showBookmarks(BuildContext context) {
    // Implementation for bookmarks
    debugPrint('Show bookmarks');
  }

  void _showAnnotations(BuildContext context) {
    // Implementation for annotations
    debugPrint('Show annotations');
  }

  void _showBookInfo(BuildContext context) {
    // Implementation for book info
    debugPrint('Show book info');
  }
}
