# Advanced EPUB Reader

A comprehensive Flutter package for reading EPUB books with advanced features: customizable themes and fonts, highlights, notes, bookmarks, progress tracking, search, and a smooth reader UI.

## Features

- 📚 **EPUB Support**: Parses container.xml and OPF; extracts metadata, manifest, spine, chapters, TOC, and cover
- 🎨 **Customizable Themes**: Reading themes, Google/system fonts, font size, line height, margins
- 🔖 **Bookmarks**: Save and organize reading positions via built-in sheets and callbacks
- ✏️ **Annotations**: Highlights (colors) and notes with lightweight visual indicators
- 🔎 **Search**: Full-text search across chapters with previews and navigation
- 📊 **Progress**: Page tracking and reading stats persisted with SharedPreferences
- 📱 **Responsive Design**: Works across mobile, desktop, and web
- 🚀 **Performance Optimized**: Fast approximate pagination and smooth scrolling

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  advanced_epub_reader: ^0.0.1
```

Then run:

```bash
flutter pub get
```

## Quick Start

```dart
import 'package:flutter/material.dart';
import 'package:advanced_epub_reader/advanced_epub_reader.dart';

class ReaderApp extends StatelessWidget {
  const ReaderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Builder(
        builder: (context) => Scaffold(
          appBar: AppBar(title: const Text('Advanced EPUB Reader')),
          body: Center(
            child: ElevatedButton(
              child: const Text('Open EPUB'),
              onPressed: () async {
                // 1) Parse EPUB file to EpubBook
                final book = await EpubParserService.parseFromFile(
                  '/absolute/path/to/your/book.epub',
                );

                // 2) Push the EpubViewer
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EpubViewer(
                      book: book,
                      initialChapterIndex: 0,
                      showControls: true,
                      showTableOfContents: true,
                      onProgressChanged: (progress) {},
                      onChapterChanged: (index) {},
                      onBookmarkSaved: ({
                        required int chapterIndex,
                        required double position,
                        required String selectedText,
                        String? title,
                      }) {},
                      onShowBookmarks: () {},
                      onNoteSaved: ({
                        required int chapterIndex,
                        required double position,
                        required String selectedText,
                        required String noteContent,
                        String? color,
                      }) {},
                      onShowNotes: () {},
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
```

## Architecture Overview

### Models

- `EpubBook`, `EpubChapter`, `EpubMetadata`, `ReadingProgress`
- `Highlight`, `Bookmark`, `Note`, `Annotation`, `AppBarStyle`

### Services

- `EpubParserService`: Parse EPUBs (ZIP via `archive`, XML via `xml`) into `EpubBook`
- `PageCalculationService`: Approximate pagination based on typography and viewport; caches results
- `ProgressService`: Persist and retrieve `ReadingProgress` via `SharedPreferences`
- `EpubSearchController`: Holds query/results and drives navigation to matches
- `HighlightService`, `BookmarkService`, `NoteService`, `AnnotationService`: Persist user annotations

### Rendering

- `EpubViewer`: Main reading widget orchestrating content, controls, TOC, selection, search, progress
- `EpubContentBuilder`: Renders HTML using `flutter_html`, integrates themes and fonts, preserves line breaks
- `ReadingControls`, `TableOfContents`/`ChaptersSheet`, `SelectionToolbar`, `HighlightSheet`, `BookmarkSheet`, `NoteSheet`

## Theming & Fonts

Apply a custom theme or change typography at runtime via `ThemeManager`.

```dart
final theme = ReadingTheme(
  name: 'Night',
  backgroundColor: Colors.black,
  textColor: Colors.white,
  accentColor: Colors.amber,
);

ThemeManager.setFontFamily('Merriweather');
ThemeManager.setFontSize(18.0);
ThemeManager.setLineHeight(1.6);
ThemeManager.setMargin(14.0);
```

## Search

`EpubViewer` wires an `EpubSearchController` to the reader controls, enabling query entry, results, and navigation. You can also host your own panel that updates the same controller.

## Persistence

- Progress is saved automatically via `ProgressService`
- Bookmarks/Notes/Highlights can be handled by built-in sheets and saved via the respective services and/or your own storage using the viewer callbacks

## Example

See the `example/` directory for a minimal working example. The `epub_reader_demo/` app shows a fuller integration and UI.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
