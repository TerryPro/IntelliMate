class Schedule {
  final String id;
  final String title;
  final String? description;
  final DateTime startTime;
  final DateTime endTime;
  final String? location;
  final bool isAllDay;
  final String? category;
  final bool isRepeated;
  final String? repeatType; // daily, weekly, monthly, yearly
  final List<String>? participants;
  final String? reminder; // 无, 提前5分钟, 提前15分钟, 提前30分钟, 提前1小时, 提前1天
  final DateTime createdAt;
  final DateTime updatedAt;

  Schedule({
    required this.id,
    required this.title,
    this.description,
    required this.startTime,
    required this.endTime,
    this.location,
    required this.isAllDay,
    this.category,
    required this.isRepeated,
    this.repeatType,
    this.participants,
    this.reminder,
    required this.createdAt,
    required this.updatedAt,
  });
} 