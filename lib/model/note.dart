class Note {
  String id;
  String title;
  String content;
  String userId;
  DateTime createdAt;
  DateTime updatedAt;
  List<String> tags;
  bool isPinned;
  String category;

  Note({
    required this.id,
    required this.title,
    required this.content,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
    this.tags = const [],
    this.isPinned = false,
    this.category = 'General',
  });

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      userId: json['userId'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      tags: List<String>.from(json['tags'] ?? []),
      isPinned: json['isPinned'] as bool? ?? false,
      category: json['category'] as String? ?? 'General',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'userId': userId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'tags': tags,
      'isPinned': isPinned,
      'category': category,
    };
  }

  Note copyWith({
    String? id,
    String? title,
    String? content,
    String? userId,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? tags,
    bool? isPinned,
    String? category,
  }) {
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      tags: tags ?? this.tags,
      isPinned: isPinned ?? this.isPinned,
      category: category ?? this.category,
    );
  }
}
