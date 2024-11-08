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
  bool descending = false;
  String searchText = "";
  bool isLoading = false;
  bool hasMoreData = true;
  int currentPage = 0;
  final int pageSize = 7;

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
    _resetPaginationAndLoad();
  }

  void _resetPaginationAndLoad() {
    products.clear();
    currentPage = 0;
    hasMoreData = true;
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    if (isLoading || !hasMoreData) return;

    setState(() {
      isLoading = true;
    });

    final productMaps = await dbService.getPaginatedProductsWithCategoryNames(
      categoryId: selectedCategory?.id,
      searchText: searchText,
      orderBy: orderBy,
      descending: descending,
      limit: pageSize,
      offset: currentPage * pageSize,
    );

    setState(() {
      if (productMaps.length < pageSize) {
        hasMoreData = false;
      }

      products.addAll(productMaps.map((map) {
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
      }).toList());

      currentPage++;
      isLoading = false;
    });
  }

  Future<void> _loadCategories() async {
    categories = await dbService.fetchAllCategories();
    setState(() {});
  }

  void _onCategoryFilterChanged(model.Category? category) {
    setState(() {
      selectedCategory = category;
      _resetPaginationAndLoad();
    });
  }

  void _onSortOptionChanged(String value) {
    setState(() {
      if (orderBy == value) {
        descending = !descending;
      } else {
        orderBy = value;
        descending = false;
      }
      _resetPaginationAndLoad();
    });
  }

  void _showAddProductDialog() {
    TextEditingController nameController = TextEditingController();
    TextEditingController descriptionController = TextEditingController();
    TextEditingController priceController = TextEditingController();
    model.Category? selectedCategoryForProduct;

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
                      value: selectedCategoryForProduct,
                      items: categories.map((category) {
                        return DropdownMenuItem<model.Category>(
                          value: category,
                          child: Text(category.name),
                        );
                      }).toList(),
                      onChanged: (newCategory) {
                        setState(() {
                          selectedCategoryForProduct = newCategory;
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
                  onPressed: () async {
                    if (nameController.text.isNotEmpty &&
                        priceController.text.isNotEmpty &&
                        selectedCategoryForProduct != null) {
                      await dbService.insertProduct(Product(
                        name: nameController.text,
                        description: descriptionController.text,
                        price: double.parse(priceController.text),
                        categoryId: selectedCategoryForProduct!.id!,
                        imageUrl: '',
                        stockQuantity: 10,
                        categoryName: selectedCategoryForProduct!.name,
                      ));
                      _resetPaginationAndLoad();
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
            child: ListView.builder(
              itemCount: products.length + (hasMoreData ? 1 : 0),
              itemBuilder: (context, index) {
                if (index < products.length) {
                  final product = products[index];
                  return ListTile(
                    title: Text("ID: ${product.id}. ${product.name}"),
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
                  );
                } else if (isLoading) {
                  return Center(child: CircularProgressIndicator());
                } else {
                  return TextButton(
                    onPressed: _loadProducts,
                    child: Text("Load More"),
                  );
                }
              },
            ),
          ),
        ],
      ),
      floatingActionButton: Stack(
        children: [
          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton(
              onPressed: () => _resetPaginationAndLoad(),
              child: Icon(Icons.refresh),
            ),
          ),
          Positioned(
            bottom: 80,
            right: 16,
            child: FloatingActionButton(
              onPressed: _showAddProductDialog,
              child: Icon(Icons.add),
            ),
          ),
        ],
      ),
    );
  }
}
