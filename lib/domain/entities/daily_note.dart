class DailyNote {
  final String id;
  final String? author;
  final String content;
  final List<String>? images;
  final String? location;
  final String? mood; // 开心, 平静, 伤心, 愤怒, 惊讶
  final String? weather; // 晴, 多云, 阴, 雨, 雪
  final bool isPrivate;
  final int likes;
  final int comments;
  final String? codeSnippet;
  final DateTime createdAt;
  final DateTime updatedAt;

  DailyNote({
    required this.id,
    this.author,
    required this.content,
    this.images,
    this.location,
    this.mood,
    this.weather,
    required this.isPrivate,
    this.likes = 0,
    this.comments = 0,
    this.codeSnippet,
    required this.createdAt,
    required this.updatedAt,
  });
} 