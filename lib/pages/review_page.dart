import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/category.dart';
import 'package:flutter_application_1/models/product.dart';
import '../services/database_service.dart';
import '../models/review.dart';

class ReviewPage extends StatefulWidget {
  @override
  _ReviewPageState createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  final DatabaseService dbService = DatabaseService();
  List<Review> reviews = [];

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  Future<void> _loadReviews() async {
    reviews = await dbService.getReviews();
    setState(() {});
  }

  void _addReview(int productId, int rating, String comment) async {
    await dbService.insertReview(Review(
      productId: productId,
      rating: rating,
      comment: comment,
      createdAt: DateTime.now(),
    ));
    _loadReviews();
  }

  void _updateReview(Review review) async {
    await dbService.updateReview(review);
    _loadReviews();
  }

  void _deleteReview(int id) async {
    await dbService.deleteReview(id);
    _loadReviews();
  }

  void _showDeleteConfirmationDialog(Review review) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Review'),
        content: Text('Are you sure you want to delete this review?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              _deleteReview(review.id!);
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.red,
            ),
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showAddReviewDialog() async {
    List<Category> categories = await dbService.fetchAllCategories();
    Category? selectedCategory;
    List<Product> products = [];
    Product? selectedProduct;

    TextEditingController ratingController = TextEditingController();
    TextEditingController commentController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text("Add Review"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<Category>(
                      value: selectedCategory,
                      items: categories.map((category) {
                        return DropdownMenuItem<Category>(
                          value: category,
                          child: Text(category.name),
                        );
                      }).toList(),
                      onChanged: (newCategory) async {
                        setState(() {
                          selectedCategory = newCategory;
                          selectedProduct = null;
                        });

                        if (selectedCategory != null) {
                          products = await dbService
                              .getProductsByCategory(selectedCategory!.id!);
                          setState(() {});
                        }
                      },
                      decoration: InputDecoration(labelText: "Category"),
                    ),
                    DropdownButtonFormField<Product>(
                      value: selectedProduct,
                      items: products.map((product) {
                        return DropdownMenuItem<Product>(
                          value: product,
                          child: Text(product.name),
                        );
                      }).toList(),
                      onChanged: (newProduct) {
                        setState(() {
                          selectedProduct = newProduct;
                        });
                      },
                      decoration: InputDecoration(labelText: "Product"),
                    ),
                    TextField(
                      controller: ratingController,
                      decoration: InputDecoration(labelText: "Rating (1-5)"),
                      keyboardType: TextInputType.number,
                    ),
                    TextField(
                      controller: commentController,
                      decoration: InputDecoration(labelText: "Comment"),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () {
                    final ratingText = ratingController.text;
                    final rating = int.tryParse(ratingText);
                    final comment = commentController.text;

                    if (rating == null || rating < 1 || rating > 5) {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text("Invalid Rating"),
                          content: Text(
                              "Please enter a valid rating between 1 and 5."),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: Text("OK"),
                            ),
                          ],
                        ),
                      );
                    } else if (selectedProduct != null) {
                      dbService.insertReview(Review(
                        productId: selectedProduct!.id!,
                        rating: rating,
                        comment: comment,
                        createdAt: DateTime.now(),
                      ));
                      Navigator.of(context).pop();
                      _loadReviews();
                    }
                  },
                  child: Text("Add"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showEditReviewDialog(Review review) {
    int rating = review.rating;
    String comment = review.comment;

    TextEditingController ratingController =
        TextEditingController(text: rating.toString());
    TextEditingController commentController =
        TextEditingController(text: comment);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Review'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(labelText: 'Rating (1-5)'),
                keyboardType: TextInputType.number,
                controller: ratingController,
                onChanged: (value) {
                  rating = int.tryParse(value) ?? review.rating;
                },
              ),
              TextField(
                decoration: InputDecoration(labelText: 'Comment'),
                controller: commentController,
                onChanged: (value) {
                  comment = value;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final ratingText = ratingController.text;
              final ratingValue = int.tryParse(ratingText);

              if (ratingValue == null || ratingValue < 1 || ratingValue > 5) {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text("Invalid Rating"),
                    content:
                        Text("Please enter a valid rating between 1 and 5."),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text("OK"),
                      ),
                    ],
                  ),
                );
              } else {
                _updateReview(
                  review.copyWith(
                    rating: ratingValue,
                    comment: commentController.text,
                  ),
                );
                Navigator.of(context).pop();
              }
            },
            child: Text('Update'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Reviews")),
      body: ListView.builder(
        itemCount: reviews.length,
        itemBuilder: (context, index) {
          final review = reviews[index];
          return ListTile(
            title: Text("Product ID: ${review.productId}"),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Rating: ${review.rating}"),
                Text("Comment: ${review.comment}"),
                Text(
                    "Date: ${review.createdAt.toLocal().toString().split(' ')[0]}"),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () {
                    _showEditReviewDialog(review);
                  },
                ),
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    _showDeleteConfirmationDialog(review);
                  },
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddReviewDialog,
        child: Icon(Icons.add),
      ),
    );
  }
}
