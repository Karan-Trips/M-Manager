// ignore_for_file: avoid_print, deprecated_member_use

import 'dart:ui';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart' hide Card;
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:m_manager/ui/cubits_app/cubits_app.dart';
import 'package:m_manager/generated/l10n.dart';
import 'package:m_manager/widgets_screen/internet_connectivity/internet_connectivity.dart';
import 'package:m_manager/widgets_screen/no_internetpage.dart';
import 'package:m_manager/app_db.dart';
import 'package:m_manager/auth/login_screen.dart';
import 'package:m_manager/fcm/notification.dart';
import 'package:m_manager/firebase_options.dart';
import 'package:m_manager/firebase_store/expense_store.dart';
import 'package:m_manager/locator.dart';
import 'package:m_manager/ui/screen/home_page.dart';

import 'package:theme_provider/theme_provider.dart';
import 'package:m_manager/ui/welcome_screen/intro_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Get.put(InternetController());
  await Hive.initFlutter();
  await Hive.openBox<String>('authBox');

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  await setuplocator();
  await locator.isReady<AppDb>();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  PushNotificationsManager().init();
  FlutterError.onError = (errorDetails) {
    FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  final user = FirebaseAuth.instance.currentUser;
  print("!!!!!!!!!!!!!!!!!! YOUR UID: ${user?.uid}");
  await appDb.storeUserId(user?.uid ?? '');

  final expenseStore = ExpenseStore();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => AddExpenseCubit()),
        BlocProvider(create: (context) => BudgetCubit()),
      ],
      child: MyMoneyManagerApp(expenseStore: expenseStore, user: user),
    ),
  );
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
      child: ScreenUtilInit(
        builder: (context, child) {
          final Brightness brightness =
              MediaQuery.of(context).platformBrightness;
          final isDarkMode = brightness == Brightness.dark;

          return GetMaterialApp(
            smartManagement: SmartManagement.full,
            supportedLocales: const [
              Locale('en'),
              Locale('hi'),
            ],
            localizationsDelegates: const [
              S.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            debugShowCheckedModeBanner: false,
            theme: ThemeData(useMaterial3: true),
            home: GetBuilder<InternetController>(
              builder: (internetController) {
                if (internetController.isConnected.value) {
                  return user != null
                      ? const MoneyManagerHomePage()
                      : (appDb.isFirstTime ? const IntroPage() : LoginPage());
                } else {
                  return NoInternetPage();
                }
              },
            ),
          );
        },
      ),
    );
  }
}
