import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';

// getting token data
String? getUserIdFromToken(String token, String search) {
  Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
  return decodedToken[search];
}

Future<String> checkJwtToken() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('jwt');

  if (token != null && !JwtDecoder.isExpired(token)) {
    String? userId = getUserIdFromToken(token, "user_id");
    if (userId != null) {
      return userId;
    } else {
      return '';
    }
  } else {
    return '';
  }
}