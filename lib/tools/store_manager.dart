import 'package:shared_preferences/shared_preferences.dart';

class StoreManager {
  //私有化SharedPreferences
  SharedPreferences? _sharedPreferences;

  //由于预加载,去掉finial
  static final StoreManager _instance = StoreManager._();

  //公开访问点
  factory StoreManager.getInstance() => _instance;

  StoreManager._() {
    // 具体初始化代码
    init();
  }

  //预加载初始化入口,防止相关对象没有初始化
  static Future<StoreManager> preInit() async {
    return _instance;
  }

  StoreManager._pre(SharedPreferences prefs) {
    _sharedPreferences = prefs;
  }

  //初始化SharedPreferences对象
  void init() async {
    _sharedPreferences = await SharedPreferences.getInstance();
  }

  Future<bool> setString(String key, String value) {
    return _sharedPreferences?.setString(key, value) ?? Future.value(false);
  }

  String? getString(String key) => _sharedPreferences?.getString(key);

  /// Saves a list of strings [value] to persistent storage in the background.
  Future<bool> setStringList(String key, List<String> value) {
    return _sharedPreferences?.setStringList(key, value) ?? Future.value(false);
  }

  /// Reads a set of string values from persistent storage, throwing an
  /// exception if it's not a string set.
  List<String>? getStringList(String key) =>
      _sharedPreferences?.getStringList(key);

  /// Removes an entry from persistent storage.
  Future<bool> remove(String key) {
    return _sharedPreferences?.remove(key) ?? Future.value(false);
  }
}

final storeManager = StoreManager.getInstance();
