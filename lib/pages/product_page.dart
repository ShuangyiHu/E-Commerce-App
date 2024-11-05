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
  TextEditingController searchController = TextEditingController();
  String orderBy = 'name';
  bool descending = false; // Default to ascending order
  String searchText = "";

  @override
  void initState() {
    super.initState();
    _loadProducts();
    _loadCategories();
    searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    searchController.removeListener(_onSearchChanged);
    searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    searchText = searchController.text;
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    final productMaps = await dbService.getProductsWithCategoryNames(
      categoryId: selectedCategory?.id,
      searchText: searchText,
      orderBy: orderBy,
      descending: descending,
    );
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

  void _onCategoryFilterChanged(model.Category? category) {
    setState(() {
      selectedCategory = category;
      _loadProducts();
    });
  }

  void _onSortOptionChanged(String value) {
    setState(() {
      if (orderBy == value) {
        // If the same sort option is selected, toggle ascending/descending
        descending = !descending;
      } else {
        // If a new sort option is selected, set it to ascending by default
        orderBy = value;
        descending = false;
      }
      _loadProducts();
    });
  }

  void addProduct(String name, String description, double price, int categoryId,
      String categoryName) async {
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

  void updateProduct(Product product) async {
    await dbService.updateProduct(product);
    _loadProducts();
  }

  void deleteProduct(int id) async {
    bool confirmed = await showDeleteConfirmationDialog();
    if (confirmed) {
      await dbService.deleteProduct(id);
      _loadProducts();
    }
  }

  Future<bool> showDeleteConfirmationDialog() async {
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

  void showAddProductDialog() {
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
                      addProduct(name, description, price,
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

  void showEditProductDialog(Product product) {
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
                      updateProduct(product.copyWith(
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
      appBar: AppBar(
        title: Text("Products"),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: "Search by name",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButton<model.Category?>(
                    value: selectedCategory,
                    hint: Text("All Categories"),
                    isExpanded: true,
                    onChanged: _onCategoryFilterChanged,
                    items: [
                      DropdownMenuItem(
                        value: null,
                        child: Text("All Categories"),
                      ),
                      ...categories.map((category) {
                        return DropdownMenuItem(
                          value: category,
                          child: Text(category.name),
                        );
                      }).toList(),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  icon: Icon(Icons.sort),
                  onSelected: _onSortOptionChanged,
                  itemBuilder: (context) => [
                    PopupMenuItem(value: 'name', child: Text('Sort by Name')),
                    PopupMenuItem(value: 'price', child: Text('Sort by Price')),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: products.isEmpty
                ? Center(child: Text("No products found"))
                : ListView.builder(
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return ListTile(
                        title: Text("ID: ${product.id}. ${product.name}"),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                "Description: ${product.description.isEmpty ? '--' : product.description}"),
                            Text(
                                "Price: \$${product.price.toStringAsFixed(2)}"),
                            Text(
                                "Category: ${product.categoryId} (${product.categoryName})"),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit),
                              onPressed: () => showEditProductDialog(product),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () => deleteProduct(product.id!),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: showAddProductDialog,
        child: Icon(Icons.add),
      ),
    );
  }
}
