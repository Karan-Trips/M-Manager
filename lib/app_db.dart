import 'package:hive_flutter/hive_flutter.dart';
import 'package:m_manager/locator.dart';

class AppDb {
  final Box<String> _userBox; // Box for user-related data (String)
  final Box<bool> _settingsBox; // Box for settings (bool)

  AppDb._(this._userBox, this._settingsBox);

  String get fcmToken => _userBox.get("fcm_token", defaultValue: "0")!;
  set fcmToken(String update) => _userBox.put("fcm_token", update);

  Future<void> storeUserId(String userId) async {
    await _userBox.put('userId', userId);
  }

  Future<String?> getUserId() async {
    return _userBox.get('userId');
  }

  Future<void> deleteUserId() async {
    await _userBox.delete('userId');
  }

  bool get isFirstTime =>
      _settingsBox.get("is_first_time", defaultValue: true)!;
  set isFirstTime(bool value) => _settingsBox.put("is_first_time", value);

  bool get isLogin => _settingsBox.get("is_login", defaultValue: false)!;
  set isLogin(bool value) => _settingsBox.put("is_login", value);

  static Future<AppDb> getInstance() async {
    final userBox = await Hive.openBox<String>('authBox');
    final settingsBox = await Hive.openBox<bool>('settingsBox');
    return AppDb._(userBox, settingsBox);
  }
}

final appDb = locator<AppDb>();
