/// Represents the metadata of an EPUB book
class EpubMetadata {
  /// The book's title
  final String title;

  /// The book's creator/author
  final String? creator;

  /// The book's publisher
  final String? publisher;

  /// The book's language
  final String? language;

  /// The book's identifier (ISBN, etc.)
  final String? identifier;

  /// The book's description
  final String? description;

  /// The book's subject/tags
  final List<String> subjects;

  /// The book's rights/copyright
  final String? rights;

  /// The book's date of publication
  final DateTime? date;

  /// The book's contributor
  final String? contributor;

  /// The book's coverage
  final String? coverage;

  /// The book's format
  final String? format;

  /// The book's relation
  final String? relation;

  /// The book's source
  final String? source;

  /// The book's type
  final String? type;

  /// Additional custom metadata
  final Map<String, String> custom;

  const EpubMetadata({
    required this.title,
    this.creator,
    this.publisher,
    this.language,
    this.identifier,
    this.description,
    this.subjects = const [],
    this.rights,
    this.date,
    this.contributor,
    this.coverage,
    this.format,
    this.relation,
    this.source,
    this.type,
    this.custom = const {},
  });

  /// Creates a copy of this metadata with updated values
  EpubMetadata copyWith({
    String? title,
    String? creator,
    String? publisher,
    String? language,
    String? identifier,
    String? description,
    List<String>? subjects,
    String? rights,
    DateTime? date,
    String? contributor,
    String? coverage,
    String? format,
    String? relation,
    String? source,
    String? type,
    Map<String, String>? custom,
  }) {
    return EpubMetadata(
      title: title ?? this.title,
      creator: creator ?? this.creator,
      publisher: publisher ?? this.publisher,
      language: language ?? this.language,
      identifier: identifier ?? this.identifier,
      description: description ?? this.description,
      subjects: subjects ?? this.subjects,
      rights: rights ?? this.rights,
      date: date ?? this.date,
      contributor: contributor ?? this.contributor,
      coverage: coverage ?? this.coverage,
      format: format ?? this.format,
      relation: relation ?? this.relation,
      source: source ?? this.source,
      type: type ?? this.type,
      custom: custom ?? this.custom,
    );
  }

  /// Converts the metadata to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'creator': creator,
      'publisher': publisher,
      'language': language,
      'identifier': identifier,
      'description': description,
      'subjects': subjects,
      'rights': rights,
      'date': date?.toIso8601String(),
      'contributor': contributor,
      'coverage': coverage,
      'format': format,
      'relation': relation,
      'source': source,
      'type': type,
      'custom': custom,
    };
  }

  /// Creates metadata from a JSON map
  factory EpubMetadata.fromJson(Map<String, dynamic> json) {
    return EpubMetadata(
      title: json['title'] as String,
      creator: json['creator'] as String?,
      publisher: json['publisher'] as String?,
      language: json['language'] as String?,
      identifier: json['identifier'] as String?,
      description: json['description'] as String?,
      subjects: List<String>.from(json['subjects'] as List? ?? []),
      rights: json['rights'] as String?,
      date: json['date'] != null
          ? DateTime.parse(json['date'] as String)
          : null,
      contributor: json['contributor'] as String?,
      coverage: json['coverage'] as String?,
      format: json['format'] as String?,
      relation: json['relation'] as String?,
      source: json['source'] as String?,
      type: json['type'] as String?,
      custom: Map<String, String>.from(json['custom'] as Map? ?? {}),
    );
  }

  @override
  String toString() {
    return 'EpubMetadata(title: $title, creator: $creator, language: $language)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is EpubMetadata &&
        other.title == title &&
        other.identifier == identifier;
  }

  @override
  int get hashCode => title.hashCode ^ (identifier?.hashCode ?? 0);
}
