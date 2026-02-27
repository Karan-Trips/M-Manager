import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:m_manager/firebase_store/expense_store.dart';

final LocalAuthentication _localAuthService = LocalAuthentication();

Future<void> checkAndAuthenticateBiometrics(BuildContext context) async {
  try {
    List<BiometricType> availableBiometrics =
        await _localAuthService.getAvailableBiometrics();

    if (availableBiometrics.isEmpty) {
      debugPrint(
          '[Biometrics] ❌ No biometric methods available on this device.');
      if (!context.mounted) return;
      _showBiometricInfoDialog(
          context, "No biometric methods are available on this device.");
      return;
    }
    final readableTypes = availableBiometrics.map((type) {
      switch (type) {
        case BiometricType.face:
          return 'Face Recognition';
        case BiometricType.fingerprint:
          return 'Fingerprint';
        case BiometricType.iris:
          return 'Iris Scanner';
        default:
          return 'Unknown';
      }
    }).toList();

    debugPrint('[Biometrics] ✅ Available: ${readableTypes.join(', ')}');
    if (!context.mounted) return;
    _showBiometricInfoDialog(
        context, "Available biometrics:\n${readableTypes.join('\n')}");

    final isAuthenticated = await _authenticateWithBiometrics();
    if (isAuthenticated) {
      debugPrint('[Biometrics] ✅ Authentication successful.');
      expenseStore.isPasswordVisible = !expenseStore.isPasswordVisible;
    } else {
      debugPrint('[Biometrics] ❌ Authentication failed or cancelled.');
    }
  } catch (e) {
    debugPrint('[Biometrics] ⚠️ Error during biometric check: $e');
    if (!context.mounted) return;
    _showBiometricInfoDialog(context, "Error checking biometrics: $e");
  }
}

Future<bool> _authenticateWithBiometrics() async {
  try {
    return await _localAuthService.authenticate(
      localizedReason: 'Authenticate to access secure data',
      options: const AuthenticationOptions(
        stickyAuth: true,
        biometricOnly: false,
        useErrorDialogs: true,
      ),
    );
  } on PlatformException catch (e) {
    debugPrint('[Biometrics] PlatformException: ${e.code}');
    return false;
  } catch (e) {
    debugPrint('[Biometrics] Unknown error: $e');
    return false;
  }
}

void _showBiometricInfoDialog(BuildContext context, String message) {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Biometric Info'),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('OK'),
        )
      ],
    ),
  );
}
