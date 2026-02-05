import 'package:flutter/material.dart';
import 'reading_theme.dart';
import 'reading_themes.dart';

/// Manages reading themes and settings with listener pattern for real-time updates
class ThemeManager {
  ThemeManager._(); // Private constructor to prevent instantiation

  // Current theme and settings
  static ReadingTheme _currentTheme = ReadingThemes.light;
  static double _currentFontSize = 16.0;
  static String _currentFontFamily = 'Roboto';
  static double _currentLineHeight = 1.5;
  static double _currentMargin = 16.0;
  static String _currentReadingStyle = 'Scrolling';

  // Listeners for real-time updates
  static final List<Function(ReadingTheme)> _themeListeners = [];
  static final List<Function(double)> _fontSizeListeners = [];
  static final List<Function(String)> _fontFamilyListeners = [];
  static final List<Function(double)> _lineHeightListeners = [];
  static final List<Function(double)> _marginListeners = [];
  static final List<Function(String)> _readingStyleListeners = [];

  // Getters for current values
  static ReadingTheme getCurrentTheme() => _currentTheme;
  static double getCurrentFontSize() => _currentFontSize;
  static String getCurrentFontFamily() => _currentFontFamily;
  static double getCurrentLineHeight() => _currentLineHeight;
  static double getCurrentMargin() => _currentMargin;
  static String getCurrentReadingStyle() => _currentReadingStyle;

  // Setters with listener notifications
  static void setCurrentTheme(ReadingTheme theme) {
    debugPrint('ThemeManager: Setting theme to ${theme.name}');
    final previousTheme = _currentTheme;
    _currentTheme = theme;
    debugPrint('ThemeManager: Previous theme was ${previousTheme.name}');
    debugPrint('ThemeManager: Theme updated to ${_currentTheme.name}');
    _notifyThemeListeners();
  }

  static void setCurrentFontSize(double size) {
    debugPrint('ThemeManager: Setting font size to $size');
    _currentFontSize = size;
    _notifyFontSizeListeners();
  }

  static void setCurrentFontFamily(String fontFamily) {
    debugPrint('ThemeManager: Setting font family to $fontFamily');
    final previousFont = _currentFontFamily;
    _currentFontFamily = fontFamily;
    debugPrint('ThemeManager: Previous font family was $previousFont');
    debugPrint('ThemeManager: Font family updated to $_currentFontFamily');
    _notifyFontFamilyListeners();
  }

  static void setCurrentLineHeight(double height) {
    debugPrint('ThemeManager: Setting line height to $height');
    _currentLineHeight = height;
    _notifyLineHeightListeners();
  }

  static void setCurrentMargin(double margin) {
    debugPrint('ThemeManager: Setting margin to $margin');
    _currentMargin = margin;
    _notifyMarginListeners();
  }

  static void setCurrentReadingStyle(String style) {
    debugPrint('ThemeManager: Setting reading style to $style');
    _currentReadingStyle = style;
    _notifyReadingStyleListeners();
  }

  // Listener management
  static void addThemeListener(Function(ReadingTheme) listener) {
    debugPrint('ThemeManager: Adding theme listener');
    _themeListeners.add(listener);
    debugPrint(
      'ThemeManager: Theme listeners count: ${_themeListeners.length}',
    );
  }

  static void removeThemeListener(Function(ReadingTheme) listener) {
    _themeListeners.remove(listener);
  }

  static void addFontSizeListener(Function(double) listener) {
    debugPrint('ThemeManager: Adding font size listener');
    _fontSizeListeners.add(listener);
    debugPrint(
      'ThemeManager: Font size listeners count: ${_fontSizeListeners.length}',
    );
  }

  static void removeFontSizeListener(Function(double) listener) {
    _fontSizeListeners.remove(listener);
  }

  static void addFontFamilyListener(Function(String) listener) {
    debugPrint('ThemeManager: Adding font family listener');
    _fontFamilyListeners.add(listener);
    debugPrint(
      'ThemeManager: Font family listeners count: ${_fontFamilyListeners.length}',
    );
  }

