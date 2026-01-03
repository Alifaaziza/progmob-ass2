class Todo {
  String title;
  String address;
  double latitude;
  double longitude;

  Todo({
    required this.title,
    required this.address,
    required this.latitude,
    required this.longitude,
  });

  Map<String, dynamic> toJson() => {
        'title': title,
        'address': address,
        'latitude': latitude,
        'longitude': longitude,
      };

  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      title: json['title'],
      address: json['address'],
      latitude: json['latitude'],
      longitude: json['longitude'],
    );
  }
}
