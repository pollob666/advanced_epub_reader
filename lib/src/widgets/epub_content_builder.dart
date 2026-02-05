import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:typed_data';
import 'dart:convert';
import '../utils/reading_theme.dart';
import '../utils/font_utils.dart';
import '../utils/html_styles.dart';
import '../utils/highlight_utils.dart';
import '../utils/epub_utils.dart';

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
    // New optional EPUB resources map (key = path inside EPUB, value = bytes)
    Map<String, List<int>>? resources,
    // Chapter file path within the EPUB, used to resolve relative image srcs
    String? chapterFilePath,
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
          resources: resources,
          chapterFilePath: chapterFilePath,
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
        resources: resources,
        chapterFilePath: chapterFilePath,
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
    Map<String, List<int>>? resources,
    String? chapterFilePath,
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
              '[SelectionArea] Selection made: "${selectedText.length > 120 ? '${selectedText.substring(0, 120)}…' : selectedText}"',
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
          final styleMap = Map<String, Style>.from(
            HtmlStyles.buildHtmlStylesForGoogleFonts(
              fontSize,
              lineHeight,
              theme,
            ),
          );
          styleMap['*'] = Style(whiteSpace: WhiteSpace.pre);
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
              style: styleMap,
               // Provide our extension so image tags are rendered from EPUB resources when possible
               extensions: [EpubImageExtension(resources, chapterFilePath)],
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
    Map<String, List<int>>? resources,
    String? chapterFilePath,
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
              '[SelectionArea] Selection made: "${selectedText.length > 120 ? '${selectedText.substring(0, 120)}…' : selectedText}"',
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
          final styleMap = Map<String, Style>.from(
            HtmlStyles.buildHtmlStyles(
              fontFamily,
              fontSize,
              lineHeight,
              theme,
            ),
          );
          styleMap['*'] = Style(whiteSpace: WhiteSpace.pre);
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
               style: styleMap,
               // Provide our extension so image tags are rendered from EPUB resources when possible
               extensions: [EpubImageExtension(resources, chapterFilePath)],
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

  /// Resolve resource bytes for a given src using the resources map and chapter path
  static Uint8List? _resolveResourceBytes(
    Map<String, List<int>>? resources,
    String? chapterFilePath,
    String src,
  ) {
    if (resources == null) return null;

    // Normalize and attempt various resolutions
    String resolved = src;
    if (chapterFilePath != null && !src.startsWith('/')) {
      final dir = EpubUtils.getDirectoryPath(chapterFilePath);
      if (dir != '.') resolved = '$dir/$src';
    }
    resolved = resolved.replaceAll('\\', '/');

    Uint8List? bytes;

    // direct match
    if (resources.containsKey(resolved)) {
      bytes = Uint8List.fromList(resources[resolved]!);
      return bytes;
    }

    // try without leading ./
    if (resolved.startsWith('./')) {
      final alt = resolved.substring(2);
      if (resources.containsKey(alt)) return Uint8List.fromList(resources[alt]!);
    }

    // try with OEBPS/ prefix
    if (!resolved.startsWith('OEBPS/')) {
      final alt = 'OEBPS/$resolved';
      if (resources.containsKey(alt)) return Uint8List.fromList(resources[alt]!);
    }

    // filename-only
    final filename = resolved.split('/').last;
    for (final entry in resources.entries) {
      if (entry.key.endsWith('/$filename') || entry.key == filename) {
        return Uint8List.fromList(entry.value);
      }
    }

    return null;
  }

  /// Heuristic to determine if bytes are SVG
  static bool _isSvg(Uint8List bytes, String src) {
    final lc = src.toLowerCase();
    if (lc.endsWith('.svg')) return true;
    try {
      final head = utf8.decode(bytes.take(200).toList(), allowMalformed: true);
      return head.contains('<svg');
    } catch (_) {
      return false;
    }
  }
}

/// Extension that renders <img> tags using EPUB resource bytes when available.
class EpubImageExtension extends HtmlExtension {
  final Map<String, List<int>>? resources;
  final String? chapterFilePath;

  const EpubImageExtension(this.resources, this.chapterFilePath);

  @override
  Set<String> get supportedTags => {'img'};

