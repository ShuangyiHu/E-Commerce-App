import 'package:flutter/material.dart';
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
    products = await dbService.getProducts();
    setState(() {});
  }

  void _addProduct(String name, String description, double price) async {
    await dbService.insertProduct(Product(
      name: name,
      description: description,
      price: price,
      categoryId: 1, // 假设一个类别 ID 以示例
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Products")),
      body: ListView.builder(
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          return ListTile(
            title: Text(product.name),
            subtitle: Text(product.description),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () {
                    // Handle edit product here
                  },
                ),
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    _deleteProduct(product.id!);
                  },
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add product logic here
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
