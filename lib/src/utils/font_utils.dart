import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:html/parser.dart' as html_parser;

/// Utility functions for font handling in EPUB content
class FontUtils {
  /// Checks if the font family is a Google Font
  static bool isGoogleFont(String fontFamily) {
    const googleFonts = ['Open Sans', 'Lato', 'Noto Sans', 'Merriweather'];
    return googleFonts.contains(fontFamily);
  }

  /// Gets the appropriate Google Font TextStyle
  static TextStyle getGoogleFont(String fontFamily, double fontSize) {
    debugPrint('🎨 Loading Google Font: "$fontFamily" with size $fontSize');

    switch (fontFamily) {
      case 'Open Sans':
        debugPrint('   → Using GoogleFonts.openSans()');
        return GoogleFonts.openSans(fontSize: fontSize);
      case 'Lato':
        debugPrint('   → Using GoogleFonts.lato()');
        return GoogleFonts.lato(fontSize: fontSize);
      case 'Noto Sans':
        debugPrint('   → Using GoogleFonts.notoSans()');
        return GoogleFonts.notoSans(fontSize: fontSize);
      case 'Merriweather':
        debugPrint('   → Using GoogleFonts.merriweather()');
        return GoogleFonts.merriweather(fontSize: fontSize);
      default:
        debugPrint('   → Using GoogleFonts.roboto() as fallback');
        return GoogleFonts.roboto(fontSize: fontSize);
    }
  }

  /// Maps a font family name to a CSS font-family value that works with flutter_html.
  /// This is necessary because flutter_html's fontFamily property expects a CSS value.
  static String getPrimaryFontFamily(String fontFamily) {
    switch (fontFamily) {
      case 'Roboto':
        return 'Roboto';
      case 'Open Sans':
        return 'Open Sans';
      case 'Lato':
        return 'Lato';
      case 'Noto Sans':
        return 'Noto Sans';
      case 'Merriweather':
        return 'Merriweather';
      case 'Georgia':
        return 'Georgia';
      case 'Times New Roman':
        return 'Times New Roman';
      case 'Arial':
        return 'Arial';
      case 'Helvetica':
        return 'Helvetica';
      case 'serif':
        return 'serif';
      case 'sans-serif':
        return 'sans-serif';
      case 'monospace':
        return 'monospace';
      case 'cursive':
        return 'cursive';
      case 'fantasy':
        return 'fantasy';
      default:
        return fontFamily;
    }
  }

  /// Strips inline font styles from HTML content to prevent conflicts with Google Fonts
  static String stripInlineFontStyles(String content) {
    try {
      final document = html_parser.parse(content);

      // Find all elements with inline styles
      final elementsWithStyles = document.querySelectorAll('[style]');
      debugPrint(
        'Found ${elementsWithStyles.length} elements with inline styles',
      );

      for (final element in elementsWithStyles) {
        final style = element.attributes['style'];
        if (style != null && style.contains('font-family')) {
          // Remove font-family from inline styles
          final newStyle = style.replaceAll(
            RegExp(r'font-family\s*:\s*[^;]+;?\s*'),
            '',
          );
          if (newStyle.trim().isEmpty) {
            element.attributes.remove('style');
          } else {
            element.attributes['style'] = newStyle;
          }
          debugPrint(
            'Removed font-family from inline style: $style → $newStyle',
          );
        }
      }

      return document.outerHtml;
    } catch (e) {
      debugPrint('Failed to strip inline font styles: $e');
      return content; // Return original content if parsing fails
    }
  }
}
