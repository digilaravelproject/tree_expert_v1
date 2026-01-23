import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'shared_prefs.dart';

import '../constent/app_constants.dart';

class TokenManager {
  static const _secureStorage = FlutterSecureStorage();

  static Future<String> getToken() async {
    String? token = await _secureStorage.read(key: AppConstants.tokenPref);
    if (token == null || token.isEmpty) {
      token = SharedPrefs.getString(AppConstants.tokenPref);
    }
    return token ?? '';
  }

  static Future<void> saveToken(String token) async {
    await _secureStorage.write(key: AppConstants.tokenPref, value: token);
    await SharedPrefs.setString(AppConstants.tokenPref, token);
  }

  static Future<void> clearToken() async {
    await _secureStorage.delete(key: AppConstants.tokenPref);
    await SharedPrefs.remove(AppConstants.tokenPref);
  }
}