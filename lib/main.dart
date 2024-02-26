// ignore_for_file: avoid_print
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
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
  SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft])
      .then((_) {
    runApp(const MyMoneyManagerApp());
  });
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
    void exitApp() {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Confirm Exit'),
            content: const Text('Are you sure you want to Exit !'),
            actions: <Widget>[
              TextButton(
                child: const Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                onPressed: () {
                  exit(0);
                },
                child: const Text('Exit'),
              ),
            ],
          );
        },
      );
    }

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        exitApp();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Money Manager'),
          centerTitle: true,
          backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
          actions: [
            IconButton(
              icon: Icon(
                ThemeProvider.themeOf(context).id == 'light_theme'
                    ? Icons.brightness_4_outlined
                    : Icons.brightness_medium_outlined,
              ),
              onPressed: () {
                ThemeProvider.controllerOf(context).nextTheme();
              },
            ),
          ],
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              color: Colors.transparent,
              height: 250,
              child: Lottie.asset("images/money2.json"),
            ),
            const SizedBox(
              height: 20,
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SizedBox(
                    height: 70,
                    width: 250,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const AddExpensePage()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        foregroundColor: Colors.white,
                        shadowColor: Colors.blueAccent,
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
                        style: TextStyle(
                            fontSize: 17, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
