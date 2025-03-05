// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(_current != null,
        'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.');
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(instance != null,
        'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?');
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `Are you sure you want to exit?`
  String get areYouSureYouWantToExit {
    return Intl.message(
      'Are you sure you want to exit?',
      name: 'areYouSureYouWantToExit',
      desc: '',
      args: [],
    );
  }

  /// `Add Expense`
  String get addExpense {
    return Intl.message(
      'Add Expense',
      name: 'addExpense',
      desc: '',
      args: [],
    );
  }

  /// `Enter your Amount`
  String get enterYourAmount {
    return Intl.message(
      'Enter your Amount',
      name: 'enterYourAmount',
      desc: '',
      args: [],
    );
  }

  /// `Save Expense`
  String get saveExpense {
    return Intl.message(
      'Save Expense',
      name: 'saveExpense',
      desc: '',
      args: [],
    );
  }

  /// `Add Income`
  String get addIncome {
    return Intl.message(
      'Add Income',
      name: 'addIncome',
      desc: '',
      args: [],
    );
  }

  /// `Category:`
  String get category {
    return Intl.message(
      'Category:',
      name: 'category',
      desc: '',
      args: [],
    );
  }

  /// `Amount:`
  String get amount {
    return Intl.message(
      'Amount:',
      name: 'amount',
      desc: '',
      args: [],
    );
  }

  /// `Income:`
  String get income {
    return Intl.message(
      'Income:',
      name: 'income',
      desc: '',
      args: [],
    );
  }

  /// `Enter the Income`
  String get enterTheIncome {
    return Intl.message(
      'Enter the Income',
      name: 'enterTheIncome',
      desc: '',
      args: [],
    );
  }

  /// `Under Development`
  String get underDevelopment {
    return Intl.message(
      'Under Development',
      name: 'underDevelopment',
      desc: '',
      args: [],
    );
  }

  /// `Close`
  String get close {
    return Intl.message(
      'Close',
      name: 'close',
      desc: '',
      args: [],
    );
  }

  /// `Bar-Chart`
  String get barchart {
    return Intl.message(
      'Bar-Chart',
      name: 'barchart',
      desc: '',
      args: [],
    );
  }

  /// `Expense Summary`
  String get expenseSummary {
    return Intl.message(
      'Expense Summary',
      name: 'expenseSummary',
      desc: '',
      args: [],
    );
  }

  /// `History`
  String get history {
    return Intl.message(
      'History',
      name: 'history',
      desc: '',
      args: [],
    );
  }

  /// `Graph`
  String get graph {
    return Intl.message(
      'Graph',
      name: 'graph',
      desc: '',
      args: [],
    );
  }

  /// `Total Balance is`
  String get totalBalanceIs {
    return Intl.message(
      'Total Balance is',
      name: 'totalBalanceIs',
      desc: '',
      args: [],
    );
  }

  /// `Expenses`
  String get expenses {
    return Intl.message(
      'Expenses',
      name: 'expenses',
      desc: '',
      args: [],
    );
  }

  /// `No expenses found.`
  String get noExpensesFound {
    return Intl.message(
      'No expenses found.',
      name: 'noExpensesFound',
      desc: '',
      args: [],
    );
  }

  /// `Confirm Deletion`
  String get confirmDeletion {
    return Intl.message(
      'Confirm Deletion',
      name: 'confirmDeletion',
      desc: '',
      args: [],
    );
  }

  /// `Cancel`
  String get cancel {
    return Intl.message(
      'Cancel',
      name: 'cancel',
      desc: '',
      args: [],
    );
  }

  /// `Delete`
  String get delete {
    return Intl.message(
      'Delete',
      name: 'delete',
      desc: '',
      args: [],
    );
  }

  /// `Transaction Deleted!`
  String get transactionDeleted {
    return Intl.message(
      'Transaction Deleted!',
      name: 'transactionDeleted',
      desc: '',
      args: [],
    );
  }

  /// `Edit Category`
  String get editCategory {
    return Intl.message(
      'Edit Category',
      name: 'editCategory',
      desc: '',
      args: [],
    );
  }

  /// `Save`
  String get save {
    return Intl.message(
      'Save',
      name: 'save',
      desc: '',
      args: [],
    );
  }

  /// `Category Name`
  String get categoryName {
    return Intl.message(
      'Category Name',
      name: 'categoryName',
      desc: '',
      args: [],
    );
  }

  /// `Manage Categories`
  String get manageCategories {
    return Intl.message(
      'Manage Categories',
      name: 'manageCategories',
      desc: '',
      args: [],
    );
  }

  /// `Expense Receipt`
  String get expenseReceipt {
    return Intl.message(
      'Expense Receipt',
      name: 'expenseReceipt',
      desc: '',
      args: [],
    );
  }

  /// `Failed to get storage directory`
  String get failedToGetStorageDirectory {
    return Intl.message(
      'Failed to get storage directory',
      name: 'failedToGetStorageDirectory',
      desc: '',
      args: [],
    );
  }

  /// `Settings`
  String get settings {
    return Intl.message(
      'Settings',
      name: 'settings',
      desc: '',
      args: [],
    );
  }

  /// `Print Receipt`
  String get printReceipt {
    return Intl.message(
      'Print Receipt',
      name: 'printReceipt',
      desc: '',
      args: [],
    );
  }

  /// `Set Budget`
  String get setBudget {
    return Intl.message(
      'Set Budget',
      name: 'setBudget',
      desc: '',
      args: [],
    );
  }

  /// `Logout`
  String get logout {
    return Intl.message(
      'Logout',
      name: 'logout',
      desc: '',
      args: [],
    );
  }

  /// `Notifications`
  String get notifications {
    return Intl.message(
      'Notifications',
      name: 'notifications',
      desc: '',
      args: [],
    );
  }

  /// `Your email address appears to be malformed.`
  String get yourEmailAddressAppearsToBeMalformed {
    return Intl.message(
      'Your email address appears to be malformed.',
      name: 'yourEmailAddressAppearsToBeMalformed',
      desc: '',
      args: [],
    );
  }

  /// `Your password should be at least 6 characters.`
  String get yourPasswordShouldBeAtLeast6Characters {
    return Intl.message(
      'Your password should be at least 6 characters.',
      name: 'yourPasswordShouldBeAtLeast6Characters',
      desc: '',
      args: [],
    );
  }

  /// `Your email or password is wrong.`
  String get yourEmailOrPasswordIsWrong {
    return Intl.message(
      'Your email or password is wrong.',
      name: 'yourEmailOrPasswordIsWrong',
      desc: '',
      args: [],
    );
  }

  /// `The email address is already in use by another account.`
  String get theEmailAddressIsAlreadyInUseByAnotherAccount {
    return Intl.message(
      'The email address is already in use by another account.',
      name: 'theEmailAddressIsAlreadyInUseByAnotherAccount',
      desc: '',
      args: [],
    );
  }

  /// `An error occured. Please try again later.`
  String get anErrorOccuredPleaseTryAgainLater {
    return Intl.message(
      'An error occured. Please try again later.',
      name: 'anErrorOccuredPleaseTryAgainLater',
      desc: '',
      args: [],
    );
  }

  /// `Camera`
  String get camera {
    return Intl.message(
      'Camera',
      name: 'camera',
      desc: '',
      args: [],
    );
  }

  /// `Gallery`
  String get gallery {
    return Intl.message(
      'Gallery',
      name: 'gallery',
      desc: '',
      args: [],
    );
  }

  /// `No Internet Connection`
  String get noInternetConnection {
    return Intl.message(
      'No Internet Connection',
      name: 'noInternetConnection',
      desc: '',
      args: [],
    );
  }

  /// `Please check your internet and try again.`
  String get pleaseCheckYourInternetAndTryAgain {
    return Intl.message(
      'Please check your internet and try again.',
      name: 'pleaseCheckYourInternetAndTryAgain',
      desc: '',
      args: [],
    );
  }

  /// `Confirm Exit`
  String get confirmExit {
    return Intl.message(
      'Confirm Exit',
      name: 'confirmExit',
      desc: '',
      args: [],
    );
  }

  /// `Exit`
  String get exit {
    return Intl.message(
      'Exit',
      name: 'exit',
      desc: '',
      args: [],
    );
  }

  /// `Money Manager`
  String get moneyManager {
    return Intl.message(
      'Money Manager',
      name: 'moneyManager',
      desc: '',
      args: [],
    );
  }

  /// `Total Balance Left Is`
  String get totalBalanceLeftIs {
    return Intl.message(
      'Total Balance Left Is',
      name: 'totalBalanceLeftIs',
      desc: '',
      args: [],
    );
  }

  /// `Add Transaction`
  String get addTransaction {
    return Intl.message(
      'Add Transaction',
      name: 'addTransaction',
      desc: '',
      args: [],
    );
  }

  /// `Split`
  String get split {
    return Intl.message(
      'Split',
      name: 'split',
      desc: '',
      args: [],
    );
  }

  /// `Copied to Clipboard`
  String get copiedToClipboard {
    return Intl.message(
      'Copied to Clipboard',
      name: 'copiedToClipboard',
      desc: '',
      args: [],
    );
  }

  /// `Flutter OCR`
  String get flutterOcr {
    return Intl.message(
      'Flutter OCR',
      name: 'flutterOcr',
      desc: '',
      args: [],
    );
  }

  /// `Select a Option`
  String get selectAOption {
    return Intl.message(
      'Select a Option',
      name: 'selectAOption',
      desc: '',
      args: [],
    );
  }

  /// `From Gallery`
  String get fromGallery {
    return Intl.message(
      'From Gallery',
      name: 'fromGallery',
      desc: '',
      args: [],
    );
  }

  /// `From Camera`
  String get fromCamera {
    return Intl.message(
      'From Camera',
      name: 'fromCamera',
      desc: '',
      args: [],
    );
  }

  /// `Previously Read`
  String get previouslyRead {
    return Intl.message(
      'Previously Read',
      name: 'previouslyRead',
      desc: '',
      args: [],
    );
  }

  /// `Please enter a valid amount and select friends.`
  String get pleaseEnterAValidAmountAndSelectFriends {
    return Intl.message(
      'Please enter a valid amount and select friends.',
      name: 'pleaseEnterAValidAmountAndSelectFriends',
      desc: '',
      args: [],
    );
  }

  /// `Split Expense`
  String get splitExpense {
    return Intl.message(
      'Split Expense',
      name: 'splitExpense',
      desc: '',
      args: [],
    );
  }

  /// `Enter Total Amount`
  String get enterTotalAmount {
    return Intl.message(
      'Enter Total Amount',
      name: 'enterTotalAmount',
      desc: '',
      args: [],
    );
  }

  /// `Please enter a valid amount`
  String get pleaseEnterAValidAmount {
    return Intl.message(
      'Please enter a valid amount',
      name: 'pleaseEnterAValidAmount',
      desc: '',
      args: [],
    );
  }

  /// `Search Contacts`
  String get searchContacts {
    return Intl.message(
      'Search Contacts',
      name: 'searchContacts',
      desc: '',
      args: [],
    );
  }

  /// `Split & Notify`
  String get splitNotify {
    return Intl.message(
      'Split & Notify',
      name: 'splitNotify',
      desc: '',
      args: [],
    );
  }

  /// `Amount is too large to handle`
  String get amountIsTooLargeToHandle {
    return Intl.message(
      'Amount is too large to handle',
      name: 'amountIsTooLargeToHandle',
      desc: '',
      args: [],
    );
  }

  /// `Please enter a valid income`
  String get pleaseEnterAValidIncome {
    return Intl.message(
      'Please enter a valid income',
      name: 'pleaseEnterAValidIncome',
      desc: '',
      args: [],
    );
  }

  /// `User ID not found.`
  String get userIdNotFound {
    return Intl.message(
      'User ID not found.',
      name: 'userIdNotFound',
      desc: '',
      args: [],
    );
  }

  /// `User document does not exist.`
  String get userDocumentDoesNotExist {
    return Intl.message(
      'User document does not exist.',
      name: 'userDocumentDoesNotExist',
      desc: '',
      args: [],
    );
  }

  /// `Error fetching expenses: $error`
  String get errorFetchingExpensesError {
    return Intl.message(
      'Error fetching expenses: \$error',
      name: 'errorFetchingExpensesError',
      desc: '',
      args: [],
    );
  }

  /// `Error fetching income: $error`
  String get errorFetchingIncomeError {
    return Intl.message(
      'Error fetching income: \$error',
      name: 'errorFetchingIncomeError',
      desc: '',
      args: [],
    );
  }

  /// `Transaction Saved!`
  String get transactionSaved {
    return Intl.message(
      'Transaction Saved!',
      name: 'transactionSaved',
      desc: '',
      args: [],
    );
  }

  /// `Failed to save expense: ${e.toString()}`
  String get failedToSaveExpenseEtostring {
    return Intl.message(
      'Failed to save expense: \${e.toString()}',
      name: 'failedToSaveExpenseEtostring',
      desc: '',
      args: [],
    );
  }

  /// `Invalid input for amount`
  String get invalidInputForAmount {
    return Intl.message(
      'Invalid input for amount',
      name: 'invalidInputForAmount',
      desc: '',
      args: [],
    );
  }

  /// `Expense deleted successfully.`
  String get expenseDeletedSuccessfully {
    return Intl.message(
      'Expense deleted successfully.',
      name: 'expenseDeletedSuccessfully',
      desc: '',
      args: [],
    );
  }

  /// `Expense with the given ID not found.`
  String get expenseWithTheGivenIdNotFound {
    return Intl.message(
      'Expense with the given ID not found.',
      name: 'expenseWithTheGivenIdNotFound',
      desc: '',
      args: [],
    );
  }

  /// `Error deleting expense: $error`
  String get errorDeletingExpenseError {
    return Intl.message(
      'Error deleting expense: \$error',
      name: 'errorDeletingExpenseError',
      desc: '',
      args: [],
    );
  }

  /// `User ID not found. Please sign in again.`
  String get userIdNotFoundPleaseSignInAgain {
    return Intl.message(
      'User ID not found. Please sign in again.',
      name: 'userIdNotFoundPleaseSignInAgain',
      desc: '',
      args: [],
    );
  }

  /// `Income value updated successfully`
  String get incomeValueUpdatedSuccessfully {
    return Intl.message(
      'Income value updated successfully',
      name: 'incomeValueUpdatedSuccessfully',
      desc: '',
      args: [],
    );
  }

  /// `Failed to update income: ${e.toString()}`
  String get failedToUpdateIncomeEtostring {
    return Intl.message(
      'Failed to update income: \${e.toString()}',
      name: 'failedToUpdateIncomeEtostring',
      desc: '',
      args: [],
    );
  }

  /// `Invalid input for income`
  String get invalidInputForIncome {
    return Intl.message(
      'Invalid input for income',
      name: 'invalidInputForIncome',
      desc: '',
      args: [],
    );
  }

  /// `Enter your password`
  String get enterYourPassword {
    return Intl.message(
      'Enter your password',
      name: 'enterYourPassword',
      desc: '',
      args: [],
    );
  }

  /// `Enter your email`
  String get enterYourEmail {
    return Intl.message(
      'Enter your email',
      name: 'enterYourEmail',
      desc: '',
      args: [],
    );
  }

  /// `or`
  String get or {
    return Intl.message(
      'or',
      name: 'or',
      desc: '',
      args: [],
    );
  }

  /// `Manger`
  String get manger {
    return Intl.message(
      'Manger',
      name: 'manger',
      desc: '',
      args: [],
    );
  }

  /// `Forgot Password ?`
  String get forgotPassword {
    return Intl.message(
      'Forgot Password ?',
      name: 'forgotPassword',
      desc: '',
      args: [],
    );
  }

  /// `Login`
  String get login {
    return Intl.message(
      'Login',
      name: 'login',
      desc: '',
      args: [],
    );
  }

  /// `Register`
  String get register {
    return Intl.message(
      'Register',
      name: 'register',
      desc: '',
      args: [],
    );
  }

  /// `Email id`
  String get emailId {
    return Intl.message(
      'Email id',
      name: 'emailId',
      desc: '',
      args: [],
    );
  }

  /// `Password`
  String get password {
    return Intl.message(
      'Password',
      name: 'password',
      desc: '',
      args: [],
    );
  }

  /// `Please enter your email address to recover your password.`
  String get pleaseEnterYourEmailAddressToRecoverYourPassword {
    return Intl.message(
      'Please enter your email address to recover your password.',
      name: 'pleaseEnterYourEmailAddressToRecoverYourPassword',
      desc: '',
      args: [],
    );
  }

  /// `Email address`
  String get emailAddress {
    return Intl.message(
      'Email address',
      name: 'emailAddress',
      desc: '',
      args: [],
    );
  }

  /// `Empty email`
  String get emptyEmail {
    return Intl.message(
      'Empty email',
      name: 'emptyEmail',
      desc: '',
      args: [],
    );
  }

  /// `Recover Password`
  String get recoverPassword {
    return Intl.message(
      'Recover Password',
      name: 'recoverPassword',
      desc: '',
      args: [],
    );
  }

  /// `Password reset email sent`
  String get passwordResetEmailSent {
    return Intl.message(
      'Password reset email sent',
      name: 'passwordResetEmailSent',
      desc: '',
      args: [],
    );
  }

  /// `Register Now`
  String get registerNow {
    return Intl.message(
      'Register Now',
      name: 'registerNow',
      desc: '',
      args: [],
    );
  }

  /// `Already have an account ?`
  String get alreadyHaveAnAccount {
    return Intl.message(
      'Already have an account ?',
      name: 'alreadyHaveAnAccount',
      desc: '',
      args: [],
    );
  }

  /// `Enter Email Address`
  String get enterEmailAddress {
    return Intl.message(
      'Enter Email Address',
      name: 'enterEmailAddress',
      desc: '',
      args: [],
    );
  }

  /// `Enter a valid email address.`
  String get enterAValidEmailAddress {
    return Intl.message(
      'Enter a valid email address.',
      name: 'enterAValidEmailAddress',
      desc: '',
      args: [],
    );
  }

  /// `Password must be at least 6 characters long.`
  String get passwordMustBeAtLeast6CharactersLong {
    return Intl.message(
      'Password must be at least 6 characters long.',
      name: 'passwordMustBeAtLeast6CharactersLong',
      desc: '',
      args: [],
    );
  }

  /// `Enter the UserName`
  String get enterTheUsername {
    return Intl.message(
      'Enter the UserName',
      name: 'enterTheUsername',
      desc: '',
      args: [],
    );
  }

  /// `Signup failed ${error.toString()}`
  String get signupFailedErrortostring {
    return Intl.message(
      'Signup failed \${error.toString()}',
      name: 'signupFailedErrortostring',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'hi'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
