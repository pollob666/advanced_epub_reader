import 'package:flutter/material.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:html/dom.dart' as html_dom;

/// Utility functions for processing highlights, bookmarks, and notes in EPUB content
class HighlightUtils {
  /// Adds visual user highlight indicators to the content (lightweight, first occurrence)
  static String addHighlightIndicators(
    String content,
    List<Map<String, dynamic>>? highlights,
  ) {
    if (highlights == null || highlights.isEmpty) {
      return content;
    }

    try {
      final document = html_parser.parse(content);
      final body = document.querySelector('body');
      if (body == null) return content;

      final sorted = [...highlights];
      sorted.sort((a, b) {
        final pa = (a['position'] as double?) ?? 0;
        final pb = (b['position'] as double?) ?? 0;
        return pa.compareTo(pb);
      });

      for (final hl in sorted) {
        final text = hl['text'] as String?;
        if (text == null || text.isEmpty) continue;

        // Skip very long highlights that might cause performance issues
        if (text.length > 500) {
          debugPrint(
            '[Perf][ContentBuilder] Skipping long highlight: ${text.length} chars',
          );
          continue;
        }

        final applied = _addHighlightToTextNodes(body, text, hl);
        if (!applied) {
          _applyCrossBlockHighlightWithGap(body, text, hl);
        }
      }
      return document.outerHtml;
    } catch (e) {
      debugPrint('Failed to add user highlight indicators: $e');
      return content;
    }
  }

  /// Adds visual bookmark indicators to the content
  static String addBookmarkIndicators(
    String content,
    List<Map<String, dynamic>>? bookmarks,
  ) {
    if (bookmarks == null || bookmarks.isEmpty) {
      return content;
    }

    try {
      final document = html_parser.parse(content);
      final body = document.querySelector('body');
      if (body == null) return content;

      // Process each bookmark
      for (final bookmark in bookmarks) {
        final excerpt = bookmark['excerpt'] as String?;
        if (excerpt == null || excerpt.isEmpty) continue;

        // Find text nodes containing the excerpt
        _addBookmarkToTextNodes(body, excerpt);
      }

      return document.outerHtml;
    } catch (e) {
      debugPrint('Failed to add bookmark indicators: $e');
      return content; // Return original content if parsing fails
    }
  }

  /// Adds visual note indicators to the content
  static String addNoteIndicators(
    String content,
    List<Map<String, dynamic>>? notes,
  ) {
    if (notes == null || notes.isEmpty) {
      return content;
    }

    try {
      final document = html_parser.parse(content);
      final body = document.querySelector('body');
      if (body == null) return content;

      // Sort notes by position if available to stabilize rendering
      final sorted = [...notes];
      sorted.sort((a, b) {
        final pa = (a['position'] as double?) ?? 0;
        final pb = (b['position'] as double?) ?? 0;
        return pa.compareTo(pb);
      });

      // Process each note
      for (final note in sorted) {
        final selectedText = note['selectedText'] as String?;
        if (selectedText == null || selectedText.isEmpty) continue;

        // Find text nodes containing the selected text
        _addNoteToTextNodes(body, selectedText, note);
      }

      return document.outerHtml;
    } catch (e) {
      debugPrint('Failed to add note indicators: $e');
      return content; // Return original content if parsing fails
    }
  }

