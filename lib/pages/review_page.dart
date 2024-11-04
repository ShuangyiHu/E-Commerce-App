import 'package:flutter/material.dart';
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

  void _showAddReviewDialog() {
    int productId = 0;
    int rating = 1;
    String comment = '';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Review'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(labelText: 'Product ID'),
              keyboardType: TextInputType.number,
              onChanged: (value) => productId = int.tryParse(value) ?? 0,
            ),
            TextField(
              decoration: InputDecoration(labelText: 'Rating (1-5)'),
              keyboardType: TextInputType.number,
              onChanged: (value) => rating = int.tryParse(value) ?? 1,
            ),
            TextField(
              decoration: InputDecoration(labelText: 'Comment'),
              onChanged: (value) => comment = value,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (productId > 0 && rating >= 1 && rating <= 5) {
                _addReview(productId, rating, comment);
                Navigator.of(context).pop();
              }
            },
            child: Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showEditReviewDialog(Review review) {
    int rating = review.rating;
    String comment = review.comment;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Review'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(labelText: 'Rating (1-5)'),
              keyboardType: TextInputType.number,
              controller: TextEditingController(text: rating.toString()),
              onChanged: (value) =>
                  rating = int.tryParse(value) ?? review.rating,
            ),
            TextField(
              decoration: InputDecoration(labelText: 'Comment'),
              controller: TextEditingController(text: comment),
              onChanged: (value) => comment = value,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (rating >= 1 && rating <= 5) {
                _updateReview(
                    review.copyWith(rating: rating, comment: comment));
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
                    _deleteReview(review.id!);
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
