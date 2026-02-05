/// Represents the reading progress of a book
class ReadingProgress {
  /// Unique identifier for the progress
  final String id;

  /// The book ID this progress belongs to
  final String bookId;

  /// The current chapter index
  final int currentChapterIndex;

  /// The current position within the chapter (percentage 0.0 to 1.0)
  final double chapterProgress;

  /// The overall book progress (percentage 0.0 to 1.0)
  final double bookProgress;

  /// The current page number (if applicable)
  final int? currentPage;

  /// The total pages (if applicable)
  final int? totalPages;

  /// The last read position timestamp
  final DateTime lastReadAt;

  /// The total reading time in seconds
  final int totalReadingTime;

  /// The reading speed (words per minute)
  final double? readingSpeed;

  /// The estimated time to finish the book
  final Duration? estimatedTimeToFinish;

  const ReadingProgress({
    required this.id,
    required this.bookId,
    required this.currentChapterIndex,
    required this.chapterProgress,
    required this.bookProgress,
    this.currentPage,
    this.totalPages,
    required this.lastReadAt,
    this.totalReadingTime = 0,
    this.readingSpeed,
    this.estimatedTimeToFinish,
  });

  /// Creates a copy of this progress with updated values
  ReadingProgress copyWith({
    String? id,
    String? bookId,
    int? currentChapterIndex,
    double? chapterProgress,
    double? bookProgress,
    int? currentPage,
    int? totalPages,
    DateTime? lastReadAt,
    int? totalReadingTime,
    double? readingSpeed,
    Duration? estimatedTimeToFinish,
  }) {
    return ReadingProgress(
      id: id ?? this.id,
      bookId: bookId ?? this.bookId,
      currentChapterIndex: currentChapterIndex ?? this.currentChapterIndex,
      chapterProgress: chapterProgress ?? this.chapterProgress,
      bookProgress: bookProgress ?? this.bookProgress,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      lastReadAt: lastReadAt ?? this.lastReadAt,
      totalReadingTime: totalReadingTime ?? this.totalReadingTime,
      readingSpeed: readingSpeed ?? this.readingSpeed,
      estimatedTimeToFinish:
          estimatedTimeToFinish ?? this.estimatedTimeToFinish,
    );
  }

  /// Converts the progress to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bookId': bookId,
      'currentChapterIndex': currentChapterIndex,
      'chapterProgress': chapterProgress,
      'bookProgress': bookProgress,
      'currentPage': currentPage,
      'totalPages': totalPages,
      'lastReadAt': lastReadAt.toIso8601String(),
      'totalReadingTime': totalReadingTime,
      'readingSpeed': readingSpeed,
      'estimatedTimeToFinish': estimatedTimeToFinish?.inSeconds,
    };
  }

  /// Creates progress from a JSON map
  factory ReadingProgress.fromJson(Map<String, dynamic> json) {
    return ReadingProgress(
      id: json['id'] as String,
      bookId: json['bookId'] as String,
      currentChapterIndex: json['currentChapterIndex'] as int,
      chapterProgress: (json['chapterProgress'] as num).toDouble(),
      bookProgress: (json['bookProgress'] as num).toDouble(),
      currentPage: json['currentPage'] as int?,
      totalPages: json['totalPages'] as int?,
      lastReadAt: DateTime.parse(json['lastReadAt'] as String),
      totalReadingTime: json['totalReadingTime'] as int? ?? 0,
      readingSpeed: json['readingSpeed'] != null
          ? (json['readingSpeed'] as num).toDouble()
          : null,
      estimatedTimeToFinish: json['estimatedTimeToFinish'] != null
          ? Duration(seconds: json['estimatedTimeToFinish'] as int)
          : null,
    );
  }

  /// Creates initial progress for a new book
  factory ReadingProgress.initial(String bookId) {
    return ReadingProgress(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      bookId: bookId,
      currentChapterIndex: 0,
      chapterProgress: 0.0,
      bookProgress: 0.0,
      lastReadAt: DateTime.now(),
    );
  }

  /// Gets the progress as a percentage string
  String get bookProgressPercentage =>
      '${(bookProgress * 100).toStringAsFixed(1)}%';

  /// Gets the chapter progress as a percentage string
  String get chapterProgressPercentage =>
      '${(chapterProgress * 100).toStringAsFixed(1)}%';

  /// Checks if the book is finished
  bool get isFinished => bookProgress >= 1.0;

  /// Checks if the chapter is finished
  bool get isChapterFinished => chapterProgress >= 1.0;

  @override
  String toString() {
    return 'ReadingProgress(bookId: $bookId, chapter: $currentChapterIndex, progress: $bookProgressPercentage)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ReadingProgress && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
