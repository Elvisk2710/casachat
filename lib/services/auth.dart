import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';

// getting token data
String? getDataFromToken(String token, String search) {
  Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
  return decodedToken[search];
}


Future<bool> logOut() async {
  final prefs = await SharedPreferences.getInstance();
  String? tokenLandlord = prefs.getString('jwtLandlord');
  String? tokenStudent = prefs.getString('jwtStudent');
  String? token;
  if (tokenStudent != null && !JwtDecoder.isExpired(tokenStudent)) {
    token = tokenStudent;
    await prefs.remove('jwtStudent');
  } else if (tokenLandlord != null && !JwtDecoder.isExpired(tokenLandlord)) {
    token = tokenLandlord;
    await prefs.remove('jwtLandlord');
  }
  if (token != null && !JwtDecoder.isExpired(token)) {
    return false;
  }else{
    return true;
  }
}