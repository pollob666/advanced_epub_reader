import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:html/dom.dart' as html_dom;
import 'reading_theme.dart';
import 'font_utils.dart';

/// HTML manipulation utilities for EPUB content
class HtmlUtils {
  /// Injects font styles into HTML content (returns modified HTML string)
  static String injectFontStyles(
    String content,
    String fontFamily,
    double fontSize,
    double lineHeight,
  ) {
    debugPrint('=== Font Injection Debug ===');
    debugPrint('HTML has <head>: ${content.contains('<head>')}');
    debugPrint('HTML has <body>: ${content.contains('<body>')}');
    debugPrint('HTML has <html>: ${content.contains('<html>')}');

    try {
      // Parse the HTML content
      final document = html_parser.parse(content);
      debugPrint('Document nodes count: ${document.nodes.length}');

      // Find or create the head element
      html_dom.Element? headElement = document.querySelector('head');
      if (headElement == null) {
        debugPrint('No <head> tag found, creating one');
        headElement = html_dom.Element.tag('head');
        document.nodes.insert(0, headElement);
      } else {
        debugPrint('Found existing <head> tag');
      }

      // Create the style element with font styles
      final styleElement = html_dom.Element.tag('style');
      styleElement.text =
          '''
        * {
          font-family: ${FontUtils.getPrimaryFontFamily(fontFamily)} !important;
          font-size: ${fontSize}px !important;
          line-height: ${lineHeight} !important;
        }
        body {
          font-family: ${FontUtils.getPrimaryFontFamily(fontFamily)} !important;
          font-size: ${fontSize}px !important;
          line-height: ${lineHeight} !important;
        }
        p, div, span, h1, h2, h3, h4, h5, h6 {
          font-family: ${FontUtils.getPrimaryFontFamily(fontFamily)} !important;
          font-size: ${fontSize}px !important;
          line-height: ${lineHeight} !important;
        }
      ''';

      // Append the style element to the head
      headElement.children.add(styleElement);
      debugPrint('Style element appended to <head>');

      // Check for any existing inline font styles
      final elementsWithInlineStyles = document.querySelectorAll(
        '[style*="font"]',
      );
      debugPrint(
        'Found ${elementsWithInlineStyles.length} elements with inline font styles',
      );

      // Convert back to string
      final modifiedContent = document.outerHtml;
      debugPrint('CSS injected successfully for font: $fontFamily');
      debugPrint('Final HTML length: ${modifiedContent.length}');
      debugPrint('=== End Font Injection Debug ===');

      return modifiedContent;
    } catch (e) {
      debugPrint('Font injection failed: $e');
      // Return original content if injection fails
      return content;
    }
  }

  /// Builds content with injected font styles
  static Widget buildContentWithInjectedFont(
    String fontFamily,
    double fontSize,
    double lineHeight,
    String content,
    ReadingTheme theme,
    OnTap? onLinkTap,
  ) {
    debugPrint('=== Font Injection Debug ===');
    debugPrint('HTML has <head>: ${content.contains('<head>')}');
    debugPrint('HTML has <body>: ${content.contains('<body>')}');
    debugPrint('HTML has <html>: ${content.contains('<html>')}');

    try {
      // Parse the HTML content
      final document = html_parser.parse(content);
      debugPrint('Document nodes count: ${document.nodes.length}');

      // Find or create the head element
      html_dom.Element? headElement = document.querySelector('head');
      if (headElement == null) {
        debugPrint('No <head> tag found, creating one');
        headElement = html_dom.Element.tag('head');
        document.nodes.insert(0, headElement);
      } else {
        debugPrint('Found existing <head> tag');
      }

      // Create the style element with font styles
      final styleElement = html_dom.Element.tag('style');
      styleElement.text =
          '''
        * {
          font-family: ${FontUtils.getPrimaryFontFamily(fontFamily)} !important;
          font-size: ${fontSize}px !important;
          line-height: ${lineHeight} !important;
        }
        body {
          font-family: ${FontUtils.getPrimaryFontFamily(fontFamily)} !important;
          font-size: ${fontSize}px !important;
          line-height: ${lineHeight} !important;
        }
        p, div, span, h1, h2, h3, h4, h5, h6 {
          font-family: ${FontUtils.getPrimaryFontFamily(fontFamily)} !important;
          font-size: ${fontSize}px !important;
          line-height: ${lineHeight} !important;
        }
      ''';

      // Append the style element to the head
      headElement.children.add(styleElement);
      debugPrint('Style element appended to <head>');

      // Check for any existing inline font styles
      final elementsWithInlineStyles = document.querySelectorAll(
        '[style*="font"]',
      );
      debugPrint(
        'Found ${elementsWithInlineStyles.length} elements with inline font styles',
      );

      // Convert back to string
      final modifiedContent = document.outerHtml;
      debugPrint('CSS injected successfully for font: $fontFamily');
      debugPrint('Final HTML length: ${modifiedContent.length}');
      debugPrint('=== End Font Injection Debug ===');

      // Note: This would need to call back to EpubContentBuilder.buildContentWithFont
      // For now, return a simple text widget as fallback
      return DefaultTextStyle(
        style: TextStyle(
          fontFamily: fontFamily,
          fontSize: fontSize,
          height: lineHeight,
          color: theme.textColor,
        ),
        child: Text(modifiedContent),
      );
    } catch (e) {
      debugPrint('Font injection failed: $e');
      // Fallback to regular content building
      return DefaultTextStyle(
        style: TextStyle(
          fontFamily: fontFamily,
          fontSize: fontSize,
          height: lineHeight,
          color: theme.textColor,
        ),
        child: Text(content),
      );
    }
  }
}
