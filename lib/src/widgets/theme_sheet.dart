import 'package:flutter/material.dart';
import '../utils/reading_theme.dart';
import '../utils/reading_themes.dart';
import '../utils/theme_manager.dart';

/// Theme selection sheet
class ThemeSheet extends StatelessWidget {
  final ReadingTheme theme;

  const ThemeSheet({required this.theme, super.key});

  @override
  Widget build(BuildContext context) {
    final themes = ReadingThemes.getAllThemes();

    return Container(
      decoration: BoxDecoration(
        color: theme.backgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor,
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: theme.dividerColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Title
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                'Select Theme',
                style: TextStyle(
                  color: theme.textColor,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            // Theme selection as vertical list
            Container(
              constraints: const BoxConstraints(maxHeight: 300),
              child: ListView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: themes.length,
                itemBuilder: (context, index) {
                  final themeOption = themes[index];
                  final isSelected = themeOption.name == theme.name;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: Container(
                        width: 50,
                        height: 40,
                        decoration: BoxDecoration(
                          color: themeOption.backgroundColor,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected
                                ? theme.accentColor
                                : themeOption.dividerColor,
                            width: isSelected ? 3 : 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: theme.shadowColor,
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            'Aa',
                            style: TextStyle(
                              color: themeOption.textColor,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      title: Text(
                        themeOption.name,
                        style: TextStyle(
                          color: theme.textColor,
                          fontSize: 16,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                      trailing: isSelected
                          ? Icon(Icons.check, color: theme.accentColor)
                          : null,
                      onTap: () {
                        debugPrint('Theme selected: ${themeOption.name}');
                        ThemeManager.setCurrentTheme(themeOption);
                        debugPrint('Theme set, closing sheet');
                        Navigator.pop(context);
                      },
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 4,
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
