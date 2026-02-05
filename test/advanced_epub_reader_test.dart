import 'package:flutter_test/flutter_test.dart';
import 'package:advanced_epub_reader/advanced_epub_reader.dart';

void main() {
  group('Advanced EPUB Reader Tests', () {
    group('EpubMetadata Tests', () {
      test('should create EpubMetadata with required fields', () {
        final metadata = EpubMetadata(
          title: 'Test Book',
          creator: 'Test Author',
          language: 'en',
        );

        expect(metadata.title, equals('Test Book'));
        expect(metadata.creator, equals('Test Author'));
        expect(metadata.language, equals('en'));
        expect(metadata.subjects, isEmpty);
        expect(metadata.custom, isEmpty);
      });

      test('should create EpubMetadata with all fields', () {
        final metadata = EpubMetadata(
          title: 'Test Book',
          creator: 'Test Author',
          publisher: 'Test Publisher',
          language: 'en',
          identifier: 'test-123',
          description: 'A test book',
          subjects: ['Fiction', 'Test'],
          rights: 'Copyright 2024',
          date: DateTime(2024, 1, 1),
          contributor: 'Test Contributor',
          coverage: 'Test Coverage',
          format: 'EPUB',
          relation: 'Test Relation',
          source: 'Test Source',
          type: 'Test Type',
          custom: {'key': 'value'},
        );

        expect(metadata.title, equals('Test Book'));
        expect(metadata.creator, equals('Test Author'));
        expect(metadata.publisher, equals('Test Publisher'));
        expect(metadata.language, equals('en'));
        expect(metadata.identifier, equals('test-123'));
        expect(metadata.description, equals('A test book'));
        expect(metadata.subjects, equals(['Fiction', 'Test']));
        expect(metadata.rights, equals('Copyright 2024'));
        expect(metadata.date, equals(DateTime(2024, 1, 1)));
        expect(metadata.contributor, equals('Test Contributor'));
        expect(metadata.coverage, equals('Test Coverage'));
        expect(metadata.format, equals('EPUB'));
        expect(metadata.relation, equals('Test Relation'));
        expect(metadata.source, equals('Test Source'));
        expect(metadata.type, equals('Test Type'));
        expect(metadata.custom, equals({'key': 'value'}));
      });

      test('should convert to and from JSON', () {
        final original = EpubMetadata(
          title: 'Test Book',
          creator: 'Test Author',
          language: 'en',
          date: DateTime(2024, 1, 1),
        );

        final json = original.toJson();
        final restored = EpubMetadata.fromJson(json);

        expect(restored.title, equals(original.title));
        expect(restored.creator, equals(original.creator));
        expect(restored.language, equals(original.language));
        expect(restored.date?.year, equals(original.date?.year));
        expect(restored.date?.month, equals(original.date?.month));
        expect(restored.date?.day, equals(original.date?.day));
      });
    });

    group('EpubChapter Tests', () {
      test('should create EpubChapter with required fields', () {
        final chapter = EpubChapter(
          id: 'chapter1',
          title: 'Chapter 1',
          content: '<h1>Chapter 1</h1><p>Content here</p>',
          filePath: 'chapter1.xhtml',
          order: 0,
        );

        expect(chapter.id, equals('chapter1'));
        expect(chapter.title, equals('Chapter 1'));
        expect(
          chapter.content,
          equals('<h1>Chapter 1</h1><p>Content here</p>'),
        );
        expect(chapter.filePath, equals('chapter1.xhtml'));
        expect(chapter.order, equals(0));
        expect(chapter.level, equals(0));
        expect(chapter.wordCount, equals(0));
        expect(chapter.estimatedReadingTime, equals(0));
      });

      test('should create EpubChapter with all fields', () {
        final chapter = EpubChapter(
          id: 'chapter1',
          title: 'Chapter 1',
          content: '<h1>Chapter 1</h1><p>Content here</p>',
          filePath: 'chapter1.xhtml',
          order: 0,
          level: 1,
          parentId: 'parent-chapter',
          childrenIds: ['sub-chapter1', 'sub-chapter2'],
          anchors: ['anchor1', 'anchor2'],
          wordCount: 150,
          estimatedReadingTime: 1,
        );

        expect(chapter.id, equals('chapter1'));
        expect(chapter.title, equals('Chapter 1'));
        expect(chapter.level, equals(1));
        expect(chapter.parentId, equals('parent-chapter'));
        expect(chapter.childrenIds, equals(['sub-chapter1', 'sub-chapter2']));
        expect(chapter.anchors, equals(['anchor1', 'anchor2']));
        expect(chapter.wordCount, equals(150));
        expect(chapter.estimatedReadingTime, equals(1));
      });

      test('should calculate reading time', () {
        final chapter = EpubChapter(
          id: 'chapter1',
          title: 'Chapter 1',
          content: 'Test content',
          filePath: 'chapter1.xhtml',
          order: 0,
          wordCount: 225,
        );

        expect(
          chapter.calculateReadingTime(),
          equals(1),
        ); // 225 words / 225 WPM = 1 minute
        expect(
          chapter.calculateReadingTime(wordsPerMinute: 150),
          equals(2),
        ); // 225 words / 150 WPM = 2 minutes
      });

      test('should check chapter properties', () {
        final chapter = EpubChapter(
          id: 'chapter1',
          title: 'Chapter 1',
          content: 'Test content',
          filePath: 'chapter1.xhtml',
          order: 0,
          childrenIds: ['sub1'],
        );

        expect(chapter.hasChildren, isTrue);
        expect(chapter.isNested, isFalse);
        expect(chapter.fullPath, equals('Chapter 1'));
      });

      test('should convert to and from JSON', () {
        final original = EpubChapter(
          id: 'chapter1',
          title: 'Chapter 1',
          content: '<h1>Chapter 1</h1>',
          filePath: 'chapter1.xhtml',
          order: 0,
          wordCount: 100,
        );

        final json = original.toJson();
        final restored = EpubChapter.fromJson(json);

        expect(restored.id, equals(original.id));
        expect(restored.title, equals(original.title));
        expect(restored.content, equals(original.content));
        expect(restored.filePath, equals(original.filePath));
        expect(restored.order, equals(original.order));
        expect(restored.wordCount, equals(original.wordCount));
      });
    });

    group('ReadingProgress Tests', () {
      test('should create initial progress', () {
        final progress = ReadingProgress.initial('book-123');

        expect(progress.bookId, equals('book-123'));
        expect(progress.currentChapterIndex, equals(0));
        expect(progress.chapterProgress, equals(0.0));
        expect(progress.bookProgress, equals(0.0));
        expect(progress.isFinished, isFalse);
        expect(progress.isChapterFinished, isFalse);
      });

      test('should calculate progress percentages', () {
        final progress = ReadingProgress(
          id: 'progress-1',
          bookId: 'book-123',
          currentChapterIndex: 2,
          chapterProgress: 0.5,
          bookProgress: 0.25,
          lastReadAt: DateTime.now(),
        );

        expect(progress.bookProgressPercentage, equals('25.0%'));
        expect(progress.chapterProgressPercentage, equals('50.0%'));
      });

      test('should check progress status', () {
        final progress = ReadingProgress(
          id: 'progress-1',
          bookId: 'book-123',
          currentChapterIndex: 5,
          chapterProgress: 1.0,
          bookProgress: 1.0,
          lastReadAt: DateTime.now(),
        );

        expect(progress.isFinished, isTrue);
        expect(progress.isChapterFinished, isTrue);
      });

      test('should convert to and from JSON', () {
        final original = ReadingProgress(
          id: 'progress-1',
          bookId: 'book-123',
          currentChapterIndex: 2,
          chapterProgress: 0.5,
          bookProgress: 0.25,
          lastReadAt: DateTime.now(),
        );

        final json = original.toJson();
        final restored = ReadingProgress.fromJson(json);

        expect(restored.id, equals(original.id));
        expect(restored.bookId, equals(original.bookId));
        expect(
          restored.currentChapterIndex,
          equals(original.currentChapterIndex),
        );
        expect(restored.chapterProgress, equals(original.chapterProgress));
        expect(restored.bookProgress, equals(original.bookProgress));
      });
    });

    group('Bookmark Tests', () {
      test('should create bookmark with required fields', () {
        final bookmark = Bookmark.create(
          bookId: 'book-123',
          chapterIndex: 2,
          position: 0.5,
          title: 'Important Page',
        );

        expect(bookmark.bookId, equals('book-123'));
        expect(bookmark.chapterIndex, equals(2));
        expect(bookmark.position, equals(0.5));
        expect(bookmark.title, equals('Important Page'));
        expect(bookmark.tags, isEmpty);
      });

      test('should create bookmark with all fields', () {
        final bookmark = Bookmark.create(
          bookId: 'book-123',
          chapterIndex: 2,
          position: 0.5,
          title: 'Important Page',
          description: 'A very important page to remember',
          color: '#FF0000',
          icon: 'star',
          tags: ['important', 'reference'],
        );

        expect(bookmark.bookId, equals('book-123'));
        expect(bookmark.title, equals('Important Page'));
        expect(
          bookmark.description,
          equals('A very important page to remember'),
        );
        expect(bookmark.color, equals('#FF0000'));
        expect(bookmark.icon, equals('star'));
        expect(bookmark.tags, equals(['important', 'reference']));
      });

      test('should calculate position percentage', () {
        final bookmark = Bookmark.create(
          bookId: 'book-123',
          chapterIndex: 2,
          position: 0.75,
          title: 'Test',
        );

        expect(bookmark.positionPercentage, equals('75.0%'));
      });

      test('should check bookmark properties', () {
        final bookmark = Bookmark.create(
          bookId: 'book-123',
          chapterIndex: 2,
          position: 0.5,
          title: 'Test',
          description: 'Description',
          tags: ['tag1', 'tag2'],
        );

        expect(bookmark.hasDescription, isTrue);
        expect(bookmark.hasTags, isTrue);
        expect(bookmark.displayName, equals('Test'));
      });

      test('should convert to and from JSON', () {
        final original = Bookmark.create(
          bookId: 'book-123',
          chapterIndex: 2,
          position: 0.5,
          title: 'Test Bookmark',
          description: 'Test Description',
          tags: ['test'],
        );

        final json = original.toJson();
        final restored = Bookmark.fromJson(json);

        expect(restored.id, equals(original.id));
        expect(restored.bookId, equals(original.bookId));
        expect(restored.chapterIndex, equals(original.chapterIndex));
        expect(restored.position, equals(original.position));
        expect(restored.title, equals(original.title));
        expect(restored.description, equals(original.description));
        expect(restored.tags, equals(original.tags));
      });
    });

    group('Annotation Tests', () {
      test('should create annotation with required fields', () {
        final annotation = Annotation.create(
          bookId: 'book-123',
          chapterIndex: 2,
          startPosition: 0.3,
          endPosition: 0.5,
          selectedText: 'This is important text',
        );

        expect(annotation.bookId, equals('book-123'));
        expect(annotation.chapterIndex, equals(2));
        expect(annotation.startPosition, equals(0.3));
        expect(annotation.endPosition, equals(0.5));
        expect(annotation.selectedText, equals('This is important text'));
        expect(annotation.type, equals(AnnotationType.highlight));
        expect(annotation.color, equals('#FFD700'));
        expect(annotation.tags, isEmpty);
      });

      test('should create annotation with all fields', () {
        final annotation = Annotation.create(
          bookId: 'book-123',
          chapterIndex: 2,
          startPosition: 0.3,
          endPosition: 0.5,
          selectedText: 'This is important text',
          note: 'Remember this for later',
          type: AnnotationType.note,
          color: '#00FF00',
          tags: ['important', 'remember'],
        );

        expect(annotation.bookId, equals('book-123'));
        expect(annotation.selectedText, equals('This is important text'));
        expect(annotation.note, equals('Remember this for later'));
        expect(annotation.type, equals(AnnotationType.note));
        expect(annotation.color, equals('#00FF00'));
        expect(annotation.tags, equals(['important', 'remember']));
      });

      test('should calculate annotation length', () {
        final annotation = Annotation.create(
          bookId: 'book-123',
          chapterIndex: 2,
          startPosition: 0.3,
          endPosition: 0.5,
          selectedText: 'Test',
        );

        expect(annotation.length, equals(0.2));
      });

      test('should check annotation properties', () {
        final annotation = Annotation.create(
          bookId: 'book-123',
          chapterIndex: 2,
          startPosition: 0.3,
          endPosition: 0.5,
          selectedText: 'Test',
          note: 'Note',
          tags: ['tag1'],
        );

        expect(annotation.hasNote, isTrue);
        expect(annotation.hasTags, isTrue);
        expect(annotation.displayText, equals('Test'));
      });

      test('should convert to and from JSON', () {
        final original = Annotation.create(
          bookId: 'book-123',
          chapterIndex: 2,
          startPosition: 0.3,
          endPosition: 0.5,
          selectedText: 'Test Text',
          note: 'Test Note',
          type: AnnotationType.highlight,
          color: '#FF0000',
          tags: ['test'],
        );

        final json = original.toJson();
        final restored = Annotation.fromJson(json);

        expect(restored.id, equals(original.id));
        expect(restored.bookId, equals(original.bookId));
        expect(restored.chapterIndex, equals(original.chapterIndex));
        expect(restored.startPosition, equals(original.startPosition));
        expect(restored.endPosition, equals(original.endPosition));
        expect(restored.selectedText, equals(original.selectedText));
        expect(restored.note, equals(original.note));
        expect(restored.type, equals(original.type));
        expect(restored.color, equals(original.color));
        expect(restored.tags, equals(original.tags));
      });
    });

    group('EpubBook Tests', () {
      test('should create EpubBook with required fields', () {
        final metadata = EpubMetadata(title: 'Test Book');
        final chapters = [
          EpubChapter(
            id: 'chapter1',
            title: 'Chapter 1',
            content: 'Content',
            filePath: 'chapter1.xhtml',
            order: 0,
          ),
        ];

        final book = EpubBook(
          id: 'book-123',
          metadata: metadata,
          chapters: chapters,
          spine: ['chapter1'],
          manifest: {'chapter1': 'chapter1.xhtml'},
          tableOfContents: [],
          navigation: [],
          createdAt: DateTime.now(),
        );

        expect(book.id, equals('book-123'));
        expect(book.metadata.title, equals('Test Book'));
        expect(book.chapters.length, equals(1));
        expect(book.spine, equals(['chapter1']));
        expect(book.manifest, equals({'chapter1': 'chapter1.xhtml'}));
      });

      test('should convert to and from JSON', () {
        final metadata = EpubMetadata(title: 'Test Book');
        final chapters = [
          EpubChapter(
            id: 'chapter1',
            title: 'Chapter 1',
            content: 'Content',
            filePath: 'chapter1.xhtml',
            order: 0,
          ),
        ];

        final original = EpubBook(
          id: 'book-123',
          metadata: metadata,
          chapters: chapters,
          spine: ['chapter1'],
          manifest: {'chapter1': 'chapter1.xhtml'},
          tableOfContents: [],
          navigation: [],
          createdAt: DateTime.now(),
        );

        final json = original.toJson();
        final restored = EpubBook.fromJson(json);

        expect(restored.id, equals(original.id));
        expect(restored.metadata.title, equals(original.metadata.title));
        expect(restored.chapters.length, equals(original.chapters.length));
        expect(restored.spine, equals(original.spine));
        expect(restored.manifest, equals(original.manifest));
      });
    });

    group('ReadingTheme Tests', () {
      test('should get all themes', () {
        final themes = ReadingThemes.getAllThemes();
        expect(themes.length, equals(8));
        expect(themes.any((theme) => theme.name == 'Light'), isTrue);
        expect(themes.any((theme) => theme.name == 'Dark'), isTrue);
        expect(themes.any((theme) => theme.name == 'Sepia'), isTrue);
        expect(themes.any((theme) => theme.name == 'High Contrast'), isTrue);
        expect(
          themes.any((theme) => theme.name == 'Blue Light Filter'),
          isTrue,
        );
        expect(themes.any((theme) => theme.name == 'Green'), isTrue);
        expect(themes.any((theme) => theme.name == 'Purple'), isTrue);
        expect(themes.any((theme) => theme.name == 'Orange'), isTrue);
      });

      test('should get theme by name', () {
        final lightTheme = ReadingThemes.getThemeByName('Light');
        expect(lightTheme?.name, equals('Light'));
        expect(
          lightTheme?.backgroundColor,
          equals(ReadingThemes.light.backgroundColor),
        );

        final darkTheme = ReadingThemes.getThemeByName('Dark');
        expect(darkTheme?.name, equals('Dark'));
        expect(
          darkTheme?.backgroundColor,
          equals(ReadingThemes.dark.backgroundColor),
        );
      });

      test('should convert theme to and from JSON', () {
        final original = ReadingThemes.light;
        final json = original.toJson();
        final restored = ReadingTheme.fromJson(json);

        expect(restored.name, equals(original.name));
        expect(
          restored.backgroundColor.value,
          equals(original.backgroundColor.value),
        );
        expect(restored.textColor.value, equals(original.textColor.value));
        expect(restored.accentColor.value, equals(original.accentColor.value));
      });
    });

    group('EpubUtils Tests', () {
      test('should format file size correctly', () {
        expect(EpubUtils.formatFileSize(512), equals('512 B'));
        expect(EpubUtils.formatFileSize(1024), equals('1.0 KB'));
        expect(EpubUtils.formatFileSize(1024 * 1024), equals('1.0 MB'));
        expect(EpubUtils.formatFileSize(1024 * 1024 * 1024), equals('1.0 GB'));
      });

      test('should get file extension', () {
        expect(
          EpubUtils.getFileExtension('/path/to/book.epub'),
          equals('epub'),
        );
        expect(EpubUtils.getFileExtension('book.epub'), equals('epub'));
        expect(EpubUtils.getFileExtension('book'), equals(''));
      });

      test('should check EPUB extension', () {
        expect(EpubUtils.hasEpubExtension('/path/to/book.epub'), isTrue);
        expect(EpubUtils.hasEpubExtension('/path/to/book.txt'), isFalse);
        expect(EpubUtils.hasEpubExtension('book.epub'), isTrue);
      });

      test('should sanitize filename', () {
        expect(
          EpubUtils.sanitizeFilename('file<name>.txt'),
          equals('file_name_.txt'),
        );
        expect(
          EpubUtils.sanitizeFilename('file name.txt'),
          equals('file_name.txt'),
        );
        expect(
          EpubUtils.sanitizeFilename('file/name.txt'),
          equals('file_name.txt'),
        );
      });

      test('should get base filename', () {
        expect(EpubUtils.getBaseFilename('/path/to/book.epub'), equals('book'));
        expect(EpubUtils.getBaseFilename('book.epub'), equals('book'));
        expect(EpubUtils.getBaseFilename('book'), equals('book'));
      });

      test('should get directory path', () {
        expect(
          EpubUtils.getDirectoryPath('/path/to/book.epub'),
          equals('/path/to'),
        );
        expect(EpubUtils.getDirectoryPath('book.epub'), equals('.'));
        expect(EpubUtils.getDirectoryPath('/path/to/'), equals('/path/to'));
      });

      test('should format duration', () {
        expect(EpubUtils.formatDuration(Duration(seconds: 30)), equals('30s'));
        expect(EpubUtils.formatDuration(Duration(minutes: 5)), equals('5m'));
        expect(
          EpubUtils.formatDuration(Duration(hours: 2, minutes: 30)),
          equals('2h 30m'),
        );
      });

      test('should format date', () {
        final now = DateTime.now();
        final yesterday = now.subtract(Duration(days: 1));
        final lastWeek = now.subtract(Duration(days: 7));
        final lastMonth = now.subtract(Duration(days: 30));
        final lastYear = now.subtract(Duration(days: 365));

        expect(EpubUtils.formatDate(now), equals('Today'));
        expect(EpubUtils.formatDate(yesterday), equals('Yesterday'));
        expect(EpubUtils.formatDate(lastWeek), equals('1 week ago'));
        expect(EpubUtils.formatDate(lastMonth), equals('1 month ago'));
        expect(EpubUtils.formatDate(lastYear), equals('1 year ago'));
      });
    });
  });
}
