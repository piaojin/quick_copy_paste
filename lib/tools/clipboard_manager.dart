import 'dart:io';
import 'dart:async';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:pasteboard/pasteboard.dart';
import 'package:keypress_simulator/keypress_simulator.dart';
import 'package:flutter/services.dart';

typedef SimulateCompletion = Function();

class ClipboardManager {
  ClipboardManager._();
  /// The shared instance of [ClipboardManager].
  static final ClipboardManager instance = ClipboardManager._();

  Future<void> simulateCtrlC(SimulateCompletion? completion) async {
    return await simulateKeyboardPressWithCtrl(LogicalKeyboardKey.keyC, completion);
  }

  Future<void> simulateCtrlV(SimulateCompletion? completion) async {
    return await simulateKeyboardPressWithCtrl(LogicalKeyboardKey.keyV, completion);
  }

  Future<void> simulateCtrlZ(SimulateCompletion? completion) async {
    return await simulateKeyboardPressWithCtrl(LogicalKeyboardKey.keyZ, completion);
  }

  Future<void> simulateKeyboardPressWithCtrl(LogicalKeyboardKey key, SimulateCompletion? completion) async {
    await _keyPressSimulator.simulateKeyPress(
      key: key,
      modifiers: [
        Platform.isMacOS
            ? ModifierKey.metaModifier
            : ModifierKey.controlModifier,
      ],
    );

    await _keyPressSimulator.simulateKeyPress(
      key: key,
      modifiers: [
        Platform.isMacOS
            ? ModifierKey.metaModifier
            : ModifierKey.controlModifier,
      ],
      keyDown: false,
    );

    if (completion != null) {
      completion();
    }
  }

  Future<void> simulateWithHotKey(HotKey hotKey, [SimulateCompletion? completion]) async {
    await simulateKey(hotKey.keyCode.logicalKey, getModifiers(hotKey), completion: completion);
  }

  Future<void> simulateKey(LogicalKeyboardKey key, List<ModifierKey> modifiers, {SimulateCompletion? completion}) async {
    await _keyPressSimulator.simulateKeyPress(
      key: key,
      modifiers: modifiers,
    );

    await _keyPressSimulator.simulateKeyPress(
      key: key,
      modifiers: modifiers,
      keyDown: false,
    );

    if (completion != null) {
      completion();
    }
  }

  List<ModifierKey> getModifiers(HotKey hotKey) {
    List<ModifierKey> modifiers = [];
    hotKey.modifiers?.forEach((item) {
      modifiers.add(item.modifierKey);
    });
    return modifiers;
  }

  Future<String?> getTextFromSystemClipboard() async {
    return await Pasteboard.text;
  }

  Future<bool> isAccessAllowed() async {
    return await _keyPressSimulator.isAccessAllowed();
  }

  Future<void> requestAccess({
    bool onlyOpenPrefPane = false,
  }) async {
    return await _keyPressSimulator.requestAccess(onlyOpenPrefPane: onlyOpenPrefPane);
  }

  void requestKeyPermissionIfNeeded(void Function(bool)? handler) async {
    clipboardManager.isAccessAllowed().then((value) => {
        if (!value) {
          clipboardManager.requestAccess().then((value) => {
              if (handler != null) {
                handler(true)
              }
          }).onError((error, stackTrace) {
            if (handler != null) {
                handler(false);
              }
            return <Set<void>>{};
          })
        } else {
          if (handler != null) {
            handler(true)
          }
        }
    });
  }
}

final clipboardManager = ClipboardManager.instance;
final _keyPressSimulator = KeyPressSimulator.instance;