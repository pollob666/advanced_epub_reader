import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:archive/archive.dart';
import 'package:xml/xml.dart';
import '../models/epub_book.dart';
import '../models/epub_metadata.dart';
import '../models/epub_chapter.dart';

/// Service for parsing EPUB files and extracting their content
class EpubParserService {
  /// Parses an EPUB file from a file path
  static Future<EpubBook> parseFromFile(String filePath) async {
    final file = File(filePath);
    if (!await file.exists()) {
      throw Exception('EPUB file not found: $filePath');
    }

    final bytes = await file.readAsBytes();
    return parseFromBytes(bytes, filePath: filePath);
  }

  /// Parses an EPUB file from bytes
  static EpubBook parseFromBytes(Uint8List bytes, {String? filePath}) {
    try {
      // Decode the ZIP archive
      final archive = ZipDecoder().decodeBytes(bytes);

      // Find the container.xml file
      final containerEntry = archive.findFile('META-INF/container.xml');
      if (containerEntry == null) {
        throw Exception('Invalid EPUB: container.xml not found');
      }

      // Parse container.xml to find the OPF file
      final containerXml = XmlDocument.parse(
        utf8.decode(containerEntry.content, allowMalformed: true),
      );
      final rootfileElement = containerXml
          .findAllElements('rootfile')
          .firstOrNull;
      if (rootfileElement == null) {
        throw Exception('Invalid EPUB: rootfile not found in container.xml');
      }

      final opfPath = rootfileElement.getAttribute('full-path');
      if (opfPath == null) {
        throw Exception(
          'Invalid EPUB: full-path attribute not found in rootfile',
        );
      }

      // Parse the OPF file
      final opfEntry = archive.findFile(opfPath);
      if (opfEntry == null) {
        throw Exception('Invalid EPUB: OPF file not found: $opfPath');
      }

      final opfXml = XmlDocument.parse(
        utf8.decode(opfEntry.content, allowMalformed: true),
      );

      // Extract metadata
      final metadata = _parseMetadata(opfXml);

      // Extract manifest and spine
      final manifest = _parseManifest(opfXml);
      final spine = _parseSpine(opfXml);

      // Debug output
      print('DEBUG: Manifest entries: ${manifest.length}');
      print('DEBUG: Spine entries: ${spine.length}');
      print('DEBUG: Manifest keys: ${manifest.keys.toList()}');
      print('DEBUG: Spine items: $spine');

      // Debug: List all files in the archive
      print('DEBUG: Files in archive:');
      for (final file in archive.files) {
        print('  - ${file.name}');
      }

      // Extract chapters
      final chapters = _parseChapters(archive, manifest, spine);

      // Extract table of contents
      final tableOfContents = _parseTableOfContents(archive, manifest);

      // Extract navigation
      final navigation = _parseNavigation(archive, manifest);

      // Extract cover image
      final coverImage = _extractCoverImage(archive, manifest);

      // Generate book ID
      final bookId =
          metadata.identifier ??
          '${metadata.title}_${DateTime.now().millisecondsSinceEpoch}';

      return EpubBook(
        id: bookId,
        metadata: metadata,
        chapters: chapters,
        coverImage: coverImage,
        spine: spine,
        manifest: manifest,
        tableOfContents: tableOfContents,
        navigation: navigation,
        filePath: filePath,
        fileSize: bytes.length,
        createdAt: DateTime.now(),
      );
    } catch (e) {
      throw Exception('Failed to parse EPUB: $e');
    }
  }