  @override
  StyledElement prepare(ExtensionContext context, List<StyledElement> children) {
    final parsedWidth = double.tryParse(context.attributes['width'] ?? '');
    final parsedHeight = double.tryParse(context.attributes['height'] ?? '');

    return ImageElement(
      name: context.elementName,
      children: children,
      style: Style(),
      node: context.node,
      elementId: context.id,
      src: context.attributes['src'] ?? '',
      alt: context.attributes['alt'],
      width: parsedWidth != null ? Width(parsedWidth) : null,
      height: parsedHeight != null ? Height(parsedHeight) : null,
    );
  }

  static final RegExp dataUriFormat = RegExp(r"^(?<scheme>data):(?<mime>image/[\w+\-.]+);*(?<encoding>base64)?,\s*(?<data>.*)");

  @override
  InlineSpan build(ExtensionContext context) {
    final element = context.styledElement as ImageElement;

    final imageStyle = Style(
      width: element.width,
      height: element.height,
    ).merge(context.styledElement!.style);

    Widget child;

    final src = element.src;

    // Data URI
    final dataUri = dataUriFormat.firstMatch(src);
    if (dataUri != null && dataUri.namedGroup('mime') != 'image/svg+xml') {
      try {
        final decoded = base64.decode(dataUri.namedGroup('data')!.trim());
        child = Image.memory(
          Uint8List.fromList(decoded),
          width: imageStyle.width?.value,
          height: imageStyle.height?.value,
          fit: BoxFit.fill,
          errorBuilder: (ctx, error, stackTrace) {
            return Text(
              element.alt ?? '',
              style: context.styledElement!.style.generateTextStyle(),
            );
          },
        );
        return WidgetSpan(
          alignment: context.style!.verticalAlign.toPlaceholderAlignment(context.style!.display),
          baseline: TextBaseline.alphabetic,
          child: CssBoxWidget(
            style: imageStyle,
            childIsReplaced: true,
            child: child,
          ),
        );
      } catch (e) {
        // fall through to other handlers
      }
    }

    // Try resources map
    final bytes = EpubContentBuilder._resolveResourceBytes(resources, chapterFilePath, src);
    if (bytes != null) {
      if (EpubContentBuilder._isSvg(bytes, src)) {
        child = SvgPicture.memory(bytes);
      } else {
        child = Image.memory(
          bytes,
          width: imageStyle.width?.value,
          height: imageStyle.height?.value,
          fit: BoxFit.fill,
          errorBuilder: (ctx, error, stackTrace) {
            return Text(
              element.alt ?? '',
              style: context.styledElement!.style.generateTextStyle(),
            );
          },
        );
      }

      return WidgetSpan(
        alignment: context.style!.verticalAlign.toPlaceholderAlignment(context.style!.display),
        baseline: TextBaseline.alphabetic,
        child: CssBoxWidget(
          style: imageStyle,
          childIsReplaced: true,
          child: child,
        ),
      );
    }

    // Fallback to network/asset/base behavior handled by original ImageBuiltIn
    // Reuse ImageBuiltIn's logic by delegating to network rendering here
    // If it's a network URL, render network image; else render alt text
    final uri = Uri.tryParse(src);
    if (uri != null && (uri.scheme == 'http' || uri.scheme == 'https')) {
      child = Image.network(
        src,
        width: imageStyle.width?.value,
        height: imageStyle.height?.value,
        fit: BoxFit.fill,
        errorBuilder: (ctx, error, stackTrace) {
          return Text(
            element.alt ?? '',
            style: context.styledElement!.style.generateTextStyle(),
          );
        },
      );

      return WidgetSpan(
        alignment: context.style!.verticalAlign.toPlaceholderAlignment(context.style!.display),
        baseline: TextBaseline.alphabetic,
        child: CssBoxWidget(
          style: imageStyle,
          childIsReplaced: true,
          child: child,
        ),
      );
    }

    // Render a broken-image placeholder if nothing else matched
    final placeholder = Center(
      child: Icon(
        Icons.broken_image,
        size: (imageStyle.width?.value ?? 24).clamp(16.0, 64.0),
        color: Colors.grey,
      ),
    );

    return WidgetSpan(
      alignment: context.style!.verticalAlign.toPlaceholderAlignment(context.style!.display),
      baseline: TextBaseline.alphabetic,
      child: CssBoxWidget(
        style: imageStyle,
        childIsReplaced: true,
        child: placeholder,
      ),
    );
  }
}
