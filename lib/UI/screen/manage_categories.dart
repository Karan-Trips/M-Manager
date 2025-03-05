import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:try1/UI/cubits_app/cubits_app.dart';
import 'package:try1/UI/cubits_app/cubits_state.dart';

class ManageCategoriesPage extends StatefulWidget {
  const ManageCategoriesPage({super.key});

  @override
  State<StatefulWidget> createState() => _ManageCategoriesPageState();
}

class _ManageCategoriesPageState extends State<ManageCategoriesPage> {
  final TextEditingController _categoryController = TextEditingController();

  void _addCategory() {
    String newCategory = _categoryController.text.trim();
    if (newCategory.isNotEmpty) {
      context.read<AddExpenseCubit>().addCategory(newCategory);
      _categoryController.clear();
    }
  }

  void _editCategory(int index, String oldCategory) {
    _categoryController.text = oldCategory;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Edit Category"),
        content: TextField(controller: _categoryController),
        actions: [
          TextButton(
            onPressed: () {
              context.read<AddExpenseCubit>().removeCategory(oldCategory);
              context
                  .read<AddExpenseCubit>()
                  .addCategory(_categoryController.text.trim());
              Navigator.pop(context);
            },
            child: Text("Save"),
          ),
        ],
      ),
    );
  }

  void _deleteCategory(String category) {
    context.read<AddExpenseCubit>().removeCategory(category);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Manage Categories")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _categoryController,
              decoration: InputDecoration(
                labelText: "Category Name",
                suffixIcon: IconButton(
                  icon: Icon(Icons.add),
                  onPressed: _addCategory,
                ),
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: BlocBuilder<AddExpenseCubit, AddExpenseState>(
                builder: (context, state) {
                  var categories = context.watch<AddExpenseCubit>().categories;
                  return ListView.builder(
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      return Card(
                        child: ListTile(
                          title: Text(categories[index]),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit),
                                onPressed: () =>
                                    _editCategory(index, categories[index]),
                              ),
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () =>
                                    _deleteCategory(categories[index]),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
