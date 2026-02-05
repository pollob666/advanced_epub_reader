import 'package:flutter/material.dart';
import '../utils/reading_theme.dart';
import '../utils/theme_manager.dart';

class SearchHighlightedPreview extends StatelessWidget {
  final String text;
  final String query;
  const SearchHighlightedPreview({
    super.key,
    required this.text,
    required this.query,
  });

  @override
  Widget build(BuildContext context) {
    final ReadingTheme rtheme = ThemeManager.getCurrentTheme();

    if (query.trim().isEmpty) {
      return Text(
        text,
        style: TextStyle(color: rtheme.textColor, fontSize: 14),
        softWrap: true,
        overflow: TextOverflow.ellipsis,
        maxLines: 3,
      );
    }

    final pattern = RegExp(RegExp.escape(query), caseSensitive: false);
    final spans = <TextSpan>[];
    int last = 0;

    for (final m in pattern.allMatches(text)) {
      if (m.start > last) {
        spans.add(
          TextSpan(
            text: text.substring(last, m.start),
            style: TextStyle(color: rtheme.textColor, fontSize: 14),
          ),
        );
      }
      spans.add(
        TextSpan(
          text: text.substring(m.start, m.end),
          style: TextStyle(
            backgroundColor: rtheme.highlightColor,
            color: rtheme.textColor,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      );
      last = m.end;
    }
    if (last < text.length) {
      spans.add(
        TextSpan(
          text: text.substring(last),
          style: TextStyle(color: rtheme.textColor, fontSize: 14),
        ),
      );
    }

    return RichText(
      text: TextSpan(children: spans),
      softWrap: true,
      overflow: TextOverflow.ellipsis,
      maxLines: 3,
    );
  }
}
