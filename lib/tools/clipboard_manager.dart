import 'dart:ffi';
import 'dart:io';
import 'dart:async';
import 'package:pasteboard/pasteboard.dart';
import 'package:keypress_simulator/keypress_simulator.dart';
import 'package:flutter/services.dart';

class ClipboardManager {
  ClipboardManager._();
  /// The shared instance of [ClipboardManager].
  static final ClipboardManager instance = ClipboardManager._();

  Future<void> simulateCtrlC() async {
    await simulateKeyboardPressWithCtrl(LogicalKeyboardKey.keyC);
  }

  Future<void> simulateCtrlV() async {
    await simulateKeyboardPressWithCtrl(LogicalKeyboardKey.keyV);
  }

  Future<void> simulateCtrlZ() async {
    await simulateKeyboardPressWithCtrl(LogicalKeyboardKey.keyZ);
  }

  Future<void> simulateKeyboardPressWithCtrl(LogicalKeyboardKey key) async {
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