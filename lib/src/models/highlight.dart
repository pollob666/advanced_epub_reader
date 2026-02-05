import 'package:flutter/material.dart';

/// Model representing a text highlight in an EPUB book
class Highlight {
  /// Unique identifier for the highlight
  final String id;

  /// ID of the book this highlight belongs to
  final String bookId;

  /// Chapter index where the highlight is located
  final int chapterIndex;

  /// Selected text content
  final String text;

  /// Highlight color
  final Color color;

  /// Optional note associated with the highlight
  final String? note;

  /// Timestamp when the highlight was created
  final DateTime createdAt;

  /// Timestamp when the highlight was last modified
  final DateTime modifiedAt;

  const Highlight({
    required this.id,
    required this.bookId,
    required this.chapterIndex,
    required this.text,
    required this.color,
    this.note,
    required this.createdAt,
    required this.modifiedAt,
  });

  /// Creates a new highlight with current timestamps
  factory Highlight.create({
    required String bookId,
    required int chapterIndex,
    required String text,
    required Color color,
    String? note,
  }) {
    final now = DateTime.now();
    return Highlight(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      bookId: bookId,
      chapterIndex: chapterIndex,
      text: text,
      color: color,
      note: note,
      createdAt: now,
      modifiedAt: now,
    );
  }

  /// Creates a copy of this highlight with updated values
  Highlight copyWith({
    String? id,
    String? bookId,
    int? chapterIndex,
    String? text,
    Color? color,
    String? note,
    DateTime? createdAt,
    DateTime? modifiedAt,
  }) {
    return Highlight(
      id: id ?? this.id,
      bookId: bookId ?? this.bookId,
      chapterIndex: chapterIndex ?? this.chapterIndex,
      text: text ?? this.text,
      color: color ?? this.color,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      modifiedAt: modifiedAt ?? this.modifiedAt,
    );
  }

  /// Converts the highlight to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bookId': bookId,
      'chapterIndex': chapterIndex,
      'text': text,
      'color': color.value,
      'note': note,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'modifiedAt': modifiedAt.millisecondsSinceEpoch,
    };
  }

  /// Creates a highlight from JSON data
  factory Highlight.fromJson(Map<String, dynamic> json) {
    return Highlight(
      id: json['id'] as String,
      bookId: json['bookId'] as String,
      chapterIndex: json['chapterIndex'] as int,
      text: json['text'] as String,
      color: Color(json['color'] as int),
      note: json['note'] as String?,
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt'] as int),
      modifiedAt: DateTime.fromMillisecondsSinceEpoch(
        json['modifiedAt'] as int,
      ),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Highlight && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Highlight(id: $id, bookId: $bookId, chapterIndex: $chapterIndex, text: ${text.length > 30 ? '${text.substring(0, 30)}...' : text})';
  }
}
