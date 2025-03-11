import 'package:intellimate/domain/entities/daily_note.dart';

class DailyNoteModel extends DailyNote {
  DailyNoteModel({
    required super.id,
    super.author,
    required super.content,
    super.images,
    super.location,
    super.mood,
    super.weather,
    required super.isPrivate,
    super.likes = 0,
    super.comments = 0,
    super.codeSnippet,
    required super.createdAt,
    required super.updatedAt,
  });

  // 从Map创建模型对象（用于数据库读取）
  factory DailyNoteModel.fromMap(Map<String, dynamic> map) {
    return DailyNoteModel(
      id: map['id'],
      author: map['author'],
      content: map['content'],
      images: map['images'] != null ? (map['images'] as String).split(',') : null,
      location: map['location'],
      mood: map['mood'],
      weather: map['weather'],
      isPrivate: map['is_private'] == 1,
      likes: map['likes'] ?? 0,
      comments: map['comments'] ?? 0,
      codeSnippet: map['code_snippet'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at']),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at']),
    );
  }

  // 转换为Map（用于数据库写入）
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'author': author,
      'content': content,
      'images': images?.join(','),
      'location': location,
      'mood': mood,
      'weather': weather,
      'is_private': isPrivate ? 1 : 0,
      'likes': likes,
      'comments': comments,
      'code_snippet': codeSnippet,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
    };
  }

  // 创建副本并修改部分属性
  DailyNoteModel copyWith({
    String? id,
    String? author,
    String? content,
    List<String>? images,
    String? location,
    String? mood,
    String? weather,
    bool? isPrivate,
    int? likes,
    int? comments,
    String? codeSnippet,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DailyNoteModel(
      id: id ?? this.id,
      author: author ?? this.author,
      content: content ?? this.content,
      images: images ?? this.images,
      location: location ?? this.location,
      mood: mood ?? this.mood,
      weather: weather ?? this.weather,
      isPrivate: isPrivate ?? this.isPrivate,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
      codeSnippet: codeSnippet ?? this.codeSnippet,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // 从实体创建模型
  factory DailyNoteModel.fromEntity(DailyNote dailyNote) {
    return DailyNoteModel(
      id: dailyNote.id,
      author: dailyNote.author,
      content: dailyNote.content,
      images: dailyNote.images,
      location: dailyNote.location,
      mood: dailyNote.mood,
      weather: dailyNote.weather,
      isPrivate: dailyNote.isPrivate,
      likes: dailyNote.likes,
      comments: dailyNote.comments,
      codeSnippet: dailyNote.codeSnippet,
      createdAt: dailyNote.createdAt,
      updatedAt: dailyNote.updatedAt,
    );
  }
} 