import 'dart:async';
import 'dart:convert';

import 'package:quick_copy_paste/models/hotkey.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HotKeyItemCacheManager {
  SharedPreferences? sharedPreferences;

  /// The shared instance of [HotKeyItemCacheManager].
  static final HotKeyItemCacheManager instance = HotKeyItemCacheManager._();

  HotKeyItemCacheManager._() {
    setUpData();
  }

  void setUpData() {
    scheduleMicrotask(() async {
      sharedPreferences = await SharedPreferences.getInstance();
    });
  }

  Future<SharedPreferences> getSharedPreferences() async {
    return sharedPreferences ??= await SharedPreferences.getInstance();
  }

  Future<void> saveHotKeyItem(HotKeyItem hotKeyItem) async {
    var hotKey = hotKeyItem.hotKey;
    if (hotKey != null) {
      await (await getSharedPreferences()).setString(hotKeyItem.type.getKeyInfo().$1, json.encode(hotKeyItem.toJson()));
    }
  }

  Future<HotKeyItem?> getCacheKeyItem(HotKeyType type) async {
    String? cacheKeyJosn = (await getSharedPreferences()).getString(type.getKeyInfo().$1);
    print("cacheKeyJosn: ${cacheKeyJosn}");
    if (cacheKeyJosn == null) {
      return null;
    }

    HotKeyItem? keyItem;
    try {
      var jsonMap = json.decode(cacheKeyJosn);
      keyItem = HotKeyItem.fromJson(jsonMap);
    } catch(e) {
      await removeCacheKeyItem(type);
      print("catch error: ${e}");
    }

    return keyItem;
  }

  HotKeyItem createKeyItem(HotKeyType type) {
    return HotKeyItem(true, false, type.getKeyInfo().$2, type, null);
  }

  Future<void> removeCacheKeyItem(HotKeyType type) async {
    (await getSharedPreferences()).remove(type.getKeyInfo().$1);
  }
}

final hotKeyItemManager = HotKeyItemCacheManager.instance;