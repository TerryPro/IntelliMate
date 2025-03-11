class Travel {
  final int? id;
  final String title;
  final String? description;
  final DateTime startDate;
  final DateTime endDate;
  final String destination;
  final List<String> places;
  final int peopleCount;
  final double budget;
  final double? actualCost;
  final TravelStatus status;
  final int? photoCount;
  final List<TravelTask>? tasks;
  final String? notes;

  Travel({
    this.id,
    required this.title,
    this.description,
    required this.startDate,
    required this.endDate,
    required this.destination,
    required this.places,
    required this.peopleCount,
    required this.budget,
    this.actualCost,
    required this.status,
    this.photoCount,
    this.tasks,
    this.notes,
  });

  Travel copyWith({
    int? id,
    String? title,
    String? description,
    DateTime? startDate,
    DateTime? endDate,
    String? destination,
    List<String>? places,
    int? peopleCount,
    double? budget,
    double? actualCost,
    TravelStatus? status,
    int? photoCount,
    List<TravelTask>? tasks,
    String? notes,
  }) {
    return Travel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      destination: destination ?? this.destination,
      places: places ?? this.places,
      peopleCount: peopleCount ?? this.peopleCount,
      budget: budget ?? this.budget,
      actualCost: actualCost ?? this.actualCost,
      status: status ?? this.status,
      photoCount: photoCount ?? this.photoCount,
      tasks: tasks ?? this.tasks,
      notes: notes ?? this.notes,
    );
  }
}

enum TravelStatus {
  planning, // 计划中
  ongoing,  // 进行中
  completed // 已完成
}

class TravelTask {
  final int? id;
  final String title;
  final bool isCompleted;
  final DateTime? dueDate;
  final String? notes;
  final TravelTaskType type;

  TravelTask({
    this.id,
    required this.title,
    this.isCompleted = false,
    this.dueDate,
    this.notes,
    required this.type,
  });

  TravelTask copyWith({
    int? id,
    String? title,
    bool? isCompleted,
    DateTime? dueDate,
    String? notes,
    TravelTaskType? type,
  }) {
    return TravelTask(
      id: id ?? this.id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
      dueDate: dueDate ?? this.dueDate,
      notes: notes ?? this.notes,
      type: type ?? this.type,
    );
  }
}

enum TravelTaskType {
  itinerary,    // 行程规划
  accommodation, // 住宿管理
  transportation, // 交通管理
  packing,      // 行李清单
  ticket,       // 票务管理
  expense,      // 花费记录
  other         // 其他
} 