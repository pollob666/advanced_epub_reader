import 'package:flutter/material.dart';

/// Represents a reading theme with color and styling properties
class ReadingTheme {
  /// Theme name for display
  final String name;

  /// Background color for the reading area
  final Color backgroundColor;

  /// Primary text color
  final Color textColor;

  /// Accent color for highlights and interactive elements
  final Color accentColor;

  /// Color for dividers and borders
  final Color dividerColor;

  /// Color for text selection
  final Color selectionColor;

  /// Secondary text color for less important text
  final Color secondaryTextColor;

  /// Color for highlights and annotations
  final Color highlightColor;

  /// Color for shadows and depth effects
  final Color shadowColor;

  /// Creates a new reading theme
  const ReadingTheme({
    required this.name,
    required this.backgroundColor,
    required this.textColor,
    required this.accentColor,
    required this.dividerColor,
    required this.selectionColor,
    required this.secondaryTextColor,
    required this.highlightColor,
    required this.shadowColor,
  });

  /// Creates a copy of this theme with the given fields replaced
  ReadingTheme copyWith({
    String? name,
    Color? backgroundColor,
    Color? textColor,
    Color? accentColor,
    Color? dividerColor,
    Color? selectionColor,
    Color? secondaryTextColor,
    Color? highlightColor,
    Color? shadowColor,
  }) {
    return ReadingTheme(
      name: name ?? this.name,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      textColor: textColor ?? this.textColor,
      accentColor: accentColor ?? this.accentColor,
      dividerColor: dividerColor ?? this.dividerColor,
      selectionColor: selectionColor ?? this.selectionColor,
      secondaryTextColor: secondaryTextColor ?? this.secondaryTextColor,
      highlightColor: highlightColor ?? this.highlightColor,
      shadowColor: shadowColor ?? this.shadowColor,
    );
  }

  /// Creates a theme with inverted colors
  ReadingTheme createInvertedTheme() {
    return ReadingTheme(
      name: '$name (Inverted)',
      backgroundColor: textColor,
      textColor: backgroundColor,
      accentColor: accentColor,
      dividerColor: dividerColor,
      selectionColor: selectionColor,
      secondaryTextColor: secondaryTextColor,
      highlightColor: highlightColor,
      shadowColor: shadowColor,
    );
  }

  /// Creates a high contrast version of this theme
  ReadingTheme createHighContrastTheme() {
    return ReadingTheme(
      name: '$name (High Contrast)',
      backgroundColor: backgroundColor.computeLuminance() > 0.5
          ? Colors.black
          : Colors.white,
      textColor: backgroundColor.computeLuminance() > 0.5
          ? Colors.white
          : Colors.black,
      accentColor: Colors.yellow,
      dividerColor: Colors.yellow,
      selectionColor: Colors.yellow.withOpacity(0.7),
      secondaryTextColor: Colors.yellow,
      highlightColor: Colors.yellow.withOpacity(0.7),
      shadowColor: Colors.yellow.withOpacity(0.5),
    );
  }

  /// Creates a theme with adjusted color temperature
  ReadingTheme createColorTemperatureTheme({required bool isWarm}) {
    if (isWarm) {
      return ReadingTheme(
        name: '$name (Warm)',
        backgroundColor: _adjustColorTemperature(backgroundColor, isWarm: true),
        textColor: _adjustColorTemperature(textColor, isWarm: true),
        accentColor: _adjustColorTemperature(accentColor, isWarm: true),
        dividerColor: _adjustColorTemperature(dividerColor, isWarm: true),
        selectionColor: _adjustColorTemperature(selectionColor, isWarm: true),
        secondaryTextColor: _adjustColorTemperature(
          secondaryTextColor,
          isWarm: true,
        ),
        highlightColor: _adjustColorTemperature(highlightColor, isWarm: true),
        shadowColor: _adjustColorTemperature(shadowColor, isWarm: true),
      );
    } else {
      return ReadingTheme(
        name: '$name (Cool)',
        backgroundColor: _adjustColorTemperature(
          backgroundColor,
          isWarm: false,
        ),
        textColor: _adjustColorTemperature(textColor, isWarm: false),
        accentColor: _adjustColorTemperature(accentColor, isWarm: false),
        dividerColor: _adjustColorTemperature(dividerColor, isWarm: false),
        selectionColor: _adjustColorTemperature(selectionColor, isWarm: false),
        secondaryTextColor: _adjustColorTemperature(
          secondaryTextColor,
          isWarm: false,
        ),
        highlightColor: _adjustColorTemperature(highlightColor, isWarm: false),
        shadowColor: _adjustColorTemperature(shadowColor, isWarm: false),
      );
    }
  }

  /// Adjusts color temperature (warm = more red/yellow, cool = more blue)
  Color _adjustColorTemperature(Color color, {required bool isWarm}) {
    if (isWarm) {
      // Increase red and yellow components
      return Color.fromARGB(
        color.alpha,
        (color.red * 1.1).clamp(0, 255).round(),
        (color.green * 1.05).clamp(0, 255).round(),
        (color.blue * 0.9).clamp(0, 255).round(),
      );
    } else {
      // Increase blue component
      return Color.fromARGB(
        color.alpha,
        (color.red * 0.9).clamp(0, 255).round(),
        (color.green * 0.95).clamp(0, 255).round(),
        (color.blue * 1.1).clamp(0, 255).round(),
      );
    }
  }

  /// Converts theme to JSON for storage/export
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'backgroundColor': backgroundColor.value,
      'textColor': textColor.value,
      'accentColor': accentColor.value,
      'dividerColor': dividerColor.value,
      'selectionColor': selectionColor.value,
      'secondaryTextColor': secondaryTextColor.value,
      'highlightColor': highlightColor.value,
      'shadowColor': shadowColor.value,
    };
  }

  /// Creates theme from JSON
  factory ReadingTheme.fromJson(Map<String, dynamic> json) {
    return ReadingTheme(
      name: json['name'] as String,
      backgroundColor: Color(json['backgroundColor'] as int),
      textColor: Color(json['textColor'] as int),
      accentColor: Color(json['accentColor'] as int),
      dividerColor: Color(json['dividerColor'] as int),
      selectionColor: Color(json['selectionColor'] as int),
      secondaryTextColor: Color(json['secondaryTextColor'] as int),
      highlightColor: Color(json['highlightColor'] as int),
      shadowColor: Color(json['shadowColor'] as int),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ReadingTheme &&
        other.name == name &&
        other.backgroundColor == backgroundColor &&
        other.textColor == textColor &&
        other.accentColor == accentColor &&
        other.dividerColor == dividerColor &&
        other.selectionColor == selectionColor &&
        other.secondaryTextColor == secondaryTextColor &&
        other.highlightColor == highlightColor;
  }

  @override
  int get hashCode {
    return Object.hash(
      name,
      backgroundColor,
      textColor,
      accentColor,
      dividerColor,
      selectionColor,
      secondaryTextColor,
      highlightColor,
    );
  }

  @override
  String toString() {
    return 'ReadingTheme(name: $name, backgroundColor: $backgroundColor, textColor: $textColor)';
  }
}
