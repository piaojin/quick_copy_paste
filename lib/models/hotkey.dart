import 'package:flutter/material.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:quick_copy_paste/common/pj_const.dart';

enum HotKeyType { copy, paste, custom }

extension HotKeyTypeExtension on HotKeyType {
  (String cacheKey, String title) getKeyInfo() {
    switch (this) {
      case HotKeyType.copy:
        return (PJConst.copyKey, "一键复制");
      case HotKeyType.paste:
        return (PJConst.pasteKey, "一键粘贴");
      case HotKeyType.custom:
        return (PJConst.customHotKey, "自定义热键");
    }
  }
}

class HotKeyItem {
  bool isEnable = true;
  // 是否选中整个Item
  bool isSelect = false;
  // 是否选中要替换的自定义热键
  bool isSelectCustomHotKey = false;
  // 是否选中要新建的热键
  bool isSelectReplacementHotKey = false;
  String title = "";
  HotKey? hotKey;
  // 要替换的自定义热键
  HotKey? customHotKey;
  HotKeyType type = HotKeyType.copy;

  HotKeyItem(this.isEnable, this.isSelect, this.title, this.type,
      {this.hotKey, this.customHotKey});

  Map<String, dynamic> toJson() {
    hotKey?.modifiers?.sort((a, b) => a.index.compareTo(b.index));
    var hotKeyMap = hotKey?.toJson();
    var customHotKeyMap = customHotKey?.toJson();
    var jsonMap = <String, dynamic>{};
    jsonMap['isEnable'] = isEnable;
    jsonMap['title'] = title;
    jsonMap['type'] = type.index;

    if (hotKeyMap != null) {
      jsonMap['hotKey'] = hotKeyMap;
    }

    if (customHotKeyMap != null) {
      jsonMap['customHotKey'] = customHotKeyMap;
    }

    return jsonMap;
  }

  factory HotKeyItem.fromJson(Map<String, dynamic> json) {
    bool isEnable = json['isEnable'];
    String title = json['title'];
    HotKey? customHotKey;
    HotKey? hotKey;

    var hotKeyMap = json['hotKey'];
    if (hotKeyMap != null) {
      hotKey = HotKey.fromJson(hotKeyMap);
    }

    var customHotKeyMap = json['customHotKey'];
    if (customHotKeyMap != null) {
      customHotKey = HotKey.fromJson(customHotKeyMap);
    }

    HotKeyType type = HotKeyType.values[json['type']];
    return HotKeyItem(isEnable, false, title, type,
        hotKey: hotKey, customHotKey: customHotKey);
  }

  (Color stateColor,) getUIInfo() {
    return (
      isEnable
          ? const Color.fromARGB(255, 30, 144, 255)
          : const Color.fromARGB(255, 128, 128, 128),
    );
  }
}

extension HotKeyExtension on HotKey {
  bool isTheSame(HotKey key) {
    var isSame = true;
    if (modifiers?.length == key.modifiers?.length) {
      if (modifiers?.isNotEmpty == true && key.modifiers?.isNotEmpty == true) {
        modifiers?.sort((a, b) => a.index.compareTo(b.index));
        key.modifiers?.sort((a, b) => a.index.compareTo(b.index));
        var ms = modifiers;
        var compareMs = key.modifiers;
        if (ms != null && compareMs != null) {
          for (var i = 0; i < ms.length; i++) {
            if (compareMs[i] != ms[i]) {
              isSame = false;
              break;
            }
          }
        }
      }
    } else {
      isSame = false;
    }
    return keyCode == key.keyCode && isSame;
  }
}
