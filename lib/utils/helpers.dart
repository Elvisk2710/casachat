import 'package:flutter/material.dart';

class Helpers {
  // Method to navigate to another screen with back function
  /// This function navigates to another screen and also allows the user to go back to the previous screen
  static void temporaryNavigator(BuildContext context, Widget nextScreen) {
    Navigator.push(context, MaterialPageRoute(builder: (c) => nextScreen));
  }


  // Method to navigate to another screen without back function
  /// This function completely deletes the previous screen from the context hence the back key completely exits the app
  static void permanentNavigator(BuildContext context, Widget nextScreen) {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (c) => nextScreen)
    );
  }

}