  static void removeFontFamilyListener(Function(String) listener) {
    _fontFamilyListeners.remove(listener);
  }

  static void addLineHeightListener(Function(double) listener) {
    _lineHeightListeners.add(listener);
  }

  static void removeLineHeightListener(Function(double) listener) {
    _lineHeightListeners.remove(listener);
  }

  static void addMarginListener(Function(double) listener) {
    _marginListeners.add(listener);
  }

  static void removeMarginListener(Function(double) listener) {
    _marginListeners.remove(listener);
  }

  static void addReadingStyleListener(Function(String) listener) {
    _readingStyleListeners.add(listener);
  }

  static void removeReadingStyleListener(Function(String) listener) {
    _readingStyleListeners.remove(listener);
  }

  // Notification methods
  static void _notifyThemeListeners() {
    debugPrint(
      'ThemeManager: Notifying ${_themeListeners.length} theme listeners',
    );
    for (final listener in _themeListeners) {
      listener(_currentTheme);
    }
    debugPrint('ThemeManager: Theme listeners notified');
  }

  static void _notifyFontSizeListeners() {
    for (final listener in _fontSizeListeners) {
      listener(_currentFontSize);
    }
  }

  static void _notifyFontFamilyListeners() {
    debugPrint(
      'ThemeManager: Notifying ${_fontFamilyListeners.length} font family listeners',
    );
    for (final listener in _fontFamilyListeners) {
      listener(_currentFontFamily);
    }
    debugPrint('ThemeManager: Font family listeners notified');
  }

  static void _notifyLineHeightListeners() {
    for (final listener in _lineHeightListeners) {
      listener(_currentLineHeight);
    }
  }

  static void _notifyMarginListeners() {
    for (final listener in _marginListeners) {
      listener(_currentMargin);
    }
  }

  static void _notifyReadingStyleListeners() {
    for (final listener in _readingStyleListeners) {
      listener(_currentReadingStyle);
    }
  }

  // Theme manipulation methods
  static ReadingTheme createCustomTheme({
    required String name,
    required Color backgroundColor,
    required Color textColor,
    required Color accentColor,
    Color? dividerColor,
    Color? selectionColor,
    Color? secondaryTextColor,
    Color? highlightColor,
    Color? shadowColor,
  }) {
    return ReadingTheme(
      name: name,
      backgroundColor: backgroundColor,
      textColor: textColor,
      accentColor: accentColor,
      dividerColor: dividerColor ?? _currentTheme.dividerColor,
      selectionColor: selectionColor ?? _currentTheme.selectionColor,
      secondaryTextColor:
          secondaryTextColor ?? _currentTheme.secondaryTextColor,
      highlightColor: highlightColor ?? _currentTheme.highlightColor,
      shadowColor: shadowColor ?? _currentTheme.shadowColor,
    );
  }

  static ReadingTheme createInvertedTheme() {
    return _currentTheme.createInvertedTheme();
  }

  static ReadingTheme createHighContrastTheme() {
    return _currentTheme.createHighContrastTheme();
  }

  static ReadingTheme createColorTemperatureTheme({required bool isWarm}) {
    return _currentTheme.createColorTemperatureTheme(isWarm: isWarm);
  }

  // Utility methods for creating text styles
  static TextStyle createTextStyle({
    required ReadingTheme theme,
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
  }) {
    return TextStyle(
      fontSize: fontSize ?? getCurrentFontSize(),
      fontWeight: fontWeight ?? FontWeight.normal,
      color: color ?? theme.textColor,
      fontFamily: getCurrentFontFamily(),
      height: getCurrentLineHeight(),
    );
  }

  static TextStyle createSecondaryTextStyle({
    required ReadingTheme theme,
    double? fontSize,
    FontWeight? fontWeight,
  }) {
    return TextStyle(
      fontSize: fontSize ?? getCurrentFontSize() * 0.875,
      fontWeight: fontWeight ?? FontWeight.normal,
      color: theme.secondaryTextColor,
      fontFamily: getCurrentFontFamily(),
      height: getCurrentLineHeight(),
    );
  }

