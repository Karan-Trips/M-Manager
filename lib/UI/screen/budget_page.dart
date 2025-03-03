import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:try1/UI/cubits_app/cubits_app.dart';

class SetBudgetPage extends StatefulWidget {
  const SetBudgetPage({super.key});

  @override
  State<SetBudgetPage> createState() => _SetBudgetPageState();
}

class _SetBudgetPageState extends State<SetBudgetPage> {
  final TextEditingController _budgetController = TextEditingController();
  late BudgetCubit _budgetCubit;

  @override
  void initState() {
    super.initState();
    _budgetCubit = BudgetCubit();
    _budgetCubit.fetchBudgets();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => _budgetCubit,
      child: Scaffold(
        appBar: AppBar(title: Text("Set Budget for Categories")),
        body: BlocBuilder<BudgetCubit, Map<String, double>>(
          builder: (context, budgets) {
            final categories = [
              "Groceries",
              "Fast-Food",
              "Ghumne",
              "Food",
              "Medicine",
              "Office",
              "EMI"
            ];

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: categories.length,
                      itemBuilder: (context, index) {
                        final category = categories[index];
                        return Card(
                          margin: EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            title:
                                Text(category, style: TextStyle(fontSize: 18)),
                            subtitle: Text(
                              "Budget: ₹${budgets[category]?.toStringAsFixed(2) ?? 'Not Set'}",
                              style:
                                  TextStyle(fontSize: 14, color: Colors.grey),
                            ),
                            trailing: IconButton(
                              icon: Icon(Icons.edit, color: Colors.blue),
                              onPressed: () {
                                _budgetController.text =
                                    budgets[category]?.toString() ?? "";
                                _showBudgetDialog(
                                    context, _budgetCubit, category);
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _showBudgetDialog(
      BuildContext context, BudgetCubit cubit, String category) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Set Budget for $category"),
        content: TextField(
          controller: _budgetController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(hintText: "Enter budget amount"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              final amount = double.tryParse(_budgetController.text) ?? 0;
              if (amount > 0) {
                cubit.setBudget(category, amount);
              }
              Navigator.pop(context);
            },
            child: Text("Save"),
          ),
        ],
      ),
    );
  }
}
