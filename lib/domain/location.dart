class Location {
  final String id;
  final String name;

  const Location({
    required this.id,
    required this.name,
  });

  Location copyWith({
    String? id,
    String? name,
  }) {
    return Location(
      id: id ?? this.id,
      name: name ?? this.name,
    );
  }
}
