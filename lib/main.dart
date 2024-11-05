// ignore_for_file: avoid_print, deprecated_member_use

import 'dart:io';
import 'dart:ui';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:local_auth/local_auth.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart' hide Card;
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:try1/app_db.dart';
import 'package:try1/auth/login_screen.dart';
import 'package:try1/fcm/notification.dart';
import 'package:try1/firebase_options.dart';
import 'package:try1/firebase_store/expense_store.dart';
import 'package:try1/locator.dart';
import 'package:try1/screen/add_trans.dart';

import 'package:try1/screen/histroy.dart';
import 'package:theme_provider/theme_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  await Hive.openBox<String>('authBox');
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await setuplocator();
  await locator.isReady<AppDb>();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((value) {
    PushNotificationsManager().init();
    FlutterError.onError = (errorDetails) {
      FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
    };

    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };

    final user = FirebaseAuth.instance.currentUser;
    print("!!!!!!!!!!!!!!!!!!YOUR UID: ${user?.uid}");
    appDb.storeUserId(user?.uid ?? '');

    final expenseStore = ExpenseStore();

    runApp(MyMoneyManagerApp(expenseStore: expenseStore, user: user));
  });
}

class MyMoneyManagerApp extends StatelessWidget {
  final ExpenseStore? expenseStore;
  final User? user;
  const MyMoneyManagerApp({super.key, this.expenseStore, this.user});

  @override
  Widget build(BuildContext context) {
    return ThemeProvider(
      themes: [
        AppTheme.light(),
        AppTheme.dark(),
      ],
      child: Builder(builder: (context) {
        final Brightness brightness = MediaQuery.of(context).platformBrightness;
        final isDarkMode = brightness == Brightness.dark;
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          home: user != null ? const MoneyManagerHomePage() : const LoginPage(),
          theme: isDarkMode ? AppTheme.dark().data : AppTheme.light().data,
        );
      }),
    );
  }
}

class MoneyManagerHomePage extends StatefulWidget {
  const MoneyManagerHomePage({super.key});

  @override
  State<MoneyManagerHomePage> createState() => _MoneyManagerHomePageState();
}

class _MoneyManagerHomePageState extends State<MoneyManagerHomePage> {
  final LocalAuthentication _localAuthService = LocalAuthentication();
  bool isAuthenticated = false;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    var userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId != null) {
      appDb.storeUserId(userId);
      expenseStore.fetchExpenses();
      expenseStore.fetchIncome();
    } else {
      print('User is not logged in');
    }
  }

  @override
  Widget build(BuildContext context) {
    void exitApp() {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Confirm Exit'),
            content: const Text('Are you sure you want to exit?'),
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

    return WillPopScope(
      onWillPop: () async {
        exitApp();
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              FirebaseAuth.instance.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
              );
            },
          ),
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
        body: Observer(builder: (context) {
          final brightness = MediaQuery.of(context).platformBrightness;
          final isDarkMode =
              brightness == Brightness.dark; // Check for dark mode

          return Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Container(
                height: 200,
                width: 360,
                decoration: BoxDecoration(
                  gradient: isDarkMode
                      ? const LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            Color(0xff3a3a3a),
                            Color(0xff555555),
                          ],
                        )
                      : const LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            Color.fromARGB(255, 243, 183, 93),
                            Color.fromARGB(255, 245, 130, 29),
                            Color.fromARGB(255, 243, 183, 93),
                          ],
                        ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color.fromRGBO(47, 125, 121, 0.3),
                      offset: Offset(1, 2),
                      blurRadius: 9,
                      spreadRadius: 5,
                    ),
                  ],
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total Balance',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              _getAvailableBiometrics();
                            },
                            icon: expenseStore.isPasswordVisible
                                ? const Icon(Icons.visibility)
                                : const Icon(Icons.visibility_off),
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 7),
                    Padding(
                      padding: const EdgeInsets.only(left: 15),
                      child: Row(
                        children: [
                          Text(
                            '₹ ${expenseStore.isPasswordVisible ? expenseStore.totalExpenses : 'XX.XX'}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 25,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 25),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 13,
                                backgroundColor: Colors.green,
                                child: Icon(
                                  Icons.arrow_upward,
                                  color: Colors.black,
                                  size: 19,
                                ),
                              ),
                              SizedBox(width: 7),
                              Text(
                                'Income',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16,
                                  color: Color.fromARGB(255, 216, 216, 216),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 13,
                                backgroundColor: Colors.red,
                                child: Icon(
                                  Icons.arrow_downward,
                                  color: Colors.black,
                                  size: 19,
                                ),
                              ),
                              SizedBox(width: 7),
                              Text(
                                'Expenses',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16,
                                  color: Color.fromARGB(255, 216, 216, 216),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '₹${expenseStore.isPasswordVisible ? expenseStore.totalIncome : 'XX.XX'}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 17,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            "₹${expenseStore.isPasswordVisible ? expenseStore.totalExpenses : "XX.XX"}",
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 17,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const AddExpensePage()),
                        );
                      },
                      child: Container(
                        width: 250,
                        padding: const EdgeInsets.symmetric(
                            vertical: 15, horizontal: 35),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(40)),
                            boxShadow: <BoxShadow>[
                              BoxShadow(
                                  color: Colors.grey.shade200,
                                  offset: const Offset(2, 4),
                                  blurRadius: 5,
                                  spreadRadius: 2)
                            ],
                            gradient: const LinearGradient(
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                                colors: [
                                  Color(0xfffbb448),
                                  Color(0xfff7892b)
                                ])),
                        height: 70,
                        child: const Text(
                          'Add Transaction',
                          style: TextStyle(fontSize: 20, color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(height: 50),
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const ExpenseSummaryPage()),
                        );
                      },
                      child: Container(
                        width: 250,
                        padding: const EdgeInsets.symmetric(
                            vertical: 15, horizontal: 35),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(40)),
                            boxShadow: <BoxShadow>[
                              BoxShadow(
                                  color: Colors.grey.shade200,
                                  offset: const Offset(2, 4),
                                  blurRadius: 5,
                                  spreadRadius: 2)
                            ],
                            gradient: const LinearGradient(
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                                colors: [
                                  Color(0xfffbb448),
                                  Color(0xfff7892b)
                                ])),
                        height: 70,
                        child: const Text(
                          'Expense Summary',
                          style: TextStyle(fontSize: 20, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Future<void> _getAvailableBiometrics() async {
    List<BiometricType> availableBiometrics =
        await _localAuthService.getAvailableBiometrics();
    print('List of available biometrics: $availableBiometrics');
    if (availableBiometrics.isNotEmpty) {
      await _authenticate();
    } else {
      print("No biometric methods available.");
    }

    if (!mounted) {
      return;
    }
  }

  Future<void> _authenticate() async {
    try {
      isAuthenticated = await _localAuthService.authenticate(
        localizedReason: 'Authenticate to access your account',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
      if (isAuthenticated) {
        expenseStore.isPasswordVisible = !expenseStore.isPasswordVisible;
      }
    } on PlatformException catch (e) {
      print("----------$e!!!!!!!!!!!!!");
    }
  }
}
