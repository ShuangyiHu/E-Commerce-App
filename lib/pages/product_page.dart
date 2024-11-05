import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/category.dart' as model;
import '../services/database_service.dart';
import '../models/product.dart';

class ProductPage extends StatefulWidget {
  @override
  _ProductPageState createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  final DatabaseService dbService = DatabaseService();
  List<Product> products = [];

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    final productMaps = await dbService.getProductsWithCategoryNames();
    products = productMaps.map((map) {
      return Product(
        id: map['id'],
        name: map['name'],
        description: map['description'],
        price: map['price'],
        categoryId: map['category_id'],
        imageUrl: map['image_url'],
        stockQuantity: map['stock_quantity'],
        categoryName: map['categoryName'],
      );
    }).toList();
    setState(() {});
  }

  void _addProduct(String name, String description, double price,
      int categoryId, String categoryName) async {
    await dbService.insertProduct(Product(
      name: name,
      description: description,
      price: price,
      categoryId: categoryId,
      categoryName: categoryName,
      imageUrl: '',
      stockQuantity: 10,
    ));
    _loadProducts();
  }

  void _updateProduct(Product product) async {
    await dbService.updateProduct(product);
    _loadProducts();
  }

  void _deleteProduct(int id) async {
    await dbService.deleteProduct(id);
    _loadProducts();
  }

  void _showEditProductDialog(Product product) {
    final nameController = TextEditingController(text: product.name);
    final descController = TextEditingController(text: product.description);
    final priceController =
        TextEditingController(text: product.price.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Product'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 8),
              TextField(
                controller: descController,
                decoration: InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 8),
              TextField(
                controller: priceController,
                decoration: InputDecoration(
                  labelText: 'Price',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
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
              final name = nameController.text;
              final description = descController.text;
              final price = double.tryParse(priceController.text) ?? 0.0;

              if (name.isNotEmpty) {
                _updateProduct(
                  product.copyWith(
                    name: name,
                    description: description,
                    price: price,
                  ),
                );
                Navigator.of(context).pop();
              }
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmationDialog(Product product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Product'),
        content: Text('Are you sure you want to delete "${product.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(), // Dismiss the dialog
            child: Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.red, // Set the button color to red
            ),
            onPressed: () {
              _deleteProduct(product.id!); // Call the delete function
              Navigator.of(context).pop(); // Dismiss the dialog
            },
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Products")),
      body: ListView.builder(
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          return ListTile(
            title: Text("${index + 1}. ${product.name}"),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    "Description: ${product.description == "" ? '--' : product.description}"),
                Text("Price: \$${product.price.toStringAsFixed(2)}"),
                Text(
                    "Category: ${product.categoryId} (${product.categoryName})"),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () {
                    _showEditProductDialog(product);
                  },
                ),
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () => _showDeleteConfirmationDialog(product),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add product dialog or function call here
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