  /// Cross-block highlighter with visible gap fill between paragraphs.
  static void _applyCrossBlockHighlightWithGap(
    html_dom.Element root,
    String selectedText,
    Map<String, dynamic> hl,
  ) {
    final color = hl['color'] as String?;
    final colorClass = color != null
        ? 'highlight-indicator-$color'
        : 'highlight-indicator';
    final bg = (() {
      if (color == null) return 'rgba(255, 87, 34, 0.28)';
      String h = color.startsWith('#') ? color.substring(1) : color;
      if (h.length != 6) return 'rgba(255, 87, 34, 0.28)';
      final r = int.tryParse(h.substring(0, 2), radix: 16) ?? 255;
      final g = int.tryParse(h.substring(2, 4), radix: 16) ?? 87;
      final b = int.tryParse(h.substring(4, 6), radix: 16) ?? 34;
      return 'rgba($r, $g, $b, 0.28)';
    })();
    final nodes = <html_dom.Text>[];
    void collect(html_dom.Node n) {
      if (n is html_dom.Text && n.text.isNotEmpty) {
        // Skip empty text nodes
        nodes.add(n);
      } else if (n is html_dom.Element) {
        for (final c in n.nodes) {
          collect(c);
        }
      }
    }

    collect(root);
    // Build the concatenated plain text from all text nodes (no separators, matching plainText behavior)
    final fullPlain = nodes.map((n) => n.text).join('');
    final globalStart = fullPlain.indexOf(selectedText);
    if (globalStart == -1) {
      debugPrint(
        'Highlight text not found in concatenated content: $selectedText',
      );
      return;
    }
    final globalEnd = globalStart + selectedText.length;
    // Find si, so, ei, eo using cumulative offsets
    int cum = 0;
    int si = -1;
    int so = -1;
    int ei = -1;
    int eo = -1;
    for (int i = 0; i < nodes.length; i++) {
      final t = nodes[i].text;
      final len = t.length;
      if (si == -1 && cum + len > globalStart) {
        si = i;
        so = globalStart - cum;
      }
      if (cum + len > globalEnd) {
        ei = i;
        eo = globalEnd - cum;
        break;
      }
      cum += len;
    }
    if (si == -1 || ei == -1) return;
    // Same node: wrap fragment directly
    if (si == ei) {
      final node = nodes[si];
      final text = node.text;
      final before = text.substring(0, so);
      final mid = text.substring(so, eo);
      final after = text.substring(eo);
      node.replaceWith(
        html_dom.Element.html(
          '<span>$before<span class="$colorClass" style="background-color: $bg; padding: 1px 2px;" title="Highlight">$mid</span>$after</span>',
        ),
      );
      return;
    }
    // Wrap tail of start node
    final sNode = nodes[si];
    final sText = sNode.text;
    final sBefore = sText.substring(0, so);
    final sMid = sText.substring(so);
    sNode.replaceWith(
      html_dom.Element.html(
        '<span>$sBefore<span class="$colorClass" style="background-color: $bg; padding: 1px 2px;" title="Highlight">$sMid</span></span>',
      ),
    );
    // Wrap head of end node
    final eNode = nodes[ei];
    final eText = eNode.text;
    final eMid = eText.substring(0, eo);
    final eAfter = eText.substring(eo);
    eNode.replaceWith(
      html_dom.Element.html(
        '<span><span class="$colorClass" style="background-color: $bg; padding: 1px 2px;" title="Highlight">$eMid</span>$eAfter</span>',
      ),
    );
    // Wrap full middle nodes
    for (int i = si + 1; i < ei; i++) {
      final mNode = nodes[i];
      final mText = mNode.text;
      mNode.replaceWith(
        html_dom.Element.html(
          '<span class="$colorClass" style="background-color: $bg; padding: 1px 2px;" title="Highlight">$mText</span>',
        ),
      );
    }
    // Insert a visible gap fill between closest block ancestors if they differ
    html_dom.Element? findBlock(html_dom.Node? n) {
      html_dom.Node? cur = n;
      while (cur != null && cur is! html_dom.Document) {
        if (cur is html_dom.Element) {
          final tag = cur.localName?.toLowerCase();
          if (['p', 'div', 'li', 'section'].contains(tag)) {
            return cur;
          }
        }
        cur = cur.parent;
      }
      return null;
    }

    final sBlock = findBlock(nodes[si].parent);
    final eBlock = findBlock(nodes[ei].parent);
    if (sBlock != null && eBlock != null && sBlock != eBlock) {
      final parent = sBlock.parent;
      if (parent != null) {
        final insertIndex = parent.children.indexOf(sBlock) + 1;
        parent.children.insert(
          insertIndex,
          html_dom.Element.html(
            '<div class="highlight-gap" style="background-color: $bg; height: 0.6em; margin: 0.1em 0;"></div>',
          ),
        );
      }
    }
  }

  static bool _addHighlightToTextNodes(
    html_dom.Element element,
    String target,
    Map<String, dynamic> hl,
  ) {
    for (final node in element.nodes) {
      if (node is html_dom.Text) {
        final text = node.text;
        if (text.contains(target)) {
          final color = hl['color'] as String?; // '#RRGGBB'
          // Use class-based color and inline background to be robust
          final colorClass = color != null
              ? 'highlight-indicator-$color'
              : 'highlight-indicator';
          String bg;
          if (color != null && color.length == 7 && color.startsWith('#')) {
            final r = int.tryParse(color.substring(1, 3), radix: 16) ?? 255;
            final g = int.tryParse(color.substring(3, 5), radix: 16) ?? 87;
            final b = int.tryParse(color.substring(5, 7), radix: 16) ?? 34;
            bg = 'rgba($r, $g, $b, 0.28)';
          } else {
            bg = 'rgba(255, 87, 34, 0.25)';
          }
          final highlightedText = text.replaceFirst(
            target,
            '<span class="$colorClass" style="background-color: $bg; padding: 1px 2px;" title="Highlight">$target</span>',
          );
          final newElement = html_dom.Element.html(
            '<span>$highlightedText</span>',
          );
          node.replaceWith(newElement);
          return true;
        }
      } else if (node is html_dom.Element) {
        final found = _addHighlightToTextNodes(node, target, hl);
        if (found) return true;
      }
    }
    return false;
  }

  /// Adds bookmark indicators to text nodes containing the excerpt
  static void _addBookmarkToTextNodes(
    html_dom.Element element,
    String excerpt,
  ) {
    for (final node in element.nodes) {
      if (node is html_dom.Text) {
        final text = node.text;
        if (text.contains(excerpt)) {
          // Replace the text with a more elegant bookmark indicator
          final highlightedText = text.replaceFirst(
            excerpt,
            '<span class="bookmark-indicator" title="Bookmarked">$excerpt</span>',
          );

          // Create a new element with the highlighted content
          final newElement = html_dom.Element.html(
            '<span>$highlightedText</span>',
          );
          node.replaceWith(newElement);
        }
      } else if (node is html_dom.Element) {
        _addBookmarkToTextNodes(node, excerpt);
      }
    }
  }

  /// Adds note indicators to text nodes containing the selected text
  static void _addNoteToTextNodes(
    html_dom.Element element,
    String selectedText,
    Map<String, dynamic> note,
  ) {
    for (final node in element.nodes) {
      if (node is html_dom.Text) {
        final text = node.text;
        if (text.contains(selectedText)) {
          // Get note color for styling
          final color = note['color'] as String?;
          final colorClass = color != null
              ? 'highlight-indicator-$color'
              : 'highlight-indicator';

          // Replace the text with a note indicator
          final highlightedText = text.replaceFirst(
            selectedText,
            '<span class="$colorClass" title="Note: ${note['noteContent'] ?? 'No content'}">$selectedText</span>',
          );

          // Create a new element with the highlighted content
          final newElement = html_dom.Element.html(
            '<span>$highlightedText</span>',
          );
          node.replaceWith(newElement);
        }
      } else if (node is html_dom.Element) {
        _addNoteToTextNodes(node, selectedText, note);
      }
    }
  }
}
