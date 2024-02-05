import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:quick_copy_paste/models/hotkey.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HotKeyItemCacheManager {
  SharedPreferences? sharedPreferences;

  /// The shared instance of [HotKeyItemCacheManager].
  static final HotKeyItemCacheManager instance = HotKeyItemCacheManager._();

  final String _allHotKeyCacheKeys = "AllHotKeyCacheKeys";
  final String _copyKey = "copyHotKey";
  final String _pasteKey = "pasteHotKey";

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

  bool isCopyKey(String cacheKey) {
    return cacheKey == _copyKey;
  }

  bool isPasteKey(String cacheKey) {
    return cacheKey == _pasteKey;
  }

  String? getCacheKey(HotKeyItem hotKeyItem) {
    var hotKey = hotKeyItem.hotKey;
    var customHotKey = hotKeyItem.customHotKey;
    String? cacheKey;
    if ((hotKey != null && hotKeyItem.type != HotKeyType.custom) ||
        customHotKey != null) {
      switch (hotKeyItem.type) {
        case HotKeyType.copy:
          cacheKey = _copyKey;
          break;
        case HotKeyType.paste:
          cacheKey = _pasteKey;
          break;
        case HotKeyType.custom:
          if (customHotKey != null) {
            cacheKey = "customHotKey_";
            cacheKey += "${customHotKey.keyCode.index}";
            customHotKey.modifiers?.forEach((element) {
              cacheKey = "${cacheKey}_${element.index}";
            });
          }
          break;
      }
    }
    return cacheKey;
  }

  HotKeyItem createKeyItem(HotKeyType type) {
    return HotKeyItem(true, false, type.getKeyInfo().$2, type);
  }

  Future<void> saveHotKeyItem(HotKeyItem hotKeyItem) async {
    var cacheKey = getCacheKey(hotKeyItem);
    if (cacheKey != null) {
      await (await getSharedPreferences())
          .setString(cacheKey, json.encode(hotKeyItem.toJson()));
      await saveCacheKey(cacheKey);
    }
  }

  Future<void> updateHotKeyItem(HotKeyItem hotKeyItem) async {
    return await saveHotKeyItem(hotKeyItem);
  }

  Future<HotKeyItem?> getHotKeyItem(String cacheKey) async {
    String? cacheKeyJosn = (await getSharedPreferences()).getString(cacheKey);
    debugPrint("cacheKeyJosn: $cacheKeyJosn");
    if (cacheKeyJosn == null) {
      return null;
    }

    HotKeyItem? keyItem;
    try {
      var jsonMap = json.decode(cacheKeyJosn);
      keyItem = HotKeyItem.fromJson(jsonMap);
    } catch (e) {
      await removeHotKeyItemByCacheKey(cacheKey);
      debugPrint("catch error: $e");
    }

    return keyItem;
  }

  Future<HotKeyItem?> getCopyHotKeyItem() async {
    return await getHotKeyItem(_copyKey);
  }

  Future<HotKeyItem?> getPasteHotKeyItem() async {
    return await getHotKeyItem(_pasteKey);
  }

  Future<void> removeHotKeyItemByCacheKey(String cacheKey) async {
    (await getSharedPreferences()).remove(cacheKey);
    await removeCacheKey(cacheKey);
  }

  Future<void> removeHotKeyItem(HotKeyItem item) async {
    var cacheKey = getCacheKey(item);
    if (cacheKey != null) {
      await removeHotKeyItemByCacheKey(cacheKey);
    }
  }

  Future<void> saveCacheKey(String cacheKey) async {
    List<String> list = await getAllCacheKeys();
    if (!list.contains(cacheKey)) {
      if (isCopyKey(cacheKey)) {
        list.insert(0, cacheKey);
      } else if (isPasteKey(cacheKey)) {
        list.insert(list.first == _copyKey ? 1 : 0, cacheKey);
      } else {
        list.add(cacheKey);
      }
    }
    (await getSharedPreferences()).setStringList(_allHotKeyCacheKeys, list);
  }

  Future<void> removeCacheKey(String cacheKey) async {
    List<String> list = await getAllCacheKeys();
    list.remove(cacheKey);
    (await getSharedPreferences()).setStringList(_allHotKeyCacheKeys, list);
  }

  Future<List<String>> getAllCacheKeys() async {
    var list =
        (await getSharedPreferences()).getStringList(_allHotKeyCacheKeys) ?? [];
    // 复制和粘贴排在头两位
    if (list.isNotEmpty &&
        (list.first != _copyKey ||
            (list.length >= 2 && list[1] != _pasteKey))) {
      list.remove(_copyKey);
      list.remove(_pasteKey);
      list.insert(0, _pasteKey);
      list.insert(0, _copyKey);
    }

    var set = Set<String>.from(list);
    return set.toList();
  }

  Future<List<HotKeyItem>> getAllHotKeyItems() async {
    List<HotKeyItem> list = [];
    var keys = await getAllCacheKeys();
    for (var cacheKey in keys) {
      var hotKeyItem = await getHotKeyItem(cacheKey);
      if (hotKeyItem != null) {
        list.add(hotKeyItem);
      }
    }

    // 默认添加复制和粘贴
    if (!isContains(HotKeyType.paste, list)) {
      var pasteItem = await getPasteHotKeyItem();
      pasteItem ??= createKeyItem(HotKeyType.paste);
      list.insert(0, pasteItem);
      await saveHotKeyItem(pasteItem);
    }

    if (!isContains(HotKeyType.copy, list)) {
      var copyItem = await getCopyHotKeyItem();
      copyItem ??= createKeyItem(HotKeyType.copy);
      list.insert(0, copyItem);
      await saveHotKeyItem(copyItem);
    }

    return list;
  }

  Future<HotKeyItem?> getHotKeyItemByType(HotKeyType type) async {
    var items = await getAllHotKeyItems();
    for (var item in items) {
      if (item.type == type) {
        return item;
      }
    }
    return null;
  }

  Future<HotKeyItem?> getHotKeyItemByKey(HotKey hotKey) async {
    var items = await getAllHotKeyItems();
    for (var item in items) {
      if (item.hotKey?.isTheSame(hotKey) == true) {
        return item;
      }
    }
    return null;
  }

  bool isContains(HotKeyType type, List<HotKeyItem> items) {
    var isContainsType = false;
    for (var item in items) {
      if (item.type == type) {
        isContainsType = true;
        break;
      }
    }
    return isContainsType;
  }
}

final hotKeyCacheManager = HotKeyItemCacheManager.instance;
