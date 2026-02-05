/// Model representing a bookmark in an EPUB book
class Bookmark {
  /// Unique identifier for the bookmark
  final String id;

  /// ID of the book this bookmark belongs to
  final String bookId;

  /// Chapter index where the bookmark is located
  final int chapterIndex;

  /// Position within the chapter (0.0 to 1.0)
  final double position;

  /// Optional description or note for the bookmark
  final String? description;

  /// Optional human-readable title for the bookmark (backward-compat)
  final String title;

  /// Optional color (as hex string) for visual identification (backward-compat)
  final String? color;

  /// Optional icon name for visual identification (backward-compat)
  final String? icon;

  /// Optional tags for categorization (backward-compat)
  final List<String> tags;

  /// Timestamp when the bookmark was created
  final DateTime createdAt;

  /// Timestamp when the bookmark was last accessed
  final DateTime lastAccessed;

  const Bookmark({
    required this.id,
    required this.bookId,
    required this.chapterIndex,
    required this.position,
    this.description,
    this.title = '',
    this.color,
    this.icon,
    this.tags = const [],
    required this.createdAt,
    required this.lastAccessed,
  });

  /// Creates a new bookmark with current timestamps
  factory Bookmark.create({
    required String bookId,
    required int chapterIndex,
    required double position,
    String? description,
    String title = '',
    String? color,
    String? icon,
    List<String>? tags,
  }) {
    final now = DateTime.now();
    return Bookmark(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      bookId: bookId,
      chapterIndex: chapterIndex,
      position: position,
      description: description,
      title: title,
      color: color,
      icon: icon,
      tags: tags ?? const [],
      createdAt: now,
      lastAccessed: now,
    );
  }

  /// Creates a copy of this bookmark with updated values
  Bookmark copyWith({
    String? id,
    String? bookId,
    int? chapterIndex,
    double? position,
    String? description,
    String? title,
    String? color,
    String? icon,
    List<String>? tags,
    DateTime? createdAt,
    DateTime? lastAccessed,
  }) {
    return Bookmark(
      id: id ?? this.id,
      bookId: bookId ?? this.bookId,
      chapterIndex: chapterIndex ?? this.chapterIndex,
      position: position ?? this.position,
      description: description ?? this.description,
      title: title ?? this.title,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      lastAccessed: lastAccessed ?? this.lastAccessed,
    );
  }

  /// Converts the bookmark to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bookId': bookId,
      'chapterIndex': chapterIndex,
      'position': position,
      'description': description,
      'title': title,
      'color': color,
      'icon': icon,
      'tags': tags,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'lastAccessed': lastAccessed.millisecondsSinceEpoch,
    };
  }

  /// Creates a bookmark from JSON data
  factory Bookmark.fromJson(Map<String, dynamic> json) {
    return Bookmark(
      id: json['id'] as String,
      bookId: json['bookId'] as String,
      chapterIndex: json['chapterIndex'] as int,
      position: (json['position'] as num).toDouble(),
      description: json['description'] as String?,
      title: (json['title'] as String?) ?? '',
      color: json['color'] as String?,
      icon: json['icon'] as String?,
      tags: List<String>.from(json['tags'] as List? ?? const []),
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt'] as int),
      lastAccessed: DateTime.fromMillisecondsSinceEpoch(
        json['lastAccessed'] as int,
      ),
    );
  }

  /// Returns position as percentage string with one decimal place
  String get positionPercentage => '${(position * 100).toStringAsFixed(1)}%';

  /// Returns true if there is a non-empty description
  bool get hasDescription => (description != null && description!.isNotEmpty);

  /// Returns true if there is at least one tag
  bool get hasTags => tags.isNotEmpty;

  /// Display name prioritizing title, then description, otherwise fallback
  String get displayName => title.isNotEmpty
      ? title
      : (description != null && description!.isNotEmpty
            ? description!
            : 'Untitled Bookmark');

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Bookmark && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Bookmark(id: $id, bookId: $bookId, chapterIndex: $chapterIndex, position: $position)';
  }
}
