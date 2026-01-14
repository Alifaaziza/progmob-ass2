class Todo {
  String title;
  String note;        // ✅ catatan
  String placeName;   // ✅ nama lokasi
  String address;
  double latitude;
  double longitude;

  Todo({
    required this.title,
    required this.note,
    required this.placeName,
    required this.address,
    required this.latitude,
    required this.longitude,
  });

  Map<String, dynamic> toJson() => {
        'title': title,
        'note': note,
        'placeName': placeName,
        'address': address,
        'latitude': latitude,
        'longitude': longitude,
      };

  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      title: (json['title'] ?? '').toString(),
      note: (json['note'] ?? '').toString(),
      placeName: (json['placeName'] ?? '').toString(),
      address: (json['address'] ?? '').toString(),
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
    );
  }
}
