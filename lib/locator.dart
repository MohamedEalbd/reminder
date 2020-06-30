import 'package:get_it/get_it.dart';
import 'package:reminder/push_nofication.dart';

GetIt locator = GetIt.instance;
void setupLocator(){
  locator.registerLazySingleton(() => PushNotificationService());
}