import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import '../utils/reading_theme.dart';
import '../utils/font_utils.dart';
import '../utils/html_styles.dart';
import '../utils/highlight_utils.dart';

/// Handles building EPUB content with different rendering approaches
class EpubContentBuilder {
  /// Builds content with the selected font using multiple approaches
  static Widget buildContentWithFont(
    String fontFamily,
    double fontSize,
    double lineHeight,
    String content,
    ReadingTheme theme,
    OnTap? onLinkTap, {
    Key? selectionAreaKey,
    ValueNotifier<BuildContext?>? selectionChildContextNotifier,
    ValueChanged<String>? onTextSelected,
    int rebuildCounter = 0,
    List<Map<String, dynamic>>? bookmarks,
    List<Map<String, dynamic>>? notes,
    List<Map<String, dynamic>>? highlights,
  }) {
    try {
      // For Google Fonts, we need to wrap the content in a Google Fonts widget
      if (FontUtils.isGoogleFont(fontFamily)) {
        debugPrint('Using Google Fonts approach for: $fontFamily');
        return _buildWithGoogleFont(
          fontFamily,
          fontSize,
          lineHeight,
          content,
          theme,
          onLinkTap,
          selectionAreaKey: selectionAreaKey,
          selectionChildContextNotifier: selectionChildContextNotifier,
          rebuildCounter: rebuildCounter,
          onTextSelected: onTextSelected,
          bookmarks: bookmarks,
          notes: notes,
          highlights: highlights,
        );
      }

      // Fallback to regular HTML rendering for system fonts
      debugPrint('Using HTML rendering approach for: $fontFamily');
      return _buildWithHtml(
        fontFamily,
        fontSize,
        lineHeight,
        content,
        theme,
        onLinkTap,
        selectionAreaKey: selectionAreaKey,
        selectionChildContextNotifier: selectionChildContextNotifier,
        rebuildCounter: rebuildCounter,
        onTextSelected: onTextSelected,
        bookmarks: bookmarks,
        notes: notes,
        highlights: highlights,
      );
    } catch (e) {
      debugPrint('HTML rendering failed: $e');
      return _buildFallbackTextContent(
        fontFamily,
        fontSize,
        lineHeight,
        content,
        theme,
      );
    }
  }

  /// Builds content using Google Fonts
  static Widget _buildWithGoogleFont(
    String fontFamily,
    double fontSize,
    double lineHeight,
    String content,
    ReadingTheme theme,
    OnTap? onLinkTap, {
    Key? selectionAreaKey,
    ValueNotifier<BuildContext?>? selectionChildContextNotifier,
    int rebuildCounter = 0,
    ValueChanged<String>? onTextSelected,
    List<Map<String, dynamic>>? bookmarks,
    List<Map<String, dynamic>>? notes,
    List<Map<String, dynamic>>? highlights,
  }) {
    // Get the appropriate Google Font
    final googleFont = FontUtils.getGoogleFont(fontFamily, fontSize);

    // Create the final TextStyle that will be applied
    final finalTextStyle = googleFont.copyWith(
      fontSize: fontSize,
      height: lineHeight,
      color: theme.textColor,
    );

    // Clean the HTML content to remove any inline font styles that might override our Google Fonts
    final cleanedContent = FontUtils.stripInlineFontStyles(content);
    debugPrint(
      '🧹 Cleaned HTML content for Google Fonts - removed inline font styles',
    );

    return SelectionArea(
      key: selectionAreaKey,
      contextMenuBuilder: (context, selectableRegionState) {
        return const SizedBox.shrink();
      },
      onSelectionChanged: (selection) {
        try {
          final selectedText = selection?.plainText ?? '';
          if (selectedText.isNotEmpty) {
            debugPrint(
              '[SelectionArea] Selection made: "${selectedText.length > 120 ? selectedText.substring(0, 120) + '…' : selectedText}"',
            );
            onTextSelected?.call(selectedText);
          } else {
            debugPrint('[SelectionArea] Selection cleared');
            onTextSelected?.call('');
          }
        } catch (e) {
          debugPrint('[SelectionArea] Error during selection: $e');
        }
      },
      child: Builder(
        builder: (ctx) {
          selectionChildContextNotifier?.value = ctx;
          return DefaultTextStyle(
            style: finalTextStyle,
            child: Html(
              key: ValueKey(
                '$fontFamily$fontSize$lineHeight${cleanedContent.length}${theme.name}#r$rebuildCounter',
              ),
              data: HighlightUtils.addHighlightIndicators(
                cleanedContent,
                highlights,
              ),
              style: {
                "*": Style(
                  whiteSpace: WhiteSpace.pre, // ✅ Preserve line breaks
                ),
                ...HtmlStyles.buildHtmlStylesForGoogleFonts(
                  fontSize,
                  lineHeight,
                  theme,
                ),
              },
              onLinkTap: onLinkTap,
            ),
          );
        },
      ),
    );
  }

  /// Builds content using regular HTML rendering (for system fonts)
  static Widget _buildWithHtml(
    String fontFamily,
    double fontSize,
    double lineHeight,
    String content,
    ReadingTheme theme,
    OnTap? onLinkTap, {
    Key? selectionAreaKey,
    ValueNotifier<BuildContext?>? selectionChildContextNotifier,
    int rebuildCounter = 0,
    ValueChanged<String>? onTextSelected,
    List<Map<String, dynamic>>? bookmarks,
    List<Map<String, dynamic>>? notes,
    List<Map<String, dynamic>>? highlights,
  }) {
    return SelectionArea(
      key: selectionAreaKey,
      contextMenuBuilder: (context, selectableRegionState) {
        return const SizedBox.shrink();
      },
      onSelectionChanged: (selection) {
        try {
          final selectedText = selection?.plainText ?? '';
          if (selectedText.isNotEmpty) {
            debugPrint(
              '[SelectionArea] Selection made: "${selectedText.length > 120 ? selectedText.substring(0, 120) + '…' : selectedText}"',
            );
            onTextSelected?.call(selectedText);
          } else {
            debugPrint('[SelectionArea] Selection cleared');
            onTextSelected?.call('');
          }
        } catch (e) {
          debugPrint('[SelectionArea] Error during selection: $e');
        }
      },
      child: Builder(
        builder: (ctx) {
          selectionChildContextNotifier?.value = ctx;
          return DefaultTextStyle(
            style: TextStyle(
              fontFamily: FontUtils.getPrimaryFontFamily(fontFamily),
              fontSize: fontSize,
              height: lineHeight,
              color: theme.textColor,
            ),
            child: Html(
              key: ValueKey(
                '$fontFamily$fontSize$lineHeight${content.length}${theme.name}#r$rebuildCounter',
              ),
              data: HighlightUtils.addHighlightIndicators(content, highlights),
              style: {
                "*": Style(
                  whiteSpace: WhiteSpace.pre, // ✅ Preserve line breaks
                ),
                ...HtmlStyles.buildHtmlStyles(
                  fontFamily,
                  fontSize,
                  lineHeight,
                  theme,
                ),
              },
              onLinkTap: onLinkTap,
            ),
          );
        },
      ),
    );
  }

  /// Builds fallback text content when HTML rendering fails
  static Widget _buildFallbackTextContent(
    String fontFamily,
    double fontSize,
    double lineHeight,
    String content,
    ReadingTheme theme,
  ) {
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
