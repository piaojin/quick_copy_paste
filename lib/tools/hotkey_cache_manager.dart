import 'dart:async';
import 'dart:convert';

import 'package:quick_copy_paste/models/hotkey.dart';
import 'package:shared_preferences/shared_preferences.dart';


class HotKeyItemCacheManager {
  SharedPreferences? sharedPreferences;

  /// The shared instance of [HotKeyItemCacheManager].
  static final HotKeyItemCacheManager instance = HotKeyItemCacheManager._();

  static const String _allHotKeyItemKeys = "AllHotKeyItemKeys";

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
      await saveHotKeyItemKey(hotKeyItem.type);
      await saveHotKeyType(hotKeyItem.type);
    }
  }

  Future<HotKeyItem?> getHotKeyItem(HotKeyType type) async {
    String? cacheKeyJosn = (await getSharedPreferences()).getString(type.getKeyInfo().$1);
    print("cacheKeyJosn: $cacheKeyJosn");
    if (cacheKeyJosn == null) {
      return null;
    }

    HotKeyItem? keyItem;
    try {
      var jsonMap = json.decode(cacheKeyJosn);
      keyItem = HotKeyItem.fromJson(jsonMap);
    } catch(e) {
      await removeHotKeyItem(type);
      await removeHotKeyType(type);
      await removeHotKeyItemKey(type);
      print("catch error: $e");
    }

    return keyItem;
  }

  HotKeyItem createKeyItem(HotKeyType type) {
    return HotKeyItem(true, false, type.getKeyInfo().$2, type, null);
  }

  Future<void> removeHotKeyItem(HotKeyType type) async {
    (await getSharedPreferences()).remove(type.getKeyInfo().$1);
  }

  Future<void> removeHotKeyItemBy(HotKeyItem hotKeyItem) async {
    await removeHotKeyItemKey(hotKeyItem.type);
    await removeHotKeyType(hotKeyItem.type);
    await removeHotKeyItem(hotKeyItem.type);
  }

  Future<void> saveHotKeyItemKey(HotKeyType type) async {
    List<String> list = await getAllHotKeyItemKeys();
    if (!list.contains(type.getKeyInfo().$1)) {
      list.add(type.getKeyInfo().$1);
    }
    (await getSharedPreferences()).setStringList(_allHotKeyItemKeys, list);
  }

  Future<List<String>> getAllHotKeyItemKeys() async {
    var list = (await getSharedPreferences()).getStringList(_allHotKeyItemKeys) ?? [];
    var set = Set<String>.from(list);
    return set.toList();
  }

  Future<void> removeHotKeyItemKey(HotKeyType type) async {
    List<String> list = await getAllHotKeyItemKeys();
    list.remove(type.getKeyInfo().$1);
    (await getSharedPreferences()).setStringList(_allHotKeyItemKeys, list);
  }

  Future<void> saveHotKeyType(HotKeyType type) async {
    (await getSharedPreferences()).setInt("${type.getKeyInfo().$1}HotKeyType", type.index);
  }

  Future<HotKeyType?> getHotKeyType(String key) async {
    var index = (await getSharedPreferences()).getInt(key);
    if (index != null) {
      return HotKeyType.values[index];
    }
    return null;
  }

  Future<void> removeHotKeyType(HotKeyType type) async {
    (await getSharedPreferences()).remove("${type.getKeyInfo().$1}HotKeyType");
  }

  Future<List<HotKeyItem>> getAllHotKeyItems() async {
    List<HotKeyItem> list = [];
    var keys = await getAllHotKeyItemKeys();
    for (var key in keys) {
      var hotKeyType = await getHotKeyType("${key}HotKeyType");
      if (hotKeyType != null) {
        var hotKeyItem = await getHotKeyItem(hotKeyType);
        if (hotKeyItem != null) {
          list.add(hotKeyItem);
        }
      }
    }
    return list;
  }
}

final hotKeyCacheManager = HotKeyItemCacheManager.instance;