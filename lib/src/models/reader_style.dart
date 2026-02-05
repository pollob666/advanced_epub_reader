import 'package:flutter/material.dart';

/// Comprehensive styling configuration for the EPUB reader
class ReaderStyle {
  // App Bar Styling
  final String? titleFontFamily;
  final double? titleFontSize;
  final FontWeight? titleFontWeight;
  final String? subtitleFontFamily;
  final double? subtitleFontSize;
  final FontWeight? subtitleFontWeight;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? borderColor;
  final EdgeInsets? padding;

  // Reading Controls Styling
  final String? controlsFontFamily;
  final double? controlsFontSize;
  final FontWeight? controlsFontWeight;
  final Color? controlsBackgroundColor;
  final Color? controlsTextColor;
  final Color? controlsAccentColor;
  final BorderRadius? controlsBorderRadius;
  final EdgeInsets? controlsPadding;

  // Content Styling
  final String? contentFontFamily;
  final double? contentFontSize;
  final double? contentLineHeight;
  final EdgeInsets? contentMargin;

  const ReaderStyle({
    // App Bar
    this.titleFontFamily,
    this.titleFontSize,
    this.titleFontWeight,
    this.subtitleFontFamily,
    this.subtitleFontSize,
    this.subtitleFontWeight,
    this.backgroundColor,
    this.textColor,
    this.borderColor,
    this.padding,

    // Reading Controls
    this.controlsFontFamily,
    this.controlsFontSize,
    this.controlsFontWeight,
    this.controlsBackgroundColor,
    this.controlsTextColor,
    this.controlsAccentColor,
    this.controlsBorderRadius,
    this.controlsPadding,

    // Content
    this.contentFontFamily,
    this.contentFontSize,
    this.contentLineHeight,
    this.contentMargin,
  });

  /// Creates a copy of this ReaderStyle with the given fields replaced
  ReaderStyle copyWith({
    // App Bar
    String? titleFontFamily,
    double? titleFontSize,
    FontWeight? titleFontWeight,
    String? subtitleFontFamily,
    double? subtitleFontSize,
    FontWeight? subtitleFontWeight,
    Color? backgroundColor,
    Color? textColor,
    Color? borderColor,
    EdgeInsets? padding,

    // Reading Controls
    String? controlsFontFamily,
    double? controlsFontSize,
    FontWeight? controlsFontWeight,
    Color? controlsBackgroundColor,
    Color? controlsTextColor,
    Color? controlsAccentColor,
    BorderRadius? controlsBorderRadius,
    EdgeInsets? controlsPadding,

    // Content
    String? contentFontFamily,
    double? contentFontSize,
    double? contentLineHeight,
    EdgeInsets? contentMargin,
  }) {
    return ReaderStyle(
      // App Bar
      titleFontFamily: titleFontFamily ?? this.titleFontFamily,
      titleFontSize: titleFontSize ?? this.titleFontSize,
      titleFontWeight: titleFontWeight ?? this.titleFontWeight,
      subtitleFontFamily: subtitleFontFamily ?? this.subtitleFontFamily,
      subtitleFontSize: subtitleFontSize ?? this.subtitleFontSize,
      subtitleFontWeight: subtitleFontWeight ?? this.subtitleFontWeight,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      textColor: textColor ?? this.textColor,
      borderColor: borderColor ?? this.borderColor,
      padding: padding ?? this.padding,

      // Reading Controls
      controlsFontFamily: controlsFontFamily ?? this.controlsFontFamily,
      controlsFontSize: controlsFontSize ?? this.controlsFontSize,
      controlsFontWeight: controlsFontWeight ?? this.controlsFontWeight,
      controlsBackgroundColor:
          controlsBackgroundColor ?? this.controlsBackgroundColor,
      controlsTextColor: controlsTextColor ?? this.controlsTextColor,
      controlsAccentColor: controlsAccentColor ?? this.controlsAccentColor,
      controlsBorderRadius: controlsBorderRadius ?? this.controlsBorderRadius,
      controlsPadding: controlsPadding ?? this.controlsPadding,

      // Content
      contentFontFamily: contentFontFamily ?? this.contentFontFamily,
      contentFontSize: contentFontSize ?? this.contentFontSize,
      contentLineHeight: contentLineHeight ?? this.contentLineHeight,
      contentMargin: contentMargin ?? this.contentMargin,
    );
  }
}

/// Legacy AppBarStyle for backward compatibility
@Deprecated('Use ReaderStyle instead')
class AppBarStyle {
  final String? titleFontFamily;
  final double? titleFontSize;
  final FontWeight? titleFontWeight;
  final String? subtitleFontFamily;
  final double? subtitleFontSize;
  final FontWeight? subtitleFontWeight;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? borderColor;
  final EdgeInsets? padding;

  const AppBarStyle({
    this.titleFontFamily,
    this.titleFontSize,
    this.titleFontWeight,
    this.subtitleFontFamily,
    this.subtitleFontSize,
    this.subtitleFontWeight,
    this.backgroundColor,
    this.textColor,
    this.borderColor,
    this.padding,
  });

  /// Convert to ReaderStyle
  ReaderStyle toReaderStyle() => ReaderStyle(
    titleFontFamily: titleFontFamily,
    titleFontSize: titleFontSize,
    titleFontWeight: titleFontWeight,
    subtitleFontFamily: subtitleFontFamily,
    subtitleFontSize: subtitleFontSize,
    subtitleFontWeight: subtitleFontWeight,
    backgroundColor: backgroundColor,
    textColor: textColor,
    borderColor: borderColor,
    padding: padding,
  );
}
