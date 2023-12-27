import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:pasteboard/pasteboard.dart';
import 'package:quick_copy_paste/models/clipboard_item.dart';
import 'package:quick_copy_paste/models/hotkey.dart';
import 'package:quick_copy_paste/tools/clipboard_manager.dart';
import 'package:quick_copy_paste/tools/eventbus_manager.dart';
import '../widgets/hotkey_item_widget.dart';
import '../tools/store_manager.dart';
import 'package:hotkey_manager/hotkey_manager.dart';


class ManageHotKeyPage extends StatefulWidget {
  const ManageHotKeyPage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<ManageHotKeyPage> createState() => _ManageHotKeyPageState();
}

class _ManageHotKeyPageState extends State<ManageHotKeyPage> {
  final List<HotKeyItem> _items = [];
  int? _selectIndex;
  HotKey? _hotKey;

  @override
  void initState() {
    super.initState();
    var copyItem = HotKeyItem(true, false, "一键复制", HotKeyType.copy, null);
    var pasteItem = HotKeyItem(true, false, "一键粘贴", HotKeyType.paste, null);
    _items.add(copyItem);
    _items.add(pasteItem);
    storeManager.setString('action', 'Start');
  }

  Widget createRow(int i) {
    var item = _items[i];
    return HotKeyItemWidget(
        index: i,
        didSelectClosure: (i) {
          handleSelectAction(i);
        },
        item: item);
  }

  void handleSelectAction(int index) {
    if (_selectIndex != null) {
      _items[_selectIndex ?? index].isSelect = false;
    }

    _items[index].isSelect = true;
    _selectIndex = index;
    setState(() {});
    print("*********$index");
  }

  void handleDeselectAction() {
    if (_selectIndex != null) {
      _items[_selectIndex ?? 0].isSelect = false;
      _selectIndex = null;
      setState(() {});
    }
  }

  void handleRecordHotKeyAction(HotKey newHotKey) {
    if (_selectIndex != null) {
      var item = _items[_selectIndex ?? 0];
      item.hotKey = newHotKey;
      setState(() {});

      hotKeyManager.unregister(newHotKey);

      hotKeyManager.register(newHotKey, keyDownHandler: (hotKey) async {
        print("触发快捷键: ${hotKey}");
         BotToast.showText(text: "触发快捷键: ${hotKey}");
         if (hotKey == item.hotKey) {
          switch (item.type) {
            case HotKeyType.copy:
              await clipboardManager.simulateCtrlC();
              String? text = await Pasteboard.text;
              text ??= "";
              if (text.isNotEmpty) {
                eventBusManager.eventBus.fire(ClipboardItem(text));
              }
              break;
            case HotKeyType.paste:
              await clipboardManager.simulateCtrlV();
              break;
          }
         }
      });

      print("录制了快捷键: ${newHotKey}");
      BotToast.showText(text: "录制了快捷键: ${newHotKey}");
    }
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
        body: Stack(
      children: [
        Positioned(
          child: Offstage(
            offstage: true,
            child: HotKeyRecorder(
              onHotKeyRecorded: (hotKey) {
                handleRecordHotKeyAction(hotKey);
              },
            ),
          ),
        ),
        Positioned(
          child: GestureDetector(
            child: ListView.builder(
              itemCount: _items.length,
              itemBuilder: (BuildContext context, int position) {
                return createRow(position);
              },
            ),
            onTap: () {
              handleDeselectAction();
            },
          ),
        ),
      ],
    )
        // This trailing comma makes auto-formatting nicer for build methods.
        );
  }
}
