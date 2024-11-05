import 'package:hive_flutter/hive_flutter.dart';
import 'package:try1/locator.dart';

class AppDb {
  final Box<dynamic> _box;
  AppDb._(this._box);
  T getValue<T>(key, {T? defaultValue}) =>
      _box.get(key, defaultValue: defaultValue) as T;
  String get fcmToken => getValue("fcm_token", defaultValue: "0");

  set fcmToken(String update) => setValue("fcm_token", update);
  Future<void> setValue<T>(key, T value) => _box.put(key, value);
  Future<void> storeUserId(String userId) async {
    final box = Hive.box<String>('authBox');
    await box.put('userId', userId);
  }

  static Future<AppDb> getInstance() async {
    final box = await Hive.openBox<String>('authBox');
    return AppDb._(box);
  }

  Future<String?> getUserId() async {
    final box = Hive.box<String>('authBox');
    return box.get('userId');
  }

  Future<void> deleteUserId() async {
    final box = Hive.box<String>('authBox');
    await box.delete('userId');
  }
}

final appDb = locator<AppDb>();
