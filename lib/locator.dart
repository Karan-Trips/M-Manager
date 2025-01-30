import 'package:get_it/get_it.dart';
import 'package:try1/app_db.dart';

GetIt locator = GetIt.instance;
setuplocator() async {
  locator.registerSingletonAsync<AppDb>(() => AppDb.getInstance());
  
}
