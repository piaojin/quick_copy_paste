import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pasteboard/pasteboard.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/services.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:keypress_simulator/keypress_simulator.dart';
import '../tools/clipboard_manager.dart';


final hotKeyManager = HotKeyManager.instance;

final kShortcutSimulateCtrlT = HotKey(
  KeyCode.keyT,
  modifiers: [
    Platform.isMacOS ? KeyModifier.meta : KeyModifier.control,
  ],
);

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // void _copyText() async {
  //   if (_controller.text.isEmpty) {
  //     BotToast.showText(text: '啥都没输入，你要我复制什么🥴');
  //   } else {
  //     Pasteboard.writeText(_controller.text);
  //   }
  // }

  // void _pasteText() async {
  //   String? results = await Pasteboard.text;
  //   _text = results ?? '啥都没有';
  //   setState(() {});
  // }

  @override
  void initState() {
    super.initState();
    // TODO: implement initState
// 初始化快捷键
    hotKeyManager.unregisterAll();
    hotKeyManager.register(
      kShortcutSimulateCtrlT,
      keyDownHandler: (_) async {
        print('simulateCtrlAKeyPress');
        // simulateCtrlC();
        clipboardManager.simulateCtrlC();
      },
    );
  }

  void simulateCtrlC() async {
    await keyPressSimulator.simulateKeyPress(
      key: LogicalKeyboardKey.keyC,
      modifiers: [
        Platform.isMacOS
            ? ModifierKey.metaModifier
            : ModifierKey.controlModifier,
      ],
    );
    await keyPressSimulator.simulateKeyPress(
      key: LogicalKeyboardKey.keyC,
      modifiers: [
        Platform.isMacOS
            ? ModifierKey.metaModifier
            : ModifierKey.controlModifier,
      ],
      keyDown: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
          ],
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}