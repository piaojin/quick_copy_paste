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

class _ManageHotKeyPageState extends State<ManageHotKeyPage>
    with AutomaticKeepAliveClientMixin, WidgetsBindingObserver {
  final List<HotKeyItem> _items = [];
  int? _selectIndex;
  bool _isInEditMode = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    scheduleMicrotask(() async {
      _items.addAll(await _getItems());
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

  Future<List<HotKeyItem>> _getItems() async {
    return await hotKeyCacheManager.getAllHotKeyItems();
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

  Widget _buildItem(int i) {
    var item = _items[i];
    return HotKeyItemWidget(
        index: i,
        didSelectClosure: (i) {
          handleSelectAction(i);
        },
        didUpdateStateClosure: (i, isEnable) {
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
      var oldItem = _items[_selectIndex ?? index];
      oldItem.isSelect = false;
      oldItem.isSelectCustomHotKey = false;
      oldItem.isSelectReplacementHotKey = false;
    }

    var item = _items[index];
    item.isSelect = true;
    item.isSelectCustomHotKey = true;
    _selectIndex = index;
    setIsInEditMode(true);
    setState(() {});
  }

  void handleDeselectAction() {
    deselectItem();
  }

  void deselectItem() {
    if (_selectIndex != null) {
      var item = _items[_selectIndex ?? 0];
      item.isSelect = false;
      _selectIndex = null;
      setIsInEditMode(false);
      item.isSelectCustomHotKey = false;
      item.isSelectReplacementHotKey = false;
      if (item.hotKey == null &&
          item.isEnable &&
          item.type == HotKeyType.custom) {
        item.isEnable = false;
      }
      setState(() {});
    }
  }

  void handleUpdateHotKeyState(int index, bool isEnable) {
    var item = _items[index];
    var hotKey = item.hotKey;
    if (hotKey != null) {
      item.isEnable = isEnable;
      if (isEnable) {
        pjHotKeyManager.register(item);
      } else {
        pjHotKeyManager.unregister(hotKey);
      }
      hotKeyCacheManager.updateHotKeyItem(item);
    } else {
      if (item.type == HotKeyType.custom) {
        item.isEnable = false;
        BotToast.showText(text: "请先录制热键");
      } else {
        item.isEnable = isEnable;
        hotKeyCacheManager.updateHotKeyItem(item);
      }
    }
  }

  void handleRemoveHotKeyAction(int index) async {
    var item = _items[index];
    var hotKey = item.hotKey;
    if (hotKey != null) {
      await pjHotKeyManager.unregister(hotKey);
      await hotKeyCacheManager.removeHotKeyItem(item);
      item.hotKey = null;
    }
  }

  Future<void> handleRecordHotKeyAction(HotKey newHotKey) async {
    if (!widget.getVisible()) {
      return;
    }

    if (_selectIndex != null) {
      var item = _items[_selectIndex ?? 0];
      var oldHotKey = item.hotKey;

      if (oldHotKey != null && oldHotKey.isTheSame(newHotKey)) {
        return;
      }

      var isRecordCustomHotKey =
          item.type == HotKeyType.custom && item.isSelectCustomHotKey;

      // 选中了自定义热键item,但没选中其中的自定义热键或替换热键.
      if (item.type == HotKeyType.custom &&
          !item.isSelectCustomHotKey &&
          !item.isSelectReplacementHotKey) {
        return;
      }

      // 新设置的自定义热键和旧的一样，不做处理。
      if (isRecordCustomHotKey &&
          item.customHotKey?.isTheSame(newHotKey) == true) {
        return;
      }

      if (!isRecordCustomHotKey &&
          pjHotKeyManager.isConflictWithSystemHotKey(newHotKey)) {
        BotToast.showText(text: "热键$newHotKey与系统热键冲突，请更换其他热键！");
        return;
      }

      if ((oldHotKey?.isTheSame(newHotKey) == false || oldHotKey == null) &&
          await pjHotKeyManager.isDuplicateHotKey(newHotKey) &&
          !isRecordCustomHotKey) {
        BotToast.showText(text: "热键$newHotKey已被设置");
        return;
      }

      if (isRecordCustomHotKey &&
          await pjHotKeyManager.isDuplicateCustomHotKey(newHotKey)) {
        BotToast.showText(text: "自定义热键$newHotKey已被设置");
        return;
      }

      if (isRecordCustomHotKey) {
        setState(() {});
        // 更新自定义热键时移除旧的自定义热键,在保存新的自定义热键.
        await hotKeyCacheManager.removeHotKeyItem(item);
        item.customHotKey = newHotKey;
        await hotKeyCacheManager.saveHotKeyItem(item);
      } else {
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
        BotToast.showText(text: "录制了热键: $newHotKey");
      }
    }
  }

  void handleAddCustomHotKey() {
    var customItem = HotKeyItem(false, false, "自定义热键", HotKeyType.custom);
    _items.add(customItem);
    setState(() {});
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
        floatingActionButton: FloatingActionButton(
          backgroundColor: const Color.fromARGB(255, 30, 144, 255),
          foregroundColor: Colors.white,
          tooltip: "添加自定义热键",
          onPressed: () => {handleAddCustomHotKey()},
          child: const Icon(Icons.add),
        ),
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
                    return _buildItem(position);
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
