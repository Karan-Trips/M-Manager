import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:try1/widgets_screen/internet_connectivity/internet_connectivity.dart';

import '../generated/l10n.dart';

class NoInternetPage extends StatelessWidget {
  const NoInternetPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.wifi_off, size: 100, color: Colors.grey),
            SizedBox(height: 20),
            Text(
              S.of(context).noInternetConnection,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(S.of(context).pleaseCheckYourInternetAndTryAgain),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
