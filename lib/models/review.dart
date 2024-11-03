class Review {
  final int? id;
  final int productId;
  final int rating;
  final String comment;
  final DateTime createdAt;

  Review({
    this.id,
    required this.productId,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  // Convert Review object to a map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'product_id': productId,
      'rating': rating,
      'comment': comment,
      'created_at': createdAt.toIso8601String(),
    };
  }

  // Create Review object from a map
  factory Review.fromMap(Map<String, dynamic> map) {
    return Review(
      id: map['id'],
      productId: map['product_id'],
      rating: map['rating'],
      comment: map['comment'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  // Create a copy of Review with optional parameter updates
  Review copyWith({
    int? id,
    int? productId,
    int? rating,
    String? comment,
    DateTime? createdAt,
  }) {
    return Review(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'Review(id: $id, productId: $productId, rating: $rating)';
  }
}