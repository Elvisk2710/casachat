import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';

Future<bool> startMonitoringInternetConnection() {
  // Create a Completer to handle the asynchronous operation
  Completer<bool> completer = Completer<bool>();

  // Start monitoring internet connection
  Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> results) {
    for (var result in results) {
      if (result == ConnectivityResult.none) {
        completer.complete(false);
        // Handle actions when internet connection is lost
      } else {
        completer.complete(true);
        // Handle actions when internet connection is restored
      }
    }
  });

  // Return the Future from the Completer
  return completer.future;
}