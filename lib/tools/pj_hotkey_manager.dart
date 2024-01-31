
import 'package:bot_toast/bot_toast.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:pasteboard/pasteboard.dart';

import '../models/clipboard_item.dart';
import '../models/hotkey.dart';
import 'clipboard_manager.dart';
import 'copy_paste_event.dart';
import 'eventbus_manager.dart';
import 'hotkey_item_manager.dart';

class PJHotKeyManager {
  PJHotKeyManager._();
  /// The shared instance of [PJHotKeyManager].
  static final PJHotKeyManager instance = PJHotKeyManager._();

  Future<void> unregister(HotKey hotKey) async {
    return await hotKeyManager.unregister(hotKey);
  }

  Future<void> register(
    HotKeyItem hotKeyItem, {
    HotKeyHandler? keyDownHandler,
    HotKeyHandler? keyUpHandler,
  }) async {
    var hotKey = hotKeyItem.hotKey;
    if (hotKeyItem.isEnable && hotKey != null) {
      hotKeyManager.register(hotKey, keyDownHandler:(triggerHotKey) async {
        BotToast.showText(text: "触发快捷键: $hotKey");
            if (hotKey.isTheSame(triggerHotKey) == true) {
              switch (hotKeyItem.type) {
                case HotKeyType.copy:
                  await clipboardManager.simulateCtrlC(() {
                    Future.delayed(const Duration(milliseconds: 500), () async {
                      String? text = await Pasteboard.text;
                      text ??= "";
                      if (text.isNotEmpty) {
                          eventBusManager.eventBus.fire(CopyPasteEvent(HotKeyType.copy, ClipboardItem(text)));
                      } 
                    });
                  });
                  break;
                case HotKeyType.paste:
                  eventBusManager.eventBus.fire(CopyPasteEvent(HotKeyType.paste, null));
                  break;
              }
            }
      }, keyUpHandler:(triggerHotKey) => {
        if (keyUpHandler != null) {
          keyUpHandler(triggerHotKey)
        }
      });
    }
  }

  Future<void> registerAllHotKey() async {
    // 初始化快捷键
    await unregisterAll();
    var items = await hotKeyItemManager.getAllHotKeyItems();
    for (var item in items) {
       await register(item);
    }
  }

  Future<void> unregisterAll() async {
    return await hotKeyManager.unregisterAll();
  }
}

final pjHotKeyManager = PJHotKeyManager.instance;