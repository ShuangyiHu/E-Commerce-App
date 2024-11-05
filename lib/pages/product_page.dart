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
  List<model.Category> categories = [];
  model.Category? selectedCategory;

  @override
  void initState() {
    super.initState();
    _loadProducts();
    _loadCategories();
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

  Future<void> _loadCategories() async {
    categories = await dbService.fetchAllCategories();
    setState(() {});
  }

  void _addProduct(String name, String description, double price,
      int categoryId, String categoryName) async {
    await dbService.insertProduct(Product(
      name: name,
      description: description,
      price: price,
      categoryId: categoryId,
      imageUrl: '',
      stockQuantity: 10,
      categoryName: categoryName,
    ));
    _loadProducts();
  }

  void _updateProduct(Product product) async {
    await dbService.updateProduct(product);
    _loadProducts();
  }

  void _deleteProduct(int id) async {
    bool confirmed = await _showDeleteConfirmationDialog();
    if (confirmed) {
      await dbService.deleteProduct(id);
      _loadProducts();
    }
  }

  Future<bool> _showDeleteConfirmationDialog() async {
    return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Delete Product'),
            content: Text('Are you sure you want to delete this product?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text('Delete'),
              ),
            ],
          ),
        ) ??
        false;
  }

  void _showAddProductDialog() {
    TextEditingController nameController = TextEditingController();
    TextEditingController descriptionController = TextEditingController();
    TextEditingController priceController = TextEditingController();
    model.Category? selectedCategory;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text("Add Product"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(labelText: "Name"),
                    ),
                    TextField(
                      controller: descriptionController,
                      decoration: InputDecoration(labelText: "Description"),
                    ),
                    TextField(
                      controller: priceController,
                      decoration: InputDecoration(labelText: "Price"),
                      keyboardType: TextInputType.number,
                    ),
                    DropdownButtonFormField<model.Category>(
                      value: selectedCategory,
                      items: categories.map((category) {
                        return DropdownMenuItem<model.Category>(
                          value: category,
                          child: Text(category.name),
                        );
                      }).toList(),
                      onChanged: (newCategory) {
                        setState(() {
                          selectedCategory = newCategory;
                        });
                      },
                      decoration: InputDecoration(labelText: "Category"),
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
                    final name = nameController.text;
                    final description = descriptionController.text;
                    final price = double.tryParse(priceController.text) ?? 0.0;

                    if (name.isNotEmpty && selectedCategory != null) {
                      _addProduct(name, description, price,
                          selectedCategory!.id!, selectedCategory!.name);
                      Navigator.of(context).pop();
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

  void _showEditProductDialog(Product product) {
    TextEditingController nameController =
        TextEditingController(text: product.name);
    TextEditingController descriptionController =
        TextEditingController(text: product.description);
    TextEditingController priceController =
        TextEditingController(text: product.price.toString());
    selectedCategory =
        categories.firstWhere((category) => category.id == product.categoryId);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text("Edit Product"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(labelText: "Name"),
                    ),
                    TextField(
                      controller: descriptionController,
                      decoration: InputDecoration(labelText: "Description"),
                    ),
                    TextField(
                      controller: priceController,
                      decoration: InputDecoration(labelText: "Price"),
                      keyboardType: TextInputType.number,
                    ),
                    DropdownButtonFormField<model.Category>(
                      value: selectedCategory,
                      items: categories.map((category) {
                        return DropdownMenuItem<model.Category>(
                          value: category,
                          child: Text(category.name),
                        );
                      }).toList(),
                      onChanged: (newCategory) {
                        setState(() {
                          selectedCategory = newCategory;
                        });
                      },
                      decoration: InputDecoration(labelText: "Category"),
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
                    final name = nameController.text;
                    final description = descriptionController.text;
                    final price = double.tryParse(priceController.text) ?? 0.0;

                    if (name.isNotEmpty && selectedCategory != null) {
                      _updateProduct(product.copyWith(
                        name: name,
                        description: description,
                        price: price,
                        categoryId: selectedCategory!.id!,
                      ));
                      Navigator.of(context).pop();
                    }
                  },
                  child: Text("Save"),
                ),
              ],
            );
          },
        );
      },
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
                    "Description: ${product.description.isEmpty ? '--' : product.description}"),
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
                  onPressed: () => _showEditProductDialog(product),
                ),
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () => _deleteProduct(product.id!),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddProductDialog,
        child: Icon(Icons.add),
      ),
    );
  }
}
