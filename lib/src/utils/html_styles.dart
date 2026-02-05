import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'reading_theme.dart';
import 'font_utils.dart';

/// HTML style definitions for EPUB content rendering
class HtmlStyles {
  /// Builds HTML styles for Google Fonts (without fontFamily since it's handled by DefaultTextStyle)
  static Map<String, Style> buildHtmlStylesForGoogleFonts(
    double fontSize,
    double lineHeight,
    ReadingTheme theme,
  ) {
    return {
      'body': Style(
        fontSize: FontSize(fontSize),
        lineHeight: LineHeight(lineHeight),
        color: theme.textColor,
        backgroundColor: theme.backgroundColor,
        margin: Margins.zero,
        padding: HtmlPaddings.zero,
      ),
      'p': Style(
        fontSize: FontSize(fontSize),
        lineHeight: LineHeight(lineHeight),
        margin: Margins.only(bottom: 16.0),
      ),
      'h1, h2, h3, h4, h5, h6': Style(
        fontSize: FontSize(fontSize * 1.2),
        fontWeight: FontWeight.bold,
        margin: Margins.only(bottom: 16.0),
      ),
      'a': Style(color: theme.textColor, textDecoration: TextDecoration.none),
      'blockquote': Style(
        fontStyle: FontStyle.italic,
        padding: HtmlPaddings.all(16.0),
        margin: Margins.only(bottom: 16.0),
      ),
      ..._getIndicatorStyles(),
      'div, span, td, th, li, ul, ol': Style(
        fontSize: FontSize(fontSize),
        lineHeight: LineHeight(lineHeight),
      ),
      '.pgheader, .pgfooter, .chapter, .content': Style(
        fontSize: FontSize(fontSize),
        lineHeight: LineHeight(lineHeight),
      ),
    };
  }

  /// Builds HTML styles for the content
  static Map<String, Style> buildHtmlStyles(
    String fontFamily,
    double fontSize,
    double lineHeight,
    ReadingTheme theme,
  ) {
    // Use a primary (single) font family name that Flutter can resolve
    final primaryFontFamily = FontUtils.getPrimaryFontFamily(fontFamily);

    return {
      // Apply to all elements
      '*': Style(
        fontFamily: primaryFontFamily,
        fontSize: FontSize(fontSize),
        lineHeight: LineHeight(lineHeight),
      ),
      'body': Style(
        fontFamily: primaryFontFamily,
        fontSize: FontSize(fontSize),
        lineHeight: LineHeight(lineHeight),
        color: theme.textColor,
        backgroundColor: theme.backgroundColor,
        margin: Margins.zero,
        padding: HtmlPaddings.zero,
      ),
      'p': Style(
        fontFamily: primaryFontFamily,
        fontSize: FontSize(fontSize),
        lineHeight: LineHeight(lineHeight),
        margin: Margins.only(bottom: 16.0),
      ),
      'h1, h2, h3, h4, h5, h6': Style(
        fontFamily: primaryFontFamily,
        fontSize: FontSize(fontSize * 1.2),
        fontWeight: FontWeight.bold,
        color: theme.textColor,
        margin: Margins.only(bottom: 16.0),
      ),
      'a': Style(
        fontFamily: primaryFontFamily,
        color: theme.textColor, // Use text color instead of accent color
        textDecoration: TextDecoration.none, // Remove underline
      ),
      'blockquote': Style(
        fontFamily: primaryFontFamily,
        fontStyle: FontStyle.italic,
        padding: HtmlPaddings.all(16.0),
        margin: Margins.only(bottom: 16.0),
      ),
      'div, span, td, th, li, ul, ol': Style(
        fontFamily: primaryFontFamily,
        fontSize: FontSize(fontSize),
        lineHeight: LineHeight(lineHeight),
      ),
      ..._getIndicatorStyles(),
      '.pgheader, .pgfooter, .chapter, .content': Style(
        fontFamily: primaryFontFamily,
        fontSize: FontSize(fontSize),
        lineHeight: LineHeight(lineHeight),
      ),
    };
  }

