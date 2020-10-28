import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesHelper {
  static final SharedPreferencesHelper _instance =
      new SharedPreferencesHelper.internal();
  factory SharedPreferencesHelper() => _instance;
  static SharedPreferences _sp;

  Future<SharedPreferences> get sp async {
    if (_sp != null) return _sp;
    _sp = await SharedPreferences.getInstance();
    return _sp;
  }

  SharedPreferencesHelper.internal();

  Future<String> getString(String key) async {
    var spClient = await sp;
    return spClient.getString(key);
  }

  Future<bool> getBool(String key) async {
    var spClient = await sp;
    return spClient.getBool(key);
  }

  Future<int> getInt(String key) async {
    var spClient = await sp;
    return spClient.getInt(key);
  }

  void setString(String key, String value) async {
    var spClient = await sp;
    spClient.setString(key, value);
  }

  void setBool(String key, bool value) async {
    var spClient = await sp;
    spClient.setBool(key, value);
  }

  void setInt(String key, int value) async {
    var spClient = await sp;
    spClient.setInt(key, value);
  }
}
