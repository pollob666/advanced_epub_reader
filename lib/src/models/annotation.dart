/// Represents a text annotation or highlight within a book
class Annotation {
  /// Unique identifier for the annotation
  final String id;

  /// The book ID this annotation belongs to
  final String bookId;

  /// The chapter index where the annotation is placed
  final int chapterIndex;

  /// The start position of the annotation (percentage 0.0 to 1.0)
  final double startPosition;

  /// The end position of the annotation (percentage 0.0 to 1.0)
  final double endPosition;

  /// The annotated text content
  final String selectedText;

  /// The annotation's note/comment
  final String? note;

  /// The annotation's type (highlight, underline, note, etc.)
  final AnnotationType type;

  /// The annotation's color
  final String color;

  /// The annotation's creation timestamp
  final DateTime createdAt;

  /// The annotation's last modified timestamp
  final DateTime lastModified;

  /// The annotation's tags for categorization
  final List<String> tags;

  /// Whether the annotation is shared/public
  final bool isShared;

  const Annotation({
    required this.id,
    required this.bookId,
    required this.chapterIndex,
    required this.startPosition,
    required this.endPosition,
    required this.selectedText,
    this.note,
    required this.type,
    required this.color,
    required this.createdAt,
    required this.lastModified,
    this.tags = const [],
    this.isShared = false,
  });

  /// Creates a copy of this annotation with updated values
  Annotation copyWith({
    String? id,
    String? bookId,
    int? chapterIndex,
    double? startPosition,
    double? endPosition,
    String? selectedText,
    String? note,
    AnnotationType? type,
    String? color,
    DateTime? createdAt,
    DateTime? lastModified,
    List<String>? tags,
    bool? isShared,
  }) {
    return Annotation(
      id: id ?? this.id,
      bookId: bookId ?? this.bookId,
      chapterIndex: chapterIndex ?? this.chapterIndex,
      startPosition: startPosition ?? this.startPosition,
      endPosition: endPosition ?? this.endPosition,
      selectedText: selectedText ?? this.selectedText,
      note: note ?? this.note,
      type: type ?? this.type,
      color: color ?? this.color,
      createdAt: createdAt ?? this.createdAt,
      lastModified: lastModified ?? this.lastModified,
      tags: tags ?? this.tags,
      isShared: isShared ?? this.isShared,
    );
  }

  /// Converts the annotation to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bookId': bookId,
      'chapterIndex': chapterIndex,
      'startPosition': startPosition,
      'endPosition': endPosition,
      'selectedText': selectedText,
      'note': note,
      'type': type.name,
      'color': color,
      'createdAt': createdAt.toIso8601String(),
      'lastModified': lastModified.toIso8601String(),
      'tags': tags,
      'isShared': isShared,
    };
  }

  /// Creates an annotation from a JSON map
  factory Annotation.fromJson(Map<String, dynamic> json) {
    return Annotation(
      id: json['id'] as String,
      bookId: json['bookId'] as String,
      chapterIndex: json['chapterIndex'] as int,
      startPosition: (json['startPosition'] as num).toDouble(),
      endPosition: (json['endPosition'] as num).toDouble(),
      selectedText: json['selectedText'] as String,
      note: json['note'] as String?,
      type: AnnotationType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => AnnotationType.highlight,
      ),
      color: json['color'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastModified: DateTime.parse(json['lastModified'] as String),
      tags: List<String>.from(json['tags'] as List? ?? []),
      isShared: json['isShared'] as bool? ?? false,
    );
  }

  /// Creates a new annotation
  factory Annotation.create({
    required String bookId,
    required int chapterIndex,
    required double startPosition,
    required double endPosition,
    required String selectedText,
    String? note,
    AnnotationType type = AnnotationType.highlight,
    String color = '#FFD700',
    List<String>? tags,
  }) {
    final now = DateTime.now();
    return Annotation(
      id: now.millisecondsSinceEpoch.toString(),
      bookId: bookId,
      chapterIndex: chapterIndex,
      startPosition: startPosition,
      endPosition: endPosition,
      selectedText: selectedText,
      note: note,
      type: type,
      color: color,
      createdAt: now,
      lastModified: now,
      tags: tags ?? [],
    );
  }

  /// Gets the annotation length
  double get length => endPosition - startPosition;

  /// Checks if the annotation has a note
  bool get hasNote => note != null && note!.isNotEmpty;

  /// Checks if the annotation has tags
  bool get hasTags => tags.isNotEmpty;

  /// Gets the annotation's display text (selected text or note if text is empty)
  String get displayText =>
      selectedText.isNotEmpty ? selectedText : (note ?? 'Untitled Annotation');

  @override
  String toString() {
    return 'Annotation(id: $id, type: $type, text: "${selectedText.length > 20 ? '${selectedText.substring(0, 20)}...' : selectedText}")';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Annotation && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Enumeration of annotation types
enum AnnotationType {
  /// Text highlight
  highlight,

  /// Text underline
  underline,

  /// Text strikethrough
  strikethrough,

  /// Text note/comment
  note,

  /// Text bookmark
  bookmark,

  /// Custom annotation
  custom,
}
