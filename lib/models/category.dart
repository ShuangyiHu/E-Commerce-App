class Category {
  final int? id;
  final String name;
  final String description;

  Category({
    this.id,
    required this.name,
    required this.description,
  });

  // Convert Category object to a map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
    };
  }

  // Create Category object from a map
  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'],
      name: map['name'],
      description: map['description'],
    );
  }

  // Create a copy of Category with optional parameter updates
  Category copyWith({
    int? id,
    String? name,
    String? description,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
    );
  }

  @override
  String toString() {
    return 'Category(id: $id, name: $name, description: $description)';
  }
}
