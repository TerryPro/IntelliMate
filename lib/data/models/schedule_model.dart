import 'package:intellimate/domain/entities/schedule.dart';

class ScheduleModel extends Schedule {
  ScheduleModel({
    required super.id,
    required super.title,
    super.description,
    required super.startTime,
    required super.endTime,
    super.location,
    required super.isAllDay,
    super.category,
    required super.isRepeated,
    super.repeatType,
    super.participants,
    super.reminder,
    required super.createdAt,
    required super.updatedAt,
  });

  // 从Map创建模型对象（用于数据库读取）
  factory ScheduleModel.fromMap(Map<String, dynamic> map) {
    return ScheduleModel(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      startTime: DateTime.fromMillisecondsSinceEpoch(map['start_time']),
      endTime: DateTime.fromMillisecondsSinceEpoch(map['end_time']),
      location: map['location'],
      isAllDay: map['is_all_day'] == 1,
      category: map['category'],
      isRepeated: map['is_repeated'] == 1,
      repeatType: map['repeat_type'],
      participants: map['participants'] != null ? map['participants'].split(',') : null,
      reminder: map['reminder'],
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
      'start_time': startTime.millisecondsSinceEpoch,
      'end_time': endTime.millisecondsSinceEpoch,
      'location': location,
      'is_all_day': isAllDay ? 1 : 0,
      'category': category,
      'is_repeated': isRepeated ? 1 : 0,
      'repeat_type': repeatType,
      'participants': participants?.join(','),
      'reminder': reminder,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
    };
  }

  // 创建副本并修改部分属性
  ScheduleModel copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? startTime,
    DateTime? endTime,
    String? location,
    bool? isAllDay,
    String? category,
    bool? isRepeated,
    String? repeatType,
    List<String>? participants,
    String? reminder,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ScheduleModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      location: location ?? this.location,
      isAllDay: isAllDay ?? this.isAllDay,
      category: category ?? this.category,
      isRepeated: isRepeated ?? this.isRepeated,
      repeatType: repeatType ?? this.repeatType,
      participants: participants ?? this.participants,
      reminder: reminder ?? this.reminder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // 从实体创建模型
  factory ScheduleModel.fromEntity(Schedule schedule) {
    return ScheduleModel(
      id: schedule.id,
      title: schedule.title,
      description: schedule.description,
      startTime: schedule.startTime,
      endTime: schedule.endTime,
      location: schedule.location,
      isAllDay: schedule.isAllDay,
      category: schedule.category,
      isRepeated: schedule.isRepeated,
      repeatType: schedule.repeatType,
      participants: schedule.participants,
      reminder: schedule.reminder,
      createdAt: schedule.createdAt,
      updatedAt: schedule.updatedAt,
    );
  }
} 