import 'package:flutter/material.dart';

/// Legacy AppBarStyle for backward compatibility
/// @Deprecated Use ReaderStyle instead
class AppBarStyle {
  /// Font family for the app bar title
  final String? titleFontFamily;

  /// Font size for the app bar title
  final double? titleFontSize;

  /// Font weight for the app bar title
  final FontWeight? titleFontWeight;

  /// Font family for the app bar subtitle (chapter info)
  final String? subtitleFontFamily;

  /// Font size for the app bar subtitle
  final double? subtitleFontSize;

  /// Font weight for the app bar subtitle
  final FontWeight? subtitleFontWeight;

  /// Background color for the app bar
  final Color? backgroundColor;

  /// Text color for the app bar
  final Color? textColor;

  /// Border color for the app bar
  final Color? borderColor;

  /// Padding for the app bar
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

  /// Creates a copy of this AppBarStyle with the given fields replaced
  AppBarStyle copyWith({
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
  }) {
    return AppBarStyle(
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
    );
  }
}
