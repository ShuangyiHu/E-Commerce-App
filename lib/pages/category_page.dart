import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../models/category.dart';

class CategoryPage extends StatefulWidget {
  @override
  _CategoryPageState createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  final DatabaseService dbService = DatabaseService();
  List<Category> categories = [];

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    categories = await dbService.getCategories();
    setState(() {});
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
    String name = '';
    String description = '';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Category'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(labelText: 'Name'),
              onChanged: (value) => name = value,
            ),
            TextField(
              decoration: InputDecoration(labelText: 'Description'),
              onChanged: (value) => description = value,
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
              _addCategory(name, description);
              Navigator.of(context).pop();
            },
            child: Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Categories")),
      body: ListView.builder(
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          return ListTile(
            title: Text(category.name),
            subtitle: Text(category.description),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () {
                    // Handle edit category here
                  },
                ),
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    _deleteCategory(category.id!);
                  },
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
