 import 'dart:convert';
import 'package:intellimate/domain/entities/goal.dart';

class GoalModel extends Goal {
  GoalModel({
    required super.id,
    required super.title,
    super.description,
    required super.startDate,
    super.endDate,
    required super.progress,
    required super.status,
    super.category,
    super.milestones,
    required super.createdAt,
    required super.updatedAt,
  });

  // 从Map创建模型对象（用于数据库读取）
  factory GoalModel.fromMap(Map<String, dynamic> map) {
    return GoalModel(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      startDate: DateTime.fromMillisecondsSinceEpoch(map['start_date']),
      endDate: map['end_date'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['end_date'])
          : null,
      progress: map['progress'],
      status: map['status'],
      category: map['category'],
      milestones: map['milestones'] != null 
          ? List<String>.from(json.decode(map['milestones']))
          : null,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at']),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at']),
    );
  }

  // 转换为Map（用于数据库写入）
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'start_date': startDate.millisecondsSinceEpoch,
      'end_date': endDate?.millisecondsSinceEpoch,
      'progress': progress,
      'status': status,
      'category': category,
      'milestones': milestones != null ? json.encode(milestones) : null,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
    };
  }

  // 创建副本并修改部分属性
  GoalModel copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? startDate,
    DateTime? endDate,
    double? progress,
    String? status,
    String? category,
    List<String>? milestones,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return GoalModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      progress: progress ?? this.progress,
      status: status ?? this.status,
      category: category ?? this.category,
      milestones: milestones ?? this.milestones,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // 从实体创建模型
  factory GoalModel.fromEntity(Goal goal) {
    return GoalModel(
      id: goal.id,
      title: goal.title,
      description: goal.description,
      startDate: goal.startDate,
      endDate: goal.endDate,
      progress: goal.progress,
      status: goal.status,
      category: goal.category,
      milestones: goal.milestones,
      createdAt: goal.createdAt,
      updatedAt: goal.updatedAt,
    );
  }
}