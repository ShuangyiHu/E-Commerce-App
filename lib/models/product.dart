class Product {
  int? id;
  String name;
  String description;
  double price;
  int categoryId; // Add this to link product to category
  String imageUrl;
  int stockQuantity;
  String categoryName;

  Product({
    this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.categoryId,
    required this.imageUrl,
    required this.stockQuantity,
    required this.categoryName,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'category_id': categoryId, // Map this to categoryId in the database
      'image_url': imageUrl,
      'stock_quantity': stockQuantity,
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'],
      name: map['name'] ?? '', // Provide a default empty string if null
      description: map['description'] ?? '',
      price: map['price'] ?? 0.0,
      categoryId: map['category_id'],
      imageUrl: map['image_url'] ?? '',
      stockQuantity: map['stock_quantity'] ?? 0,
      categoryName:
          map['categoryName'] ?? '', // Ensure this is handled if it's nullable
    );
  }

  Product copyWith({
    int? id,
    String? name,
    String? description,
    double? price,
    int? categoryId,
    String? categoryName,
    String? imageUrl,
    int? stockQuantity,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      imageUrl: imageUrl ?? this.imageUrl,
      stockQuantity: stockQuantity ?? this.stockQuantity,
    );
  }
}
