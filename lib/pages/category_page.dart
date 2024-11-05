import 'package:flutter/material.dart';
import 'dart:async';
import '../services/database_service.dart';
import '../models/category.dart';

class CategoryPage extends StatefulWidget {
  @override
  _CategoryPageState createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  final DatabaseService dbService = DatabaseService();
  List<Category> categories = [];
  TextEditingController searchController = TextEditingController();
  Timer? _debounce;
  String searchField = 'name';
  String orderBy = 'name';
  bool descending = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadCategories();
    searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _loadCategories();
    });
  }

  Future<void> _loadCategories() async {
    setState(() => isLoading = true);
    try {
      if (searchController.text.isEmpty) {
        categories = await dbService.fetchAllCategories(
          orderBy: orderBy,
          descending: descending,
        );
      } else {
        categories = await dbService.searchCategories(
          searchText: searchController.text,
          searchField: searchField,
          orderBy: orderBy,
          descending: descending,
        );
      }
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _addCategory(String name, String description) async {
    await dbService
        .insertCategory(Category(name: name, description: description));
    _loadCategories();
  }

  void _updateCategory(Category category) async {
    await dbService.updateCategory(category);
    _loadCategories();
  }

  void _deleteCategory(int id) async {
    await dbService.deleteCategory(id);
    _loadCategories();
  }

  void _showAddCategoryDialog() {
    final nameController = TextEditingController();
    final descController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Category'),
        content: Column(
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
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                _addCategory(nameController.text, descController.text);
                Navigator.of(context).pop();
              }
            },
            child: Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showEditCategoryDialog(Category category) {
    final nameController = TextEditingController(text: category.name);
    final descController = TextEditingController(text: category.description);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Category'),
        content: Column(
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
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                _updateCategory(
                  category.copyWith(
                    name: nameController.text,
                    description: descController.text,
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

  void _showDeleteConfirmation(Category category) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Category'),
        content: Text('Are you sure you want to delete "${category.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.red,
            ),
            onPressed: () {
              _deleteCategory(category.id!);
              Navigator.of(context).pop();
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
      appBar: AppBar(
        title: Text('Categories'),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(80),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: 'Search categories...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                ),
                PopupMenuButton<String>(
                  icon: Icon(Icons.filter_list),
                  onSelected: (value) {
                    setState(() {
                      searchField = value;
                      _loadCategories();
                    });
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(value: 'name', child: Text('Search in Name')),
                    PopupMenuItem(
                        value: 'description',
                        child: Text('Search in Description')),
                  ],
                ),
                PopupMenuButton<String>(
                  icon: Icon(Icons.sort),
                  onSelected: (value) {
                    setState(() {
                      if (orderBy == value) {
                        descending = !descending;
                      } else {
                        orderBy = value;
                        descending = false;
                      }
                      _loadCategories();
                    });
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(value: 'name', child: Text('Sort by Name')),
                    PopupMenuItem(value: 'id', child: Text('Sort by ID')),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : categories.isEmpty
              ? Center(
                  child: Text(
                    searchController.text.isEmpty
                        ? 'No categories found'
                        : 'No matching categories',
                    style: TextStyle(fontSize: 16),
                  ),
                )
              : ListView.builder(
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    return ListTile(
                      title: Text("${category.id}. ${category.name}"),
                      subtitle: Text(category.description),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () => _showEditCategoryDialog(category),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () => _showDeleteConfirmation(category),
                          ),
                        ],
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddCategoryDialog,
        child: Icon(Icons.add),
      ),
    );
  }
}
