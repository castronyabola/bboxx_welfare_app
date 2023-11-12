import 'package:shared_preferences/shared_preferences.dart';

class UserSimplePreferences {
  static SharedPreferences _preferences;

  static const _keyLanguage = 'language';
  static const _keyShop = 'shop';

  static Future init() async =>
      _preferences = await SharedPreferences.getInstance();

  static Future setLanguage(String language) async =>
      await _preferences.setString(_keyLanguage, language);

  static String getLanguage() => _preferences.getString(_keyLanguage);

  static Future setShop(String shop) async =>
      await _preferences.setString(_keyShop, shop);

  static String getShop() => _preferences.getString(_keyShop);

}
