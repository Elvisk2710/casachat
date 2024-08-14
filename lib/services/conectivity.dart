import 'package:internet_connection_checker/internet_connection_checker.dart';

Future<bool> checkInternetConnection() async {
  InternetConnectionStatus status = await InternetConnectionChecker().connectionStatus;
  return status == InternetConnectionStatus.connected;
}