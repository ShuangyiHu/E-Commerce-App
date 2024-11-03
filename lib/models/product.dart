class Product {
  final int? id;
  final String name;
  final String description;
  final double price;
  final int categoryId;
  final String imageUrl;
  final int stockQuantity;

  Product({
    this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.categoryId,
    required this.imageUrl,
    required this.stockQuantity,
  });

  // Convert Product object to a map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'category_id': categoryId,
      'image_url': imageUrl,
      'stock_quantity': stockQuantity,
    };
  }

  // Create Product object from a map
  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      price: map['price'],
      categoryId: map['category_id'],
      imageUrl: map['image_url'],
      stockQuantity: map['stock_quantity'],
    );
  }

  // Create a copy of Product with optional parameter updates
  Product copyWith({
    int? id,
    String? name,
    String? description,
    double? price,
    int? categoryId,
    String? imageUrl,
    int? stockQuantity,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      categoryId: categoryId ?? this.categoryId,
      imageUrl: imageUrl ?? this.imageUrl,
      stockQuantity: stockQuantity ?? this.stockQuantity,
    );
  }

  @override
  String toString() {
    return 'Product(id: $id, name: $name, price: $price, categoryId: $categoryId)';
  }
}