import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracker1/data/expense_data.dart';
import 'package:expense_tracker1/models/expense_item.dart';
import 'package:expense_tracker1/components/expense_tile.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final newExpenseNameController = TextEditingController();
  final newExpenseAmountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      Provider.of<ExpenseData>(context, listen: false).prepareData();
    });
  }

  void addNewExpense() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add New Expense'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: newExpenseNameController,
              decoration: InputDecoration(
                labelText: 'Expense Name',
              ),
            ),

            TextField(
              controller: newExpenseAmountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Amount',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: cancel,
            child: Text('Cancel'),
          ),

          TextButton(
            onPressed: save,
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  void deleteExpense(ExpenseItem expense) {
    Provider.of<ExpenseData>(context, listen: false).deleteExpense(expense);
  }

  void save() {
    // Check if both name and amount are not empty
    if (newExpenseAmountController.text.isNotEmpty &&
        newExpenseNameController.text.isNotEmpty) {
      // Create a new ExpenseItem object
      ExpenseItem newExpense = ExpenseItem(
        name: newExpenseNameController.text,
        amount: newExpenseAmountController.text,
        dateTime: DateTime.now(),
      );
      // Add the new expense using the provider
      Provider.of<ExpenseData>(context, listen: false).addNewExpense(newExpense);
    }

    // Close the dialog and clear text fields
    Navigator.pop(context);
    clear();
  }

  void cancel() {

    Navigator.pop(context);
    clear();
  }

  void clear() {
    // Clear both text fields
    newExpenseNameController.clear();
    newExpenseAmountController.clear();
  }

  String calculateTotalExpenditure(List<ExpenseItem> expenses) {
    double total = 0;
    expenses.forEach((expense) {
      total += double.parse(expense.amount);
    });
    return '₹${total.toStringAsFixed(2)}';
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ExpenseData>(
      builder: (context, value, child) => Scaffold(
        appBar: AppBar(
          title: Text('Cash Flow Manager'),
        ),
        backgroundColor: Colors.grey[300],
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: value.overallExpenseList.length,
                itemBuilder: (context, index) {
                  ExpenseItem expense = value.overallExpenseList[index];
                  return ExpenseTile(
                    name: expense.name,
                    amount: expense.amount,
                    dateTime: expense.dateTime,
                    deleteTapped: (p0) => deleteExpense(expense),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.yellow,
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: EdgeInsets.all(8.0),
                child: Text(
                  'Total: ${calculateTotalExpenditure(value.overallExpenseList)}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: addNewExpense,
          backgroundColor: Colors.green,
          child: Icon(Icons.add),
        ),
      ),
    );
  }
}
