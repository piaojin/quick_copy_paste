import '../models/clipboard_item.dart';
import '../models/hotkey.dart';

class CopyPasteEvent {
  HotKeyType type = HotKeyType.copy;
  ClipboardItem? item;
  CopyPasteEvent(this.type, this.item);
}