import 'dart:convert';

import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:quick_copy_paste/common/pj_const.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum HotKeyType {
  copy, paste
}

extension HotKeyTypeExtension on HotKeyType {
  (String cacheKey, String title) getKeyInfo() {
    switch (this) {
      case HotKeyType.copy:
        return (PJConst.copyKey, "一键复制");
      case HotKeyType.paste:
        return (PJConst.pasteKey, "一键粘贴");
    }
  }
}

class HotKeyItem {
   bool isEnable = true;
   bool isSelect = false;
   String title = "";
   HotKey? hotKey;
   HotKeyType type = HotKeyType.copy;

   HotKeyItem(this.isEnable, this.isSelect, this.title, this.type, this.hotKey);

   Map<String, dynamic> toJson() {
    var hotKeyMap = hotKey?.toJson() ?? const MapEntry(String, dynamic);
    return {
      'isEnable': isEnable,
      'isSelect': isSelect,
      'title': title,
      'hotKey': hotKeyMap,
      'type': type.index
    };
  }

  factory HotKeyItem.fromJson(Map<String, dynamic> json) {
    bool isEnable = json['isEnable'];
    String title = json['title'];
    var hotKey = HotKey.fromJson(json['hotKey']);
    HotKeyType type = HotKeyType.values[json['type']];
    return HotKeyItem(isEnable, false, title, type, hotKey);
  }
}

extension HotKeyExtension on HotKey {
  bool isTheSame(HotKey key) {
    if (modifiers?.length == key.modifiers?.length) {
        modifiers?.sort((a, b) => a.index.compareTo(b.index));
        key.modifiers?.sort((a, b) => a.index.compareTo(b.index));
    }
    return keyCode == key.keyCode;
  }
}