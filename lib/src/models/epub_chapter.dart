/// Represents a chapter within an EPUB book
class EpubChapter {
  /// Unique identifier for the chapter
  final String id;

  /// The chapter's title
  final String title;

  /// The chapter's content in HTML format
  final String content;

  /// The chapter's file path within the EPUB
  final String filePath;

  /// The chapter's order in the book
  final int order;

  /// The chapter's level in the hierarchy (for nested chapters)
  final int level;

  /// The chapter's parent chapter ID (if nested)
  final String? parentId;

  /// The chapter's children chapter IDs (if has nested chapters)
  final List<String> childrenIds;

  /// The chapter's anchor points for navigation
  final List<String> anchors;

  /// The chapter's word count
  final int wordCount;

  /// The chapter's estimated reading time in minutes
  final int estimatedReadingTime;

  /// Whether this chapter is the cover chapter of the book
  final bool isCoverChapter;

  const EpubChapter({
    required this.id,
    required this.title,
    required this.content,
    required this.filePath,
    required this.order,
    this.level = 0,
    this.parentId,
    this.childrenIds = const [],
    this.anchors = const [],
    this.wordCount = 0,
    this.estimatedReadingTime = 0,
    this.isCoverChapter = false,
  });

  /// Creates a copy of this chapter with updated values
  EpubChapter copyWith({
    String? id,
    String? title,
    String? content,
    String? filePath,
    int? order,
    int? level,
    String? parentId,
    List<String>? childrenIds,
    List<String>? anchors,
    int? wordCount,
    int? estimatedReadingTime,
    bool? isCoverChapter,
  }) {
    return EpubChapter(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      filePath: filePath ?? this.filePath,
      order: order ?? this.order,
      level: level ?? this.level,
      parentId: parentId ?? this.parentId,
      childrenIds: childrenIds ?? this.childrenIds,
      anchors: anchors ?? this.anchors,
      wordCount: wordCount ?? this.wordCount,
      estimatedReadingTime: estimatedReadingTime ?? this.estimatedReadingTime,
      isCoverChapter: isCoverChapter ?? this.isCoverChapter,
    );
  }

  /// Converts the chapter to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'filePath': filePath,
      'order': order,
      'level': level,
      'parentId': parentId,
      'childrenIds': childrenIds,
      'anchors': anchors,
      'wordCount': wordCount,
      'estimatedReadingTime': estimatedReadingTime,
      'isCoverChapter': isCoverChapter,
    };
  }

  /// Creates a chapter from a JSON map
  factory EpubChapter.fromJson(Map<String, dynamic> json) {
    return EpubChapter(
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      filePath: json['filePath'] as String,
      order: json['order'] as int,
      level: json['level'] as int? ?? 0,
      parentId: json['parentId'] as String?,
      childrenIds: List<String>.from(json['childrenIds'] as List? ?? []),
      anchors: List<String>.from(json['anchors'] as List? ?? []),
      wordCount: json['wordCount'] as int? ?? 0,
      estimatedReadingTime: json['estimatedReadingTime'] as int? ?? 0,
      isCoverChapter: json['isCoverChapter'] as bool? ?? false,
    );
  }

  /// Calculates the estimated reading time based on word count
  /// Average reading speed is 200-250 words per minute
  int calculateReadingTime({int wordsPerMinute = 225}) {
    return (wordCount / wordsPerMinute).ceil();
  }

  /// Gets the chapter's full path including parent chapters
  String get fullPath {
    if (parentId == null) return title;
    return '$parentId > $title';
  }

  /// Checks if this chapter has nested chapters
  bool get hasChildren => childrenIds.isNotEmpty;

  /// Checks if this chapter is nested under another chapter
  bool get isNested => parentId != null;

  @override
  String toString() {
    return 'EpubChapter(id: $id, title: $title, order: $order, level: $level)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is EpubChapter && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
