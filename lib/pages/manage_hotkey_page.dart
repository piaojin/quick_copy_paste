import 'package:flutter/material.dart';
import 'package:quick_copy_paste/models/hotkey.dart';
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

  Widget createRow(int i) {
    var item = _items[i];
    return GestureDetector(
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Container(
          decoration: const BoxDecoration(
          border: Border.fromBorderSide(
            BorderSide (
              width: 5,
              color: Colors.green,
              style: BorderStyle.solid
          )
          ),
        ),
          child: HotKeyItemWidget(index: i, didSelectClosure: (i) {
            _selectIndex = i;
            print("*********$i");
        }, item: item),
        )
      ),
      onTap: () {
        print('row ${storeManager.getString('action')}');
        // setState(() {

        // });
      },
    );
  }

  @override
  void initState() {
    super.initState();
    var copyItem = HotKeyItem(false, "一键复制", HotKeyType.copy, null);
    var pasteItem = HotKeyItem(false, "一键粘贴", HotKeyType.paste, null);
    _items.add(copyItem);
    _items.add(pasteItem);
    storeManager.setString('action', 'Start');
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
                _hotKey = hotKey;
                print("录制了快捷键");
                setState(() {});
              },
            ),
          ),
          ),
          Positioned(
            child: ListView.builder(
            itemCount: _items.length,
            itemBuilder: (BuildContext context, int position) {
              return createRow(position);
            },
          ),
          ),
        ],
    )
        // This trailing comma makes auto-formatting nicer for build methods.
        );
  }
}
