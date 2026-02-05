import 'package:flutter/material.dart';
import 'reading_theme.dart';

/// Static class containing predefined reading themes
class ReadingThemes {
  ReadingThemes._(); // Private constructor to prevent instantiation

  /// Gets all available reading themes
  static List<ReadingTheme> getAllThemes() {
    return [
      ReadingThemes.light,
      ReadingThemes.dark,
      ReadingThemes.sepia,
      ReadingThemes.highContrast,
      ReadingThemes.blueLight,
      ReadingThemes.green,
      ReadingThemes.purple,
      ReadingThemes.orange,
    ];
  }

  /// Gets a theme by name
  static ReadingTheme? getThemeByName(String name) {
    try {
      return getAllThemes().firstWhere((theme) => theme.name == name);
    } catch (e) {
      return null;
    }
  }

  /// Light theme for daytime reading
  static final ReadingTheme light = ReadingTheme(
    name: 'Light',
    backgroundColor: Colors.white,
    textColor: Colors.black87,
    accentColor: Colors.blue,
    dividerColor: Colors.grey.shade300,
    selectionColor: Colors.blue.withOpacity(0.3),
    secondaryTextColor: Colors.grey.shade600,
    highlightColor: Colors.yellow.withOpacity(0.3),
    shadowColor: Colors.black.withOpacity(0.1),
  );

  /// Dark theme for nighttime reading
  static final ReadingTheme dark = ReadingTheme(
    name: 'Dark',
    backgroundColor: Colors.black87,
    textColor: Colors.white,
    accentColor: Colors.blue.shade300,
    dividerColor: Colors.grey.shade700,
    selectionColor: Colors.blue.shade300.withOpacity(0.3),
    secondaryTextColor: Colors.grey.shade400,
    highlightColor: Colors.yellow.shade700.withOpacity(0.3),
    shadowColor: Colors.white.withOpacity(0.1),
  );

  /// Sepia theme for reduced eye strain
  static final ReadingTheme sepia = ReadingTheme(
    name: 'Sepia',
    backgroundColor: const Color(0xFFFDF6E3),
    textColor: const Color(0xFF5D4037),
    accentColor: const Color(0xFF8D6E63),
    dividerColor: const Color(0xFFD7CCC8),
    selectionColor: const Color(0xFF8D6E63).withOpacity(0.3),
    secondaryTextColor: const Color(0xFF8D6E63),
    highlightColor: const Color(0xFFFFF59D).withOpacity(0.5),
    shadowColor: const Color(0xFF5D4037).withOpacity(0.1),
  );

  /// High contrast theme for accessibility
  static final ReadingTheme highContrast = ReadingTheme(
    name: 'High Contrast',
    backgroundColor: Colors.black,
    textColor: Colors.white,
    accentColor: Colors.yellow,
    dividerColor: Colors.white,
    selectionColor: Colors.yellow.withOpacity(0.5),
    secondaryTextColor: Colors.yellow,
    highlightColor: Colors.yellow.withOpacity(0.7),
    shadowColor: Colors.white.withOpacity(0.3),
  );

  /// Blue light filter theme
  static final ReadingTheme blueLight = ReadingTheme(
    name: 'Blue Light Filter',
    backgroundColor: const Color(0xFFF5F5FF),
    textColor: const Color(0xFF1A1A2E),
    accentColor: const Color(0xFF16213E),
    dividerColor: const Color(0xFFE8E8FF),
    selectionColor: const Color(0xFF16213E).withOpacity(0.3),
    secondaryTextColor: const Color(0xFF16213E),
    highlightColor: const Color(0xFFE8E8FF).withOpacity(0.7),
    shadowColor: const Color(0xFF1A1A2E).withOpacity(0.1),
  );

  /// Green theme for nature-inspired reading
  static final ReadingTheme green = ReadingTheme(
    name: 'Green',
    backgroundColor: const Color(0xFFF1F8E9),
    textColor: const Color(0xFF2E7D32),
    accentColor: const Color(0xFF4CAF50),
    dividerColor: const Color(0xFFC8E6C9),
    selectionColor: const Color(0xFF4CAF50).withOpacity(0.3),
    secondaryTextColor: const Color(0xFF388E3C),
    highlightColor: const Color(0xFFC8E6C9).withOpacity(0.7),
    shadowColor: const Color(0xFF2E7D32).withOpacity(0.1),
  );

  /// Purple theme for creative reading
  static final ReadingTheme purple = ReadingTheme(
    name: 'Purple',
    backgroundColor: const Color(0xFFF3E5F5),
    textColor: const Color(0xFF4A148C),
    accentColor: const Color(0xFF9C27B0),
    dividerColor: const Color(0xFFE1BEE7),
    selectionColor: const Color(0xFF9C27B0).withOpacity(0.3),
    secondaryTextColor: const Color(0xFF7B1FA2),
    highlightColor: const Color(0xFFE1BEE7).withOpacity(0.7),
    shadowColor: const Color(0xFF4A148C).withOpacity(0.1),
  );

  /// Orange theme for warm reading
  static final ReadingTheme orange = ReadingTheme(
    name: 'Orange',
    backgroundColor: const Color(0xFFFFF3E0),
    textColor: const Color(0xFFE65100),
    accentColor: const Color(0xFFFF9800),
    dividerColor: const Color(0xFFFFCC02),
    selectionColor: const Color(0xFFFF9800).withOpacity(0.3),
    secondaryTextColor: const Color(0xFFF57C00),
    highlightColor: const Color(0xFFFFCC02).withOpacity(0.7),
    shadowColor: const Color(0xFFE65100).withOpacity(0.1),
  );
}