  /// Parses metadata from OPF XML
  static EpubMetadata _parseMetadata(XmlDocument opfXml) {
    final metadataElement = opfXml.findAllElements('metadata').firstOrNull;
    if (metadataElement == null) {
      throw Exception('Metadata element not found in OPF');
    }

    String? title;
    String? creator;
    String? publisher;
    String? language;
    String? identifier;
    String? description;
    List<String> subjects = [];
    String? rights;
    DateTime? date;
    String? contributor;
    String? coverage;
    String? format;
    String? relation;
    String? source;
    String? type;

    // Extract basic metadata
    title =
        _getElementText(metadataElement, 'dc:title') ??
        _getElementText(metadataElement, 'title');
    creator =
        _getElementText(metadataElement, 'dc:creator') ??
        _getElementText(metadataElement, 'creator');
    publisher =
        _getElementText(metadataElement, 'dc:publisher') ??
        _getElementText(metadataElement, 'publisher');
    language =
        _getElementText(metadataElement, 'dc:language') ??
        _getElementText(metadataElement, 'language');
    identifier =
        _getElementText(metadataElement, 'dc:identifier') ??
        _getElementText(metadataElement, 'identifier');
    description =
        _getElementText(metadataElement, 'dc:description') ??
        _getElementText(metadataElement, 'description');
    rights =
        _getElementText(metadataElement, 'dc:rights') ??
        _getElementText(metadataElement, 'rights');
    contributor =
        _getElementText(metadataElement, 'dc:contributor') ??
        _getElementText(metadataElement, 'contributor');
    coverage =
        _getElementText(metadataElement, 'dc:coverage') ??
        _getElementText(metadataElement, 'coverage');
    format =
        _getElementText(metadataElement, 'dc:format') ??
        _getElementText(metadataElement, 'format');
    relation =
        _getElementText(metadataElement, 'dc:relation') ??
        _getElementText(metadataElement, 'relation');
    source =
        _getElementText(metadataElement, 'dc:source') ??
        _getElementText(metadataElement, 'source');
    type =
        _getElementText(metadataElement, 'dc:type') ??
        _getElementText(metadataElement, 'type');

    // Extract subjects
    final subjectElements = metadataElement.findAllElements('dc:subject');
    subjects = subjectElements
        .map((e) => e.text.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    // Extract date
    final dateText =
        _getElementText(metadataElement, 'dc:date') ??
        _getElementText(metadataElement, 'date');
    if (dateText != null) {
      try {
        date = DateTime.parse(dateText);
      } catch (e) {
        // Try to parse common date formats
        final patterns = [
          'yyyy-MM-dd',
          'yyyy-MM-ddTHH:mm:ss',
          'yyyy-MM-ddTHH:mm:ssZ',
        ];
        for (final pattern in patterns) {
          try {
            // Simple date parsing - in production, use a proper date parsing library
            if (dateText.length >= 10) {
              final year = int.parse(dateText.substring(0, 4));
              final month = int.parse(dateText.substring(5, 7));
              final day = int.parse(dateText.substring(8, 10));
              date = DateTime(year, month, day);
              break;
            }
          } catch (e) {
            // Continue to next pattern
          }
        }
      }
    }

    if (title == null || title.isEmpty) {
      throw Exception('Book title not found in metadata');
    }

    return EpubMetadata(
      title: title,
      creator: creator,
      publisher: publisher,
      language: language,
      identifier: identifier,
      description: description,
      subjects: subjects,
      rights: rights,
      date: date,
      contributor: contributor,
      coverage: coverage,
      format: format,
      relation: relation,
      source: source,
      type: type,
    );
  }

  /// Parses manifest from OPF XML
  static Map<String, String> _parseManifest(XmlDocument opfXml) {
    final manifestElement = opfXml.findAllElements('manifest').firstOrNull;
    if (manifestElement == null) {
      throw Exception('Manifest element not found in OPF');
    }

    final manifest = <String, String>{};
    final itemElements = manifestElement.findAllElements('item');

    for (final item in itemElements) {
      final id = item.getAttribute('id');
      final href = item.getAttribute('href');
      if (id != null && href != null) {
        manifest[id] = href;
      }
    }

    return manifest;
  }

  /// Parses spine from OPF XML
  static List<String> _parseSpine(XmlDocument opfXml) {
    final spineElement = opfXml.findAllElements('spine').firstOrNull;
    if (spineElement == null) {
      throw Exception('Spine element not found in OPF');
    }

    final spine = <String>[];
    final itemrefElements = spineElement.findAllElements('itemref');

    for (final itemref in itemrefElements) {
      final idref = itemref.getAttribute('idref');
      if (idref != null) {
        spine.add(idref);
      }
    }

    return spine;
  }

  /// Parses chapters from archive
  static List<EpubChapter> _parseChapters(
    Archive archive,
    Map<String, String> manifest,
    List<String> spine,
  ) {
    final chapters = <EpubChapter>[];

    print('DEBUG: Starting chapter parsing...');
    print('DEBUG: Spine length: ${spine.length}');
    print('DEBUG: Manifest length: ${manifest.length}');

    for (int i = 0; i < spine.length; i++) {
      final id = spine[i];
      final href = manifest[id];
      print('DEBUG: Processing spine item $i: id=$id, href=$href');

      if (href == null) {
        print('DEBUG: No href found for id: $id');
        continue;
      }

      // Try to find the file with different path variations
      ArchiveFile? entry = archive.findFile(href);

      // If not found, try with different path combinations
      if (entry == null) {
        // Try with OEBPS/ prefix (common in EPUBs)
        entry = archive.findFile('OEBPS/$href');
      }

      if (entry == null) {
        // Try with text/ prefix (some EPUBs use this)
        entry = archive.findFile('text/$href');
      }

      if (entry == null) {
        // Try to find by filename only (ignore directory)
        final filename = href.split('/').last;
        for (final file in archive.files) {
          if (file.name.endsWith(filename)) {
            entry = file;
            break;
          }
        }
      }

      if (entry == null) {
        print(
          'DEBUG: No archive entry found for href: $href (tried multiple paths)',
        );
        continue;
      }

      print('DEBUG: Found file at: ${entry.name}');

      // Properly decode the content as UTF-8
      final content = utf8.decode(entry.content, allowMalformed: true);
      final title = _extractChapterTitle(content);
      final wordCount = _countWords(content);

      // Check if this is likely a cover chapter (first chapter with minimal content)
      final isCoverChapter =
          i == 0 && _isLikelyCoverChapter(content, title, wordCount);

      print(
        'DEBUG: Created chapter: $title (${content.length} chars, $wordCount words, cover: $isCoverChapter)',
      );

      final chapter = EpubChapter(
        id: id,
        title: isCoverChapter ? 'Cover' : _generateChapterTitle(title, i),
        content: content,
        filePath: href,
        order: i,
        wordCount: wordCount,
        estimatedReadingTime: (wordCount / 225).ceil(), // 225 WPM average
        isCoverChapter: isCoverChapter,
      );

      chapters.add(chapter);
    }

    print('DEBUG: Total chapters created: ${chapters.length}');
    return chapters;
  }

  /// Determines if a chapter is likely a cover page
  static bool _isLikelyCoverChapter(
    String content,
    String title,
    int wordCount,
  ) {
    // Check for minimal content (typical of cover pages)
    if (wordCount < 50) return true;

    // Check for cover-related titles
    final coverTitles = ['cover', 'title', 'front', 'page'];
    if (coverTitles.any(
      (coverTitle) => title.toLowerCase().contains(coverTitle),
    )) {
      return true;
    }

    // Check for minimal HTML structure (just title and maybe one paragraph)
    final htmlTags = content.split('<').length - 1;
    if (htmlTags < 10) return true;

    // Check if content is mostly empty or just contains basic structure
    final cleanContent = content.replaceAll(RegExp(r'<[^>]*>'), '').trim();
    if (cleanContent.length < 200) return true;

    return false;
  }

  /// Parses table of contents
  static List<Map<String, dynamic>> _parseTableOfContents(
    Archive archive,
    Map<String, String> manifest,
  ) {
    // Look for NCX file or nav.xhtml
    final ncxEntry =
        archive.findFile('toc.ncx') ??
        archive.findFile('nav.ncx') ??
        archive.findFile('navigation.ncx');

    if (ncxEntry != null) {
      return _parseNcxToc(utf8.decode(ncxEntry.content, allowMalformed: true));
    }

    // Look for nav.xhtml
    final navEntry =
        archive.findFile('nav.xhtml') ?? archive.findFile('navigation.xhtml');

    if (navEntry != null) {
      return _parseNavToc(utf8.decode(navEntry.content, allowMalformed: true));
    }

    return [];
  }

  /// Parses navigation
  static List<Map<String, dynamic>> _parseNavigation(
    Archive archive,
    Map<String, String> manifest,
  ) {
    // Similar to TOC parsing but for navigation
    return [];
  }

  /// Extracts cover image
  static List<int>? _extractCoverImage(
    Archive archive,
    Map<String, String> manifest,
  ) {
    print('DEBUG: Starting cover image extraction...');
    print('DEBUG: Manifest entries: ${manifest.entries.length}');

    // Look for cover image in manifest
    for (final entry in manifest.entries) {
      final key = entry.key.toLowerCase();
      final value = entry.value.toLowerCase();

      print('DEBUG: Checking manifest entry: $key -> $value');

      // Check for cover-related identifiers
      if (key.contains('cover') || value.contains('cover')) {
        print(
          'DEBUG: Found potential cover in manifest: ${entry.key} -> ${entry.value}',
        );
        final imageEntry = archive.findFile(entry.value);
        if (imageEntry != null) {
          print(
            'DEBUG: Successfully found cover image: ${entry.key} -> ${entry.value}',
          );
          return imageEntry.content;
        } else {
          print(
            'DEBUG: Manifest entry found but file not found: ${entry.value}',
          );
        }
      }
    }

    // If no cover found in manifest, look for common cover file names
    print('DEBUG: No cover found in manifest, searching by filename...');
    final commonCoverNames = [
      'cover.jpg',
      'cover.jpeg',
      'cover.png',
      'title.jpg',
      'title.jpeg',
      'title.png',
      'front.jpg',
      'front.jpeg',
      'front.png',
      'page1.jpg',
      'page1.jpeg',
      'page1.png',
    ];

    for (final coverName in commonCoverNames) {
      final imageEntry = archive.findFile(coverName);
      if (imageEntry != null) {
        print('DEBUG: Found cover image by filename: $coverName');
        return imageEntry.content;
      }

      // Try with OEBPS/ prefix
      final imageEntryWithPrefix = archive.findFile('OEBPS/$coverName');
      if (imageEntryWithPrefix != null) {
        print(
          'DEBUG: Found cover image by filename with OEBPS prefix: OEBPS/$coverName',
        );
        return imageEntryWithPrefix.content;
      }
    }

    // Last resort: search through all files for any image that might be a cover
    print('DEBUG: Searching through all archive files for cover images...');
    for (final file in archive.files) {
      final fileName = file.name.toLowerCase();
      if (fileName.contains('cover') &&
          (fileName.endsWith('.jpg') ||
              fileName.endsWith('.jpeg') ||
              fileName.endsWith('.png'))) {
        print('DEBUG: Found potential cover image in archive: ${file.name}');
        return file.content;
      }

      // Also check for title and front images
      if ((fileName.contains('title') || fileName.contains('front')) &&
          (fileName.endsWith('.jpg') ||
              fileName.endsWith('.jpeg') ||
              fileName.endsWith('.png'))) {
        print(
          'DEBUG: Found potential title/front image in archive: ${file.name}',
        );
        return file.content;
      }
    }

    print('DEBUG: No cover image found after exhaustive search');
    return null;
  }

  /// Helper method to get element text
  static String? _getElementText(XmlElement parent, String elementName) {
    final element = parent.findAllElements(elementName).firstOrNull;
    return element?.text.trim();
  }

  /// Extracts chapter title from HTML content
  static String _extractChapterTitle(String htmlContent) {
    try {
      final document = XmlDocument.parse(htmlContent);
      final titleElement = document.findAllElements('title').firstOrNull;
      if (titleElement != null) {
        return titleElement.text.trim();
      }

      // Try to find h1, h2, h3 tags
      for (final tag in ['h1', 'h2', 'h3']) {
        final heading = document.findAllElements(tag).firstOrNull;
        if (heading != null) {
          return heading.text.trim();
        }
      }

      return 'Chapter';
    } catch (e) {
      return 'Chapter';
    }
  }

  /// Generates a better chapter title, filtering out Project Gutenberg headers
  static String _generateChapterTitle(String extractedTitle, int chapterIndex) {
    // Patterns to identify Project Gutenberg headers and unwanted content
    final unwantedPatterns = [
      RegExp(r'project gutenberg', caseSensitive: false),
      RegExp(r'ebook.*by', caseSensitive: false),
      RegExp(r'the project gutenberg ebook', caseSensitive: false),
      RegExp(r'this ebook is for the use of anyone', caseSensitive: false),
      RegExp(r'produced by', caseSensitive: false),
      RegExp(r'transcribed from', caseSensitive: false),
      RegExp(r'end of.*project gutenberg', caseSensitive: false),
    ];

    // Check if the extracted title is unwanted
    final isUnwanted = unwantedPatterns.any(
      (pattern) => pattern.hasMatch(extractedTitle),
    );

    // If title is too long, it's probably book metadata
    final isTooLong = extractedTitle.length > 80;

    // If title contains book metadata indicators
    final hasBookMetadata =
        extractedTitle.toLowerCase().contains('ebook') ||
        extractedTitle.toLowerCase().contains(' by ') ||
        extractedTitle.toLowerCase().contains('author');

    // If the title is problematic, generate a better one
    if (isUnwanted ||
        isTooLong ||
        hasBookMetadata ||
        extractedTitle == 'Chapter') {
      // Try to extract just the meaningful part if possible
      final cleanTitle = _extractMeaningfulPart(extractedTitle);
      if (cleanTitle != null && cleanTitle.isNotEmpty) {
        return cleanTitle;
      }

      // Generate numbered chapter title
      return 'Chapter ${chapterIndex + 1}';
    }

    // Title seems good, use it as is
    return extractedTitle;
  }

  /// Extracts meaningful part from a long title
  static String? _extractMeaningfulPart(String title) {
    // Common patterns for real chapter titles within longer text
    final chapterPatterns = [
      RegExp(r'chapter\s+\d+[:\-\s]*([^\.]+)', caseSensitive: false),
      RegExp(r'part\s+\d+[:\-\s]*([^\.]+)', caseSensitive: false),
      RegExp(r'book\s+\d+[:\-\s]*([^\.]+)', caseSensitive: false),
      RegExp(r'section\s+\d+[:\-\s]*([^\.]+)', caseSensitive: false),
    ];

    for (final pattern in chapterPatterns) {
      final match = pattern.firstMatch(title);
      if (match != null && match.groupCount > 0) {
        final meaningful = match.group(1)?.trim();
        if (meaningful != null &&
            meaningful.length > 3 &&
            meaningful.length < 50) {
          return meaningful;
        }
      }
    }

    return null;
  }

  /// Counts words in text content
  static int _countWords(String text) {
    // Remove HTML tags and count words
    final cleanText = text.replaceAll(RegExp(r'<[^>]*>'), ' ').trim();
    if (cleanText.isEmpty) return 0;

    final words = cleanText.split(RegExp(r'\s+'));
    return words.length;
  }

  /// Parses NCX table of contents
  static List<Map<String, dynamic>> _parseNcxToc(String ncxContent) {
    try {
      final document = XmlDocument.parse(ncxContent);
      final navPoints = document.findAllElements('navPoint');

      return navPoints.map((navPoint) {
        final label =
            navPoint.findAllElements('text').firstOrNull?.text.trim() ?? '';
        final src =
            navPoint
                .findAllElements('content')
                .firstOrNull
                ?.getAttribute('src') ??
            '';

        return {'label': label, 'src': src};
      }).toList();
    } catch (e) {
      return [];
    }
  }

  /// Parses navigation table of contents
  static List<Map<String, dynamic>> _parseNavToc(String navContent) {
    try {
      final document = XmlDocument.parse(navContent);
      final navElements = document.findAllElements('nav');

      return navElements.map((nav) {
        final label = nav.findAllElements('a').firstOrNull?.text.trim() ?? '';
        final href =
            nav.findAllElements('a').firstOrNull?.getAttribute('href') ?? '';

        return {'label': label, 'href': href};
      }).toList();
    } catch (e) {
      return [];
    }
  }
}
