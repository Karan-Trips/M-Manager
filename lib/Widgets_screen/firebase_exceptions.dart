import 'package:firebase_auth/firebase_auth.dart';

import '../generated/l10n.dart';

enum AuthStatus {
  successful,
  wrongPassword,
  emailAlreadyExists,
  invalidEmail,
  weakPassword,
  unknown,
  pending,
  initial,
  emptyEmail,
}

class AuthExceptionHandler {
  static AuthStatus handleAuthException(FirebaseAuthException e) {
    AuthStatus status;
    switch (e.code) {
      case "invalid-email":
        status = AuthStatus.invalidEmail;
        break;
      case "wrong-password":
        status = AuthStatus.wrongPassword;
        break;
      case "weak-password":
        status = AuthStatus.weakPassword;
        break;
      case "email-already-in-use":
        status = AuthStatus.emailAlreadyExists;
        break;
      default:
        status = AuthStatus.unknown;
    }
    return status;
  }

  static String generateErrorMessage(AuthStatus error) {
    String errorMessage;
    switch (error) {
      case AuthStatus.invalidEmail:
        errorMessage = S.current.yourEmailAddressAppearsToBeMalformed;
        break;
      case AuthStatus.weakPassword:
        errorMessage = S.current.yourPasswordShouldBeAtLeast6Characters;
        break;
      case AuthStatus.wrongPassword:
        errorMessage = S.current.yourEmailOrPasswordIsWrong;
        break;
      case AuthStatus.emailAlreadyExists:
        errorMessage = S.current.theEmailAddressIsAlreadyInUseByAnotherAccount;
        break;
      default:
        errorMessage = S.current.anErrorOccuredPleaseTryAgainLater;
    }
    return errorMessage;
  }
}
