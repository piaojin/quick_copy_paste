import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/services.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:pasteboard/pasteboard.dart';

import '../models/clipboard_item.dart';
import '../models/hotkey.dart';
import 'clipboard_manager.dart';
import 'copy_paste_event.dart';
import 'eventbus_manager.dart';
import 'hotkey_cache_manager.dart';

class PJHotKeyCacheManager {
  PJHotKeyCacheManager._();

  /// The shared instance of [PJHotKeyCacheManager].
  static final PJHotKeyCacheManager instance = PJHotKeyCacheManager._();

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
      hotKeyManager.register(hotKey,
          keyDownHandler: (triggerHotKey) async {
            await handleTriggerHotKeyEvent(triggerHotKey);
          },
          keyUpHandler: (triggerHotKey) => {
                if (keyUpHandler != null) {keyUpHandler(triggerHotKey)}
              });
    }
  }

  Future<void> registerAllHotKey() async {
    // 初始化快捷键
    await unregisterAll();
    var items = await hotKeyCacheManager.getAllHotKeyItems();
    for (var item in items) {
      await register(item);
    }
  }

  Future<void> unregisterAll() async {
    return await hotKeyManager.unregisterAll();
  }

  Future<void> handleTriggerHotKeyEvent(HotKey triggerHotKey) async {
    var hotKeyItem = await hotKeyCacheManager.getHotKeyItemByKey(triggerHotKey);
    if (hotKeyItem != null) {
      switch (hotKeyItem.type) {
        case HotKeyType.copy:
          await clipboardManager.simulateCtrlC(() {
            Future.delayed(const Duration(milliseconds: 500), () async {
              String? text = await Pasteboard.text;
              text ??= "";
              if (text.isNotEmpty) {
                eventBusManager.eventBus
                    .fire(CopyPasteEvent(HotKeyType.copy, ClipboardItem(text)));
              }
            });
          });
          break;
        case HotKeyType.paste:
          eventBusManager.eventBus.fire(CopyPasteEvent(HotKeyType.paste, null));
          break;
        case HotKeyType.custom:
          var customHotKey = hotKeyItem.customHotKey;
          if (customHotKey != null) {
            await clipboardManager.simulateWithHotKey(customHotKey);
          }
          break;
      }
      BotToast.showText(text: "触发快捷键: $triggerHotKey");
    }
  }

  List<ModifierKey> getModifiers(HotKey hotKey) {
    List<ModifierKey> modifiers = [];
    hotKey.modifiers?.forEach((item) {
      modifiers.add(item.modifierKey);
    });
    return modifiers;
  }

  Future<bool> isDuplicateHotKey(HotKey hotKey) async {
    var list = await hotKeyCacheManager.getAllHotKeyItems();
    for (var item in list) {
      if (item.hotKey?.isTheSame(hotKey) == true) {
        return true;
      }
    }
    return false;
  }

  Future<bool> isDuplicateCustomHotKey(HotKey hotKey) async {
    var list = await hotKeyCacheManager.getAllHotKeyItems();
    for (var item in list) {
      if (item.customHotKey?.isTheSame(hotKey) == true) {
        return true;
      }
    }
    return false;
  }

  bool isConflictWithSystemHotKey(HotKey hotKey) {
    var keyCodeIndex = hotKey.keyCode.index;
    var isCharacter = keyCodeIndex >= KeyCode.keyC.index &&
        keyCodeIndex <= KeyCode.keyZ.index;
    var modifiers = hotKey.modifiers;
    if (modifiers != null &&
        modifiers.length == 1 &&
        modifiers.first == KeyModifier.meta &&
        isCharacter) {
      return true;
    }
    return false;
  }
}

final pjHotKeyManager = PJHotKeyCacheManager.instance;
