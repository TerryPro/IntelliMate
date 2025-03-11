class Note {
  final String id;
  final String title;
  final String content;
  final List<String>? tags;
  final String? category;
  final bool isFavorite;
  final DateTime createdAt;
  final DateTime updatedAt;

  Note({
    required this.id,
    required this.title,
    required this.content,
    this.tags,
    this.category,
    required this.isFavorite,
    required this.createdAt,
    required this.updatedAt,
  });
} 