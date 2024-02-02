import 'dart:async';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:quick_copy_paste/models/hotkey.dart';
import '../tools/hotkey_cache_manager.dart';
import '../tools/pj_hotkey_manager.dart';
import '../widgets/hotkey_item_widget.dart';
import 'package:hotkey_manager/hotkey_manager.dart';


class ManageHotKeyPage extends StatefulWidget {
  ManageHotKeyPage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;
  var _isVisible = false;
  final int index = 1;
  Function(bool)? didChangeVisibleClosure;

  @override
  State<ManageHotKeyPage> createState() => _ManageHotKeyPageState();

  void setVisible(bool isVisible) {
    _isVisible = isVisible;
    if (didChangeVisibleClosure != null) {
      didChangeVisibleClosure!(isVisible);
    }
  }

  bool getVisible() {
    return _isVisible;
  }
}

class _ManageHotKeyPageState extends State<ManageHotKeyPage> with AutomaticKeepAliveClientMixin, WidgetsBindingObserver {
  final List<HotKeyItem> _items = [];
  int? _selectIndex;
  bool _isInEditMode = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    scheduleMicrotask(() async {
      _items.addAll(await getItems());
      setState(() {});
    });

    widget.didChangeVisibleClosure = (isVisible) {
      if (!isVisible) {
        deselectItem();
      }
    };
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.inactive) {
      deselectItem();
    }
  }

  Future<List<HotKeyItem>> getItems() async {
    List<HotKeyItem> items = [];
    var copyItem = await hotKeyCacheManager.getHotKeyItem(HotKeyType.copy);
    copyItem ??= hotKeyCacheManager.createKeyItem(HotKeyType.copy);
    items.add(copyItem);

    var pasteItem = await hotKeyCacheManager.getHotKeyItem(HotKeyType.paste);
    pasteItem ??= hotKeyCacheManager.createKeyItem(HotKeyType.paste);
    items.add(pasteItem);
    return items;
  }

  void setIsInEditMode(bool isInEditMode) {
    _isInEditMode = isInEditMode;
    scheduleMicrotask(() async {
      if (isInEditMode) {
        pjHotKeyManager.unregisterAll();
      } else {
        pjHotKeyManager.registerAllHotKey();
      }
    });
  }

  Widget createRow(int i) {
    var item = _items[i];
    return HotKeyItemWidget(
        index: i,
        didSelectClosure: (i) {
          handleSelectAction(i);
        },
        didUpdateStateClosure: (i, isEnable){
          handleUpdateHotKeyState(i, isEnable);
        },
        didRemoveHotKeyClosure: (i) {
          handleRemoveHotKeyAction(i);
        },
        item: item);
  }

  void handleSelectAction(int index) {
    if (_selectIndex == index) {
      deselectItem();
      return;
    }

    if (_selectIndex != null) {
      _items[_selectIndex ?? index].isSelect = false;
    }

    _items[index].isSelect = true;
    _selectIndex = index;
    setIsInEditMode(true);
    setState(() {});
  }

  void handleDeselectAction() {
    deselectItem();
  }

  void deselectItem() {
    if (_selectIndex != null) {
      _items[_selectIndex ?? 0].isSelect = false;
      _selectIndex = null;
      setIsInEditMode(false);
      setState(() {});
    }
  }

  void handleUpdateHotKeyState(int index, bool isEnable) {
      _items[index].isEnable = isEnable;
      var item = _items[index];
      var hotKey = item.hotKey;
      if (hotKey != null) {
        if (isEnable) {
          pjHotKeyManager.register(item);
        } else {
          pjHotKeyManager.unregister(hotKey);
        }
      }
  }

  void handleRemoveHotKeyAction(int index) async {
      var item = _items[index];
      var hotKey = item.hotKey;
      if (hotKey != null) {
        await pjHotKeyManager.unregister(hotKey);
        await hotKeyCacheManager.removeHotKeyItemBy(item);
        item.hotKey = null;
      }
  }

  Future<void> handleRecordHotKeyAction(HotKey newHotKey) async {
    if (!widget.getVisible()) {
      return;
    }

    if (pjHotKeyManager.isConflictWithSystemHotKey(newHotKey)) {
      BotToast.showText(text: "热键$newHotKey与系统热键冲突，请更换其他热键！");
      return;
    }

    if (_selectIndex != null) {
      var item = _items[_selectIndex ?? 0];
      var oldHotKey = item.hotKey;

      if(oldHotKey != null && oldHotKey.isTheSame(newHotKey)) {
        return;
      }

      if ((oldHotKey?.isTheSame(newHotKey) == false || oldHotKey == null) && await pjHotKeyManager.isDuplicateHotKey(newHotKey)) {
        BotToast.showText(text: "热键$newHotKey已被设置");
        return;
      }

      if (oldHotKey != null) {
        await pjHotKeyManager.unregister(oldHotKey);
      }
      item.hotKey = newHotKey;
      setState(() {});

      if (item.isEnable) {
        await pjHotKeyManager.register(item);
      }

      await hotKeyCacheManager.saveHotKeyItem(item);
      deselectItem();
      BotToast.showText(text: "录制了快捷键: $newHotKey");
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 251, 251, 251),
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
  
  @override
  bool get wantKeepAlive => true;
}
