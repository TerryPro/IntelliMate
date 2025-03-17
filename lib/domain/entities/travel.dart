import 'package:equatable/equatable.dart';

enum TravelStatus {
  planning,
  ongoing,
  completed,
}

class Travel extends Equatable {
  final String? id;
  final String title;
  final String? description;
  final List<String> places;
  final DateTime startDate;
  final DateTime endDate;
  final TravelStatus status;
  final List<TravelTask> tasks;
  final List<TravelAccommodation> accommodations;
  final double budget;
  final double? actualCost;
  final int peopleCount;
  final int? photoCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Travel({
    this.id,
    required this.title,
    this.description,
    required this.places,
    required this.startDate,
    required this.endDate,
    required this.status,
    this.tasks = const [],
    this.accommodations = const [],
    this.budget = 0.0,
    this.actualCost,
    this.peopleCount = 1,
    this.photoCount,
    required this.createdAt,
    required this.updatedAt,
  });

  Travel copyWith({
    String? id,
    String? title,
    String? description,
    List<String>? places,
    DateTime? startDate,
    DateTime? endDate,
    TravelStatus? status,
    List<TravelTask>? tasks,
    List<TravelAccommodation>? accommodations,
    double? budget,
    double? actualCost,
    int? peopleCount,
    int? photoCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Travel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      places: places ?? this.places,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      status: status ?? this.status,
      tasks: tasks ?? this.tasks,
      accommodations: accommodations ?? this.accommodations,
      budget: budget ?? this.budget,
      actualCost: actualCost ?? this.actualCost,
      peopleCount: peopleCount ?? this.peopleCount,
      photoCount: photoCount ?? this.photoCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'places': places,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'status': status.index,
      'tasks': tasks.map((task) => task.toJson()).toList(),
      'accommodations': accommodations.map((accommodation) => accommodation.toJson()).toList(),
      'budget': budget,
      'actualCost': actualCost,
      'peopleCount': peopleCount,
      'photoCount': photoCount,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Travel.fromJson(Map<String, dynamic> json) {
    return Travel(
      id: json['id'] as String?,
      title: json['title'] as String,
      description: json['description'] as String?,
      places: (json['places'] as List<dynamic>).map((e) => e as String).toList(),
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      status: TravelStatus.values[json['status'] as int],
      tasks: (json['tasks'] as List<dynamic>)
          .map((e) => TravelTask.fromJson(e as Map<String, dynamic>))
          .toList(),
      accommodations: (json['accommodations'] as List<dynamic>?)
          ?.map((e) => TravelAccommodation.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      budget: (json['budget'] as num?)?.toDouble() ?? 0.0,
      actualCost: (json['actualCost'] as num?)?.toDouble(),
      peopleCount: json['peopleCount'] as int? ?? 1,
      photoCount: json['photoCount'] as int?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        places,
        startDate,
        endDate,
        status,
        tasks,
        accommodations,
        budget,
        actualCost,
        peopleCount,
        photoCount,
        createdAt,
        updatedAt,
      ];
}

class TravelTask extends Equatable {
  final String? id;
  final String title;
  final String? description;
  final String? location;
  final DateTime startTime;
  final DateTime endTime;
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime updatedAt;

  const TravelTask({
    this.id,
    required this.title,
    this.description,
    this.location,
    required this.startTime,
    required this.endTime,
    this.isCompleted = false,
    required this.createdAt,
    required this.updatedAt,
  });

  TravelTask copyWith({
    String? id,
    String? title,
    String? description,
    String? location,
    DateTime? startTime,
    DateTime? endTime,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TravelTask(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      location: location ?? this.location,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'location': location,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'isCompleted': isCompleted ? 1 : 0,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory TravelTask.fromJson(Map<String, dynamic> json) {
    return TravelTask(
      id: json['id'] as String?,
      title: json['title'] as String,
      description: json['description'] as String?,
      location: json['location'] as String?,
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: DateTime.parse(json['endTime'] as String),
      isCompleted: (json['isCompleted'] as int) == 1,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        location,
        startTime,
        endTime,
        isCompleted,
        createdAt,
        updatedAt,
      ];
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

class TravelAccommodation extends Equatable {
  final String? id;
  final String name;
  final String? address;
  final String? phone;
  final DateTime checkInDate;
  final DateTime checkOutDate;
  final double price;
  final String? bookingNumber;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  const TravelAccommodation({
    this.id,
    required this.name,
    this.address,
    this.phone,
    required this.checkInDate,
    required this.checkOutDate,
    required this.price,
    this.bookingNumber,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  TravelAccommodation copyWith({
    String? id,
    String? name,
    String? address,
    String? phone,
    DateTime? checkInDate,
    DateTime? checkOutDate,
    double? price,
    String? bookingNumber,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TravelAccommodation(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      checkInDate: checkInDate ?? this.checkInDate,
      checkOutDate: checkOutDate ?? this.checkOutDate,
      price: price ?? this.price,
      bookingNumber: bookingNumber ?? this.bookingNumber,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'phone': phone,
      'checkInDate': checkInDate.toIso8601String(),
      'checkOutDate': checkOutDate.toIso8601String(),
      'price': price,
      'bookingNumber': bookingNumber,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory TravelAccommodation.fromJson(Map<String, dynamic> json) {
    return TravelAccommodation(
      id: json['id'] as String?,
      name: json['name'] as String,
      address: json['address'] as String?,
      phone: json['phone'] as String?,
      checkInDate: DateTime.parse(json['checkInDate'] as String),
      checkOutDate: DateTime.parse(json['checkOutDate'] as String),
      price: (json['price'] as num).toDouble(),
      bookingNumber: json['bookingNumber'] as String?,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        address,
        phone,
        checkInDate,
        checkOutDate,
        price,
        bookingNumber,
        notes,
        createdAt,
        updatedAt,
      ];
} 