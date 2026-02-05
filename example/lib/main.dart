import 'package:flutter/material.dart';
import 'package:advanced_epub_reader/advanced_epub_reader.dart';

void main() {
  runApp(const EpubReaderExampleApp());
}

class EpubReaderExampleApp extends StatelessWidget {
  const EpubReaderExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Advanced EPUB Reader Example',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const EpubReaderExampleHome(),
    );
  }
}

class EpubReaderExampleHome extends StatefulWidget {
  const EpubReaderExampleHome({super.key});

  @override
  State<EpubReaderExampleHome> createState() => _EpubReaderExampleHomeState();
}

class _EpubReaderExampleHomeState extends State<EpubReaderExampleHome> {
  EpubBook? _book;
  bool _isLoading = false;
  String? _error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Advanced EPUB Reader Example'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Icon(Icons.book, size: 64, color: Colors.blue),
                    const SizedBox(height: 16),
                    const Text(
                      'Advanced EPUB Reader',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'A comprehensive Flutter package for reading EPUB books with advanced features.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Demo book section
            if (_book != null) ...[
              _buildBookInfo(),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _openBook,
                icon: const Icon(Icons.read_more),
                label: const Text('Open Book'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
              ),
            ] else ...[
              // Load demo book button
              ElevatedButton.icon(
                onPressed: _loadDemoBook,
                icon: const Icon(Icons.download),
                label: const Text('Load Demo Book'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
              ),
            ],

            const SizedBox(height: 24),

            // Features section
            _buildFeaturesSection(),

            const SizedBox(height: 24),

            // Loading indicator
            if (_isLoading) const Center(child: CircularProgressIndicator()),

            // Error display
            if (_error != null)
              Card(
                color: Colors.red.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Icon(Icons.error, color: Colors.red),
                      const SizedBox(height: 8),
                      Text(
                        'Error: $_error',
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookInfo() {
    if (_book == null) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _book!.metadata.title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            if (_book!.metadata.creator != null) ...[
              const SizedBox(height: 8),
              Text(
                'Author: ${_book!.metadata.creator}',
                style: const TextStyle(fontSize: 14),
              ),
            ],
            const SizedBox(height: 8),
            Text(
              'Chapters: ${_book!.chapters.length}',
              style: const TextStyle(fontSize: 14),
            ),
            if (_book!.metadata.language != null) ...[
              const SizedBox(height: 8),
              Text(
                'Language: ${_book!.metadata.language}',
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturesSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Features',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildFeatureItem(
              Icons.palette,
              'Multiple Themes',
              'Light, Dark, Sepia, High Contrast, and more',
            ),
            _buildFeatureItem(
              Icons.bookmark,
              'Smart Bookmarks',
              'Organize and categorize your bookmarks',
            ),
            _buildFeatureItem(
              Icons.highlight,
              'Text Annotations',
              'Highlight, underline, and add notes',
            ),
            _buildFeatureItem(
              Icons.track_changes,
              'Progress Tracking',
              'Track reading progress and statistics',
            ),
            _buildFeatureItem(
              Icons.search,
              'Full-Text Search',
              'Search within books and annotations',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _loadDemoBook() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Create a demo book for demonstration purposes
      // In a real app, you would load an actual EPUB file
      _book = _createDemoBook();

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
  }

  void _openBook() {
    if (_book == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EpubViewer(
          book: _book!,
          initialChapterIndex: 0,
          showControls: true,
          showTableOfContents: true,
          onProgressChanged: (progress) {
            print('Reading progress: ${progress.bookProgressPercentage}');
          },
          onChapterChanged: (chapterIndex) {
            print('Now reading chapter: $chapterIndex');
          },
        ),
      ),
    );
  }

  EpubBook _createDemoBook() {
    // Create demo metadata
    final metadata = EpubMetadata(
      title: 'Sample Book',
      creator: 'Demo Author',
      publisher: 'Demo Publisher',
      language: 'en',
      identifier: 'demo-book-123',
      description: 'This is a sample book for demonstration purposes.',
      subjects: ['Demo', 'Sample', 'Example'],
      date: DateTime.now(),
    );

    // Create demo chapters
    final chapters = [
      EpubChapter(
        id: 'chapter1',
        title: 'Introduction',
        content: '''
          <h1>Introduction</h1>
          <p>Welcome to this sample book. This is a demonstration of the Advanced EPUB Reader package.</p>
          <p>This chapter shows how the reader handles HTML content, including:</p>
          <ul>
            <li>Headings and paragraphs</li>
            <li>Lists and formatting</li>
            <li>Custom styling and themes</li>
          </ul>
          <p>You can navigate through chapters, adjust themes, and explore all the features.</p>
        ''',
        filePath: 'chapter1.xhtml',
        order: 0,
        wordCount: 150,
        estimatedReadingTime: 1,
      ),
      EpubChapter(
        id: 'chapter2',
        title: 'Getting Started',
        content: '''
          <h1>Getting Started</h1>
          <p>This chapter covers the basics of using the EPUB reader.</p>
          <h2>Features</h2>
          <p>The reader includes many advanced features:</p>
          <ul>
            <li>Multiple reading themes</li>
            <li>Bookmarking system</li>
            <li>Text annotations</li>
            <li>Progress tracking</li>
            <li>Search functionality</li>
          </ul>
          <h2>Navigation</h2>
          <p>Use the controls at the bottom to navigate between chapters and adjust reading settings.</p>
        ''',
        filePath: 'chapter2.xhtml',
        order: 1,
        wordCount: 200,
        estimatedReadingTime: 1,
      ),
      EpubChapter(
        id: 'chapter3',
        title: 'Advanced Features',
        content: '''
          <h1>Advanced Features</h1>
          <p>This chapter explores the more advanced capabilities of the reader.</p>
          <h2>Customization</h2>
          <p>You can customize:</p>
          <ul>
            <li>Font size and family</li>
            <li>Line height and margins</li>
            <li>Reading themes</li>
            <li>Navigation controls</li>
          </ul>
          <h2>Data Management</h2>
          <p>The reader automatically saves your:</p>
          <ul>
            <li>Reading progress</li>
            <li>Bookmarks and annotations</li>
            <li>Theme preferences</li>
            <li>Reading statistics</li>
          </ul>
        ''',
        filePath: 'chapter3.xhtml',
        order: 2,
        wordCount: 250,
        estimatedReadingTime: 2,
      ),
    ];

    return EpubBook(
      id: 'demo-book-123',
      metadata: metadata,
      chapters: chapters,
      spine: chapters.map((c) => c.id).toList(),
      manifest: {for (final chapter in chapters) chapter.id: chapter.filePath},
      tableOfContents: chapters
          .map((c) => {'label': c.title, 'src': c.filePath})
          .toList(),
      navigation: [],
      createdAt: DateTime.now(),
    );
  }
}