  /// Gets common indicator styles for bookmarks, notes, and highlights
  static Map<String, Style> _getIndicatorStyles() {
    return {
      '.bookmark-indicator': Style(
        display: Display.inlineBlock,
        padding: HtmlPaddings.symmetric(horizontal: 3.0, vertical: 1.0),
        backgroundColor: const Color(0x14FFC107), // rgba(255, 193, 7, 0.08)
        border: Border.all(
          color: const Color(0x33FFC107),
          width: 1.0,
        ), // rgba(255, 193, 7, 0.2)
      ),
      '.note-indicator': Style(
        display: Display.inlineBlock,
        padding: HtmlPaddings.symmetric(horizontal: 3.0, vertical: 1.0),
        backgroundColor: const Color(0x142196F3), // rgba(33, 150, 243, 0.08)
        border: Border.all(
          color: const Color(0x332196F3),
          width: 1.0,
        ), // rgba(33, 150, 243, 0.2)
      ),
      '.note-indicator-#FF5722': Style(
        display: Display.inlineBlock,
        padding: HtmlPaddings.symmetric(horizontal: 3.0, vertical: 1.0),
        backgroundColor: const Color(0x14FF5722), // Important - Red
        border: Border.all(color: const Color(0x33FF5722), width: 1.0),
      ),
      '.note-indicator-#2196F3': Style(
        display: Display.inlineBlock,
        padding: HtmlPaddings.symmetric(horizontal: 3.0, vertical: 1.0),
        backgroundColor: const Color(0x142196F3), // Question - Blue
        border: Border.all(color: const Color(0x332196F3), width: 1.0),
      ),
      '.note-indicator-#4CAF50': Style(
        display: Display.inlineBlock,
        padding: HtmlPaddings.symmetric(horizontal: 3.0, vertical: 1.0),
        backgroundColor: const Color(0x144CAF50), // Idea - Green
        border: Border.all(color: const Color(0x334CAF50), width: 1.0),
      ),
      '.note-indicator-#9C27B0': Style(
        display: Display.inlineBlock,
        padding: HtmlPaddings.symmetric(horizontal: 3.0, vertical: 1.0),
        backgroundColor: const Color(0x149C27B0), // Quote - Purple
        border: Border.all(color: const Color(0x339C27B0), width: 1.0),
      ),
      '.note-indicator-#FF9800': Style(
        display: Display.inlineBlock,
        padding: HtmlPaddings.symmetric(horizontal: 3.0, vertical: 1.0),
        backgroundColor: const Color(0x14FF9800), // Personal - Orange
        border: Border.all(color: const Color(0x33FF9800), width: 1.0),
      ),
      '.note-indicator-#FFEB3B': Style(
        display: Display.inlineBlock,
        padding: HtmlPaddings.symmetric(horizontal: 3.0, vertical: 1.0),
        backgroundColor: const Color(0x14FFEB3B), // Yellow
        border: Border.all(color: const Color(0x33FFEB3B), width: 1.0),
      ),
      '.note-indicator-#E91E63': Style(
        display: Display.inlineBlock,
        padding: HtmlPaddings.symmetric(horizontal: 3.0, vertical: 1.0),
        backgroundColor: const Color(0x14E91E63), // Pink
        border: Border.all(color: const Color(0x33E91E63), width: 1.0),
      ),
      '.note-indicator-#3F51B5': Style(
        display: Display.inlineBlock,
        padding: HtmlPaddings.symmetric(horizontal: 3.0, vertical: 1.0),
        backgroundColor: const Color(0x143F51B5), // Indigo
        border: Border.all(color: const Color(0x333F51B5), width: 1.0),
      ),
      '.note-indicator-#00BCD4': Style(
        display: Display.inlineBlock,
        padding: HtmlPaddings.symmetric(horizontal: 3.0, vertical: 1.0),
        backgroundColor: const Color(0x1400BCD4), // Cyan
        border: Border.all(color: const Color(0x3300BCD4), width: 1.0),
      ),
      // Highlight indicator styles
      '.highlight-indicator': Style(
        display: Display.inlineBlock,
        padding: HtmlPaddings.symmetric(horizontal: 3.0, vertical: 1.0),
        backgroundColor: const Color(0x14FF5722), // Default highlight color
      ),
      '.highlight-indicator-#FF5722': Style(
        display: Display.inlineBlock,
        padding: HtmlPaddings.symmetric(horizontal: 3.0, vertical: 1.0),
        backgroundColor: const Color(0x14FF5722), // Red
      ),
      '.highlight-indicator-#2196F3': Style(
        display: Display.inlineBlock,
        padding: HtmlPaddings.symmetric(horizontal: 3.0, vertical: 1.0),
        backgroundColor: const Color(0x142196F3), // Blue
      ),
      '.highlight-indicator-#4CAF50': Style(
        display: Display.inlineBlock,
        padding: HtmlPaddings.symmetric(horizontal: 3.0, vertical: 1.0),
        backgroundColor: const Color(0x144CAF50), // Green
      ),
      '.highlight-indicator-#9C27B0': Style(
        display: Display.inlineBlock,
        padding: HtmlPaddings.symmetric(horizontal: 3.0, vertical: 1.0),
        backgroundColor: const Color(0x149C27B0), // Purple
      ),
      '.highlight-indicator-#FF9800': Style(
        display: Display.inlineBlock,
        padding: HtmlPaddings.symmetric(horizontal: 3.0, vertical: 1.0),
        backgroundColor: const Color(0x14FF9800), // Orange
      ),
      '.highlight-indicator-#FFEB3B': Style(
        display: Display.inlineBlock,
        padding: HtmlPaddings.symmetric(horizontal: 3.0, vertical: 1.0),
        backgroundColor: const Color(0x14FFEB3B), // Yellow
      ),
      '.highlight-indicator-#E91E63': Style(
        display: Display.inlineBlock,
        padding: HtmlPaddings.symmetric(horizontal: 3.0, vertical: 1.0),
        backgroundColor: const Color(0x14E91E63), // Pink
      ),
      '.highlight-indicator-#3F51B5': Style(
        display: Display.inlineBlock,
        padding: HtmlPaddings.symmetric(horizontal: 3.0, vertical: 1.0),
        backgroundColor: const Color(0x143F51B5), // Indigo
      ),
      '.highlight-indicator-#00BCD4': Style(
        display: Display.inlineBlock,
        padding: HtmlPaddings.symmetric(horizontal: 3.0, vertical: 1.0),
        backgroundColor: const Color(0x1400BCD4), // Cyan
      ),
    };
  }
}
