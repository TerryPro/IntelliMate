import 'package:intellimate/domain/entities/memo.dart';

class MemoModel extends Memo {
  MemoModel({
    required super.id,
    required super.title,
    super.content,
    super.category,
    required super.createdAt,
    required super.updatedAt,
  });

  // 从实体类创建模型
  factory MemoModel.fromEntity(Memo memo) {
    return MemoModel(
      id: memo.id,
      title: memo.title,
      content: memo.content,
      category: memo.category,
      createdAt: memo.createdAt,
      updatedAt: memo.updatedAt,
    );
  }

  // 从Map创建模型
  factory MemoModel.fromMap(Map<String, dynamic> map) {
    return MemoModel(
      id: map['id'],
      title: map['title'],
      content: map['content'],
      category: map['category'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at']),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at']),
    );
  }

  // 转换为Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'category': category,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
    };
  }

  // 创建副本
  MemoModel copyWith({
    String? id,
    String? title,
    String? content,
    String? category,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MemoModel(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
