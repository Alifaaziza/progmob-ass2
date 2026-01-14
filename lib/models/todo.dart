class Todo {
  int? id;
  String title;
  String? address;
  double? latitude;
  double? longitude;
  DateTime date;
  bool isDone;
  DateTime createdAt;
  DateTime updatedAt;

  Todo({
    this.id,
    required this.title,
    this.address,
    this.latitude,
    this.longitude,
    required this.date,
    this.isDone = false,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  /* =======================
   * SQLITE
   * ======================= */

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'date': date.toIso8601String(),
      'isDone': isDone ? 1 : 0,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
    };
  }

  factory Todo.fromMap(Map<String, dynamic> map) {
    return Todo(
      id: map['id'],
      title: map['title'],
      address: map['address'],
      latitude: (map['latitude'] as num?)?.toDouble(),
      longitude: (map['longitude'] as num?)?.toDouble(),
      date: DateTime.parse(map['date']),
      isDone: map['isDone'] == 1,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at']),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at']),
    );
  }

  /* =======================
   * API / JSON
   * ======================= */

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'date': date.toIso8601String(),
      'is_done': isDone,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      id: json['id'],
      title: json['title'],
      address: json['address'],
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      date: DateTime.parse(json['date']),
      isDone: json['is_done'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  /* =======================
   * HELPER
   * ======================= */

  Todo copyWith({
    int? id,
    String? title,
    String? address,
    double? latitude,
    double? longitude,
    DateTime? date,
    bool? isDone,
  }) {
    return Todo(
      id: id ?? this.id,
      title: title ?? this.title,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      date: date ?? this.date,
      isDone: isDone ?? this.isDone,
      createdAt: createdAt,
      updatedAt: DateTime.now(), // ✅ FIX
    );
  }
}
