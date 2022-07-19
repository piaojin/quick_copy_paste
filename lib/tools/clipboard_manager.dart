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
    await _keyPressSimulator.simulateKeyPress(
      key: LogicalKeyboardKey.keyC,
      modifiers: [
        Platform.isMacOS
            ? ModifierKey.metaModifier
            : ModifierKey.controlModifier,
      ],
    );

    await _keyPressSimulator.simulateKeyPress(
      key: LogicalKeyboardKey.keyC,
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
}

final clipboardManager = ClipboardManager.instance;
final _keyPressSimulator = KeyPressSimulator.instance;