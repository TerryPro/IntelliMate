import 'package:intellimate/domain/entities/memo.dart';

class MemoModel extends Memo {
  MemoModel({
    required String id,
    required String title,
    required String content,
    required DateTime date,
    String? category,
    required String priority,
    required bool isPinned,
    required bool isCompleted,
    DateTime? completedAt,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : super(
          id: id,
          title: title,
          content: content,
          date: date,
          category: category,
          priority: priority,
          isPinned: isPinned,
          isCompleted: isCompleted,
          completedAt: completedAt,
          createdAt: createdAt,
          updatedAt: updatedAt,
        );

  // 从实体类创建模型
  factory MemoModel.fromEntity(Memo memo) {
    return MemoModel(
      id: memo.id,
      title: memo.title,
      content: memo.content,
      date: memo.date,
      category: memo.category,
      priority: memo.priority,
      isPinned: memo.isPinned,
      isCompleted: memo.isCompleted,
      completedAt: memo.completedAt,
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
      date: DateTime.fromMillisecondsSinceEpoch(map['date']),
      category: map['category'],
      priority: map['priority'],
      isPinned: map['is_pinned'] == 1,
      isCompleted: map['is_completed'] == 1,
      completedAt: map['completed_at'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['completed_at']) 
          : null,
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
      'date': date.millisecondsSinceEpoch,
      'category': category,
      'priority': priority,
      'is_pinned': isPinned ? 1 : 0,
      'is_completed': isCompleted ? 1 : 0,
      'completed_at': completedAt?.millisecondsSinceEpoch,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
    };
  }

  // 创建副本
  MemoModel copyWith({
    String? id,
    String? title,
    String? content,
    DateTime? date,
    String? category,
    String? priority,
    bool? isPinned,
    bool? isCompleted,
    DateTime? completedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MemoModel(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      date: date ?? this.date,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      isPinned: isPinned ?? this.isPinned,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
} 