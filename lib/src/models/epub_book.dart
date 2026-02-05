import 'epub_metadata.dart';
import 'epub_chapter.dart';

/// Represents an EPUB book with all its components
class EpubBook {
  /// Unique identifier for the book
  final String id;

  /// Book metadata (title, author, etc.)
  final EpubMetadata metadata;

  /// List of all chapters in the book
  final List<EpubChapter> chapters;

  /// The book's cover image as bytes (if available)
  final List<int>? coverImage;

  /// The book's spine (reading order)
  final List<String> spine;

  /// The book's manifest (all resources)
  final Map<String, String> manifest;

  /// Map of raw resource bytes keyed by the path inside the EPUB archive
  final Map<String, List<int>> resources;

  /// The book's table of contents
  final List<Map<String, dynamic>> tableOfContents;

  /// The book's navigation
  final List<Map<String, dynamic>> navigation;

  /// The book's file path
  final String? filePath;

  /// The book's file size in bytes
  final int? fileSize;

  /// The book's last opened date
  final DateTime? lastOpened;

  /// The book's creation date
  final DateTime createdAt;

  const EpubBook({
    required this.id,
    required this.metadata,
    required this.chapters,
    this.coverImage,
    required this.spine,
    required this.manifest,
    required this.tableOfContents,
    required this.navigation,
    this.filePath,
    this.fileSize,
    this.lastOpened,
    required this.createdAt,
    this.resources = const {},
  });

  /// Creates a copy of this book with updated values
  EpubBook copyWith({
    String? id,
    EpubMetadata? metadata,
    List<EpubChapter>? chapters,
    List<int>? coverImage,
    List<String>? spine,
    Map<String, String>? manifest,
    Map<String, List<int>>? resources,
    List<Map<String, dynamic>>? tableOfContents,
    List<Map<String, dynamic>>? navigation,
    String? filePath,
    int? fileSize,
    DateTime? lastOpened,
    DateTime? createdAt,
  }) {
    return EpubBook(
      id: id ?? this.id,
      metadata: metadata ?? this.metadata,
      chapters: chapters ?? this.chapters,
      coverImage: coverImage ?? this.coverImage,
      spine: spine ?? this.spine,
      manifest: manifest ?? this.manifest,
      tableOfContents: tableOfContents ?? this.tableOfContents,
      navigation: navigation ?? this.navigation,
      filePath: filePath ?? this.filePath,
      fileSize: fileSize ?? this.fileSize,
      lastOpened: lastOpened ?? this.lastOpened,
      createdAt: createdAt ?? this.createdAt,
      resources: resources ?? this.resources,
    );
  }

  /// Converts the book to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'metadata': metadata.toJson(),
      'chapters': chapters.map((chapter) => chapter.toJson()).toList(),
      'spine': spine,
      'manifest': manifest,
      'tableOfContents': tableOfContents,
      'navigation': navigation,
      'filePath': filePath,
      'fileSize': fileSize,
      'lastOpened': lastOpened?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'resources': resources.map((k, v) => MapEntry(k, v)),
    };
  }

  /// Creates a book from a JSON map
  factory EpubBook.fromJson(Map<String, dynamic> json) {
    return EpubBook(
      id: json['id'] as String,
      metadata: EpubMetadata.fromJson(json['metadata'] as Map<String, dynamic>),
      chapters: (json['chapters'] as List)
          .map(
            (chapter) => EpubChapter.fromJson(chapter as Map<String, dynamic>),
          )
          .toList(),
      spine: List<String>.from(json['spine'] as List),
      manifest: Map<String, String>.from(json['manifest'] as Map),
      tableOfContents: List<Map<String, dynamic>>.from(
        json['tableOfContents'] as List,
      ),
      navigation: List<Map<String, dynamic>>.from(json['navigation'] as List),
      filePath: json['filePath'] as String?,
      fileSize: json['fileSize'] as int?,
      lastOpened: json['lastOpened'] != null
          ? DateTime.parse(json['lastOpened'] as String)
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      resources: json['resources'] != null
          ? (json['resources'] as Map).map((k, v) => MapEntry(k as String, List<int>.from(v as List)))
          : {},
    );
  }

  @override
  String toString() {
    return 'EpubBook(id: $id, title: ${metadata.title}, chapters: ${chapters.length})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is EpubBook && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
