import 'package:hotkey_manager/hotkey_manager.dart';

enum HotKeyType {
  copy, paste
}

class HotKeyItem {
   bool isEnable = false;
   String title = "";
   HotKey? hotKey;
   HotKeyType type = HotKeyType.copy;

   HotKeyItem(this.isEnable,this.title, this.type, this.hotKey);
}