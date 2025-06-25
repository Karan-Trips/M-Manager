import 'package:get_it/get_it.dart';
import 'package:try1/app_db.dart';

GetIt locator = GetIt.instance;
Future<void> setuplocator() async {
  locator.registerSingletonAsync<AppDb>(() => AppDb.getInstance());
  
}
