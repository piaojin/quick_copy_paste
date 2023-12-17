import 'package:flutter/services.dart';

class KeyBoardManager {
  KeyBoardManager._();
  /// The shared instance of [KeyBoardManager].
  static final KeyBoardManager instance = KeyBoardManager._();
}

final keyboardManager = KeyBoardManager.instance;