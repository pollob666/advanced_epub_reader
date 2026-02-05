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

## EPUB Embedded Resources & Image Rendering

This release adds first-class support for rendering images that live inside the EPUB archive (for example images stored in OEBPS/images/...). The parser now collects raw bytes for every file inside the EPUB into a `resources` map on `EpubBook`. The HTML renderer will use those bytes to render images (including SVGs) directly from memory.

Key points

- `EpubBook.resources` is a Map<String, List<int>> where the key is the file path inside the EPUB (normalized to use `/`) and the value is the raw file bytes.
- The parser (`EpubParserService.parseFromFile` / `parseFromBytes`) populates `book.resources` automatically when an EPUB is parsed.
- `EpubContentBuilder` and `EpubViewer` support rendering images from `book.resources` (SVG/PNG/JPEG/JPG/GIF). `EpubViewer` already passes the `book.resources` map and the current chapter file path into the content builder so images referenced by relative URLs in XHTML chapters will resolve automatically.
- SVG rendering uses `flutter_svg` (already declared in `pubspec.yaml`). Raster images are rendered using `Image.memory(bytes)`. Data URIs and http(s) URLs are handled as well (data URIs are decoded; network URLs fall back to `Image.network`).

How it works (example usage)

1) Parse an EPUB to get an `EpubBook` (resources will be populated):

```dart
final book = await EpubParserService.parseFromFile('/path/to/book.epub');
```

2) Use `EpubViewer` (automatically wired):

```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => EpubViewer(
      book: book,
      initialChapterIndex: 0,
    ),
  ),
);
```

`EpubViewer` already passes `book.resources` and the current chapter's `filePath` to the content builder, so images in the chapter HTML like `<img src="images/cover.svg">` or `<img src="cover.png">` will be resolved and rendered.

3) If you use `EpubContentBuilder` directly, pass the resources map and the chapter file path: 

```dart
final widget = EpubContentBuilder.buildContentWithFont(
  fontFamily,
  fontSize,
  lineHeight,
  chapterHtmlContent,
  theme,
  onLinkTap,
  resources: book.resources, // map from path -> bytes
  chapterFilePath: chapter.filePath, // for resolving relative srcs
);
```

Direct access to resource bytes

If you want to access image bytes yourself (for example to do custom processing), you can read them directly from the map using the archive path key:

```dart
final bytes = book.resources['OEBPS/images/illustration.svg'];
if (bytes != null) {
  // Render manually (SVG example)
  final svgWidget = SvgPicture.memory(Uint8List.fromList(bytes));
}
```

Supported image sources and fallbacks

- data: URIs (inline base64) — decoded and rendered.
- EPUB internal resources (SVG/PNG/JPEG/JPG/GIF) — resolved against the chapter file path and manifest and rendered from memory.
- http(s) URLs — rendered with `Image.network`.
- Missing resources — the renderer will fall back gracefully (show alt text or nothing) and log a debug message.

Notes and caveats

- `EpubBook.resources` stores raw bytes for every entry in the EPUB archive; serializing this map to persistent storage may be large. If you plan to persist books and their resources, consider storing resources externally or selectively.
- SVG rendering requires `flutter_svg` (already included in this package's dependencies). Make sure your app's Flutter SDK is compatible with the pinned `flutter_svg` version in `pubspec.yaml`.
- Animated GIFs are supported by `Image.memory`, but rendering large or many animated images may impact memory and performance.

If you'd like, I can also add a short example test that loads a tiny EPUB fixture and asserts that `book.resources` contains expected keys, and a widget test that verifies an SVG and PNG are rendered via the content builder. Would you like me to add those tests now?

## Example

See the `example/` directory for a minimal working example. The `epub_reader_demo/` app shows a fuller integration and UI.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
