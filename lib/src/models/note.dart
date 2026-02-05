/// Model representing a note in an EPUB book
class Note {
  /// Unique identifier for the note
  final String id;

  /// ID of the book this note belongs to
  final String bookId;

  /// Chapter index where the note is located
  final int chapterIndex;

  /// Selected text content that the note refers to
  final String selectedText;

  /// The note content
  final String content;

  /// Timestamp when the note was created
  final DateTime createdAt;

  /// Timestamp when the note was last modified
  final DateTime modifiedAt;

  const Note({
    required this.id,
    required this.bookId,
    required this.chapterIndex,
    required this.selectedText,
    required this.content,
    required this.createdAt,
    required this.modifiedAt,
  });

  /// Creates a new note with current timestamps
  factory Note.create({
    required String bookId,
    required int chapterIndex,
    required String selectedText,
    required String content,
  }) {
    final now = DateTime.now();
    return Note(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      bookId: bookId,
      chapterIndex: chapterIndex,
      selectedText: selectedText,
      content: content,
      createdAt: now,
      modifiedAt: now,
    );
  }

  /// Creates a copy of this note with updated values
  Note copyWith({
    String? id,
    String? bookId,
    int? chapterIndex,
    String? selectedText,
    String? content,
    DateTime? createdAt,
    DateTime? modifiedAt,
  }) {
    return Note(
      id: id ?? this.id,
      bookId: bookId ?? this.bookId,
      chapterIndex: chapterIndex ?? this.chapterIndex,
      selectedText: selectedText ?? this.selectedText,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      modifiedAt: modifiedAt ?? this.modifiedAt,
    );
  }

  /// Converts the note to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bookId': bookId,
      'chapterIndex': chapterIndex,
      'selectedText': selectedText,
      'content': content,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'modifiedAt': modifiedAt.millisecondsSinceEpoch,
    };
  }

  /// Creates a note from JSON data
  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['id'] as String,
      bookId: json['bookId'] as String,
      chapterIndex: json['chapterIndex'] as int,
      selectedText: json['selectedText'] as String,
      content: json['content'] as String,
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt'] as int),
      modifiedAt: DateTime.fromMillisecondsSinceEpoch(
        json['modifiedAt'] as int,
      ),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Note && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Note(id: $id, bookId: $bookId, chapterIndex: $chapterIndex, content: ${content.length > 30 ? '${content.substring(0, 30)}...' : content})';
  }
}
