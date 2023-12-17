import 'package:hotkey_manager/hotkey_manager.dart';

enum HotKeyType {
  copy, paste
}

class HotKeyItem {
   bool isEnable = true;
   bool isSelect = false;
   String title = "";
   HotKey? hotKey;
   HotKeyType type = HotKeyType.copy;

   HotKeyItem(this.isEnable, this.isSelect, this.title, this.type, this.hotKey);
}