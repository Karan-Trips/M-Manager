// ignore_for_file: avoid_print
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:try1/firebase_options.dart';
import 'package:try1/screen/add_trans.dart';
import 'package:try1/screen/histroy.dart';
import 'package:theme_provider/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
  } catch (e) {
    print('Error initializing Firebase: $e');
  }
  runApp(const MyMoneyManagerApp());
}

class MyMoneyManagerApp extends StatelessWidget {
  const MyMoneyManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ThemeProvider(
      themes: [
        AppTheme.light(),
        AppTheme.dark(),
      ],
      child: Builder(
        builder: (context) => MaterialApp(
          debugShowCheckedModeBanner: false,
          home: const MoneyManagerHomePage(),
          theme: ThemeProvider.themeOf(context).data,
        ),
      ),
    );
  }
}

class MoneyManagerHomePage extends StatelessWidget {
  const MoneyManagerHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Money Manager'),
        centerTitle: true,
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        actions: [
          IconButton(
            icon: Icon(
              ThemeProvider.themeOf(context).id == 'light_theme'
                  ? Icons.light_mode
                  : Icons.dark_mode,
            ),
            onPressed: () {
              ThemeProvider.controllerOf(context).nextTheme();
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              height: 70,
              width: 250,
              child: ElevatedButton(
                onPressed: () {
                  // Navigate to AddTransactionPage
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const AddExpensePage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent, // Background color
                  foregroundColor: Colors.white, // Text color
                  shadowColor: Colors.blueAccent, // Shadow color
                ),
                child: const Text(
                  'Add Transaction',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(
              height: 50,
            ),

            SizedBox(
              height: 70,
              width: 250,
              child: ElevatedButton(
                onPressed: () {
                  // Navigate to ExpenseSummaryPage
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ExpenseSummaryPage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                ),
                child: const Text(
                  'Expense Summary',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            // Add more buttons for other features
          ],
        ),
      ),
    );
  }
}
