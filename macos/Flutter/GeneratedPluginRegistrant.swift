//
//  Generated file. Do not edit.
//

import FlutterMacOS
import Foundation

import hotkey_manager
import keypress_simulator
import pasteboard
import shared_preferences_foundation

func RegisterGeneratedPlugins(registry: FlutterPluginRegistry) {
  HotkeyManagerPlugin.register(with: registry.registrar(forPlugin: "HotkeyManagerPlugin"))
  KeypressSimulatorPlugin.register(with: registry.registrar(forPlugin: "KeypressSimulatorPlugin"))
  PasteboardPlugin.register(with: registry.registrar(forPlugin: "PasteboardPlugin"))
  SharedPreferencesPlugin.register(with: registry.registrar(forPlugin: "SharedPreferencesPlugin"))
}
