class Memo {
  final String id;
  final String title;
  final String? content;
  final String? category;
  final DateTime createdAt;
  final DateTime updatedAt;

  Memo({
    required this.id,
    required this.title,
    this.content,
    this.category,
    required this.createdAt,
    required this.updatedAt,
  });
}