  // Export/Import theme settings
  static Map<String, dynamic> exportThemeSettings() {
    return {
      'theme': _currentTheme.toJson(),
      'fontSize': _currentFontSize,
      'fontFamily': _currentFontFamily,
      'lineHeight': _currentLineHeight,
      'margin': _currentMargin,
      'readingStyle': _currentReadingStyle,
    };
  }

  static void importThemeSettings(Map<String, dynamic> settings) {
    if (settings['theme'] != null) {
      setCurrentTheme(ReadingTheme.fromJson(settings['theme']));
    }
    if (settings['fontSize'] != null) {
      setCurrentFontSize(settings['fontSize'].toDouble());
    }
    if (settings['fontFamily'] != null) {
      setCurrentFontFamily(settings['fontFamily']);
    }
    if (settings['lineHeight'] != null) {
      setCurrentLineHeight(settings['lineHeight'].toDouble());
    }
    if (settings['margin'] != null) {
      setCurrentMargin(settings['margin'].toDouble());
    }
    if (settings['readingStyle'] != null) {
      setCurrentReadingStyle(settings['readingStyle']);
    }
  }

  // Available options
  static List<String> getAvailableFontFamilies() {
    return [
      'Roboto',
      'Open Sans',
      'Lato',
      'Source Sans Pro',
      'Noto Sans',
      'Merriweather',
      'Georgia',
      'Times New Roman',
      'Arial',
      'Helvetica',
    ];
  }

  static List<String> getAvailableFontFamiliesWithFallbacks() {
    return [
      'Roboto, Arial, sans-serif',
      'Open Sans, Arial, sans-serif',
      'Lato, Arial, sans-serif',
      'Source Sans Pro, Arial, sans-serif',
      'Noto Sans, Arial, sans-serif',
      'Merriweather, Georgia, serif',
      'Georgia, Times New Roman, serif',
      'Times New Roman, Times, serif',
      'Arial, Helvetica, sans-serif',
      'Helvetica, Arial, sans-serif',
    ];
  }

  static String getCurrentFontFamilyWithFallbacks() {
    final currentFont = _currentFontFamily;
    switch (currentFont) {
      case 'Roboto':
        return 'Roboto, Arial, sans-serif';
      case 'Open Sans':
        return 'Open Sans, Arial, sans-serif';
      case 'Lato':
        return 'Lato, Arial, sans-serif';
      case 'Source Sans Pro':
        return 'Source Sans Pro, Arial, sans-serif';
      case 'Noto Sans':
        return 'Noto Sans, Arial, sans-serif';
      case 'Merriweather':
        return 'Merriweather, Georgia, serif';
      case 'Georgia':
        return 'Georgia, Times New Roman, serif';
      case 'Times New Roman':
        return 'Times New Roman, Times, serif';
      case 'Arial':
        return 'Arial, Helvetica, sans-serif';
      case 'Helvetica':
        return 'Helvetica, Arial, sans-serif';
      default:
        return 'Arial, sans-serif';
    }
  }

  static List<double> getAvailableFontSizes() {
    return [12.0, 14.0, 16.0, 18.0, 20.0, 22.0, 24.0, 26.0, 28.0, 32.0];
  }

  static List<double> getAvailableLineHeights() {
    return [1.0, 1.2, 1.4, 1.5, 1.6, 1.8, 2.0, 2.2, 2.5];
  }

  static List<double> getAvailableMargins() {
    return [8.0, 12.0, 16.0, 20.0, 24.0, 28.0, 32.0];
  }

  static List<String> getAvailableReadingStyles() {
    return ['Scrolling', 'Fixed', 'Double Page', 'Scroll and Zoom'];
  }

  // Reset to defaults
  static void resetToDefaults() {
    setCurrentTheme(ReadingThemes.light);
    setCurrentFontSize(16.0);
    setCurrentFontFamily('Roboto');
    setCurrentLineHeight(1.5);
    setCurrentMargin(16.0);
    setCurrentReadingStyle('Scrolling');
  }
}
