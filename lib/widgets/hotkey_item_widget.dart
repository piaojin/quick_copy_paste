import 'package:flutter/material.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:quick_copy_paste/models/hotkey.dart';

class HotKeyItemWidget extends StatefulWidget {
  const HotKeyItemWidget(
      {Key? key,
      required this.index,
      this.didSelectClosure,
      this.didUpdateStateClosure,
      required this.item})
      : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final int index;
  final HotKeyItem item;
  final Function(int)? didSelectClosure;
  final Function(int, bool)? didUpdateStateClosure;

  @override
  State<HotKeyItemWidget> createState() => _HotKeyItemWidgetState();
}

class _HotKeyItemWidgetState extends State<HotKeyItemWidget> {
  String title = '热键名称';
  final HotKey _hotKey = HotKey(KeyCode.control);

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void handleCheckBoxAction(bool value) {
    widget.item.isEnable = value;
    if (widget.didUpdateStateClosure != null) {
      widget.didUpdateStateClosure!(widget.index, value);
    }
    setState(() {});
  }

  void handleTapAction() {
    if (widget.didSelectClosure != null) {
      widget.didSelectClosure!(widget.index);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    // widget.didSelectClosure
    
    return GestureDetector(
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Container(
          decoration: BoxDecoration(
            border: Border.fromBorderSide( 
              BorderSide(
                width: 3, color: widget.item.getUIInfo().$1, style: widget.item.isSelect ? BorderStyle.solid : BorderStyle.none)
            ),
          ),
          child: Center(
            child: Column(
              children: [
                Row(
                  children: [
                    Checkbox(
                      value: widget.item.isEnable,
                      onChanged: (bool? value) {
                        handleCheckBoxAction(value ?? false);
                      },
                    ),
                    Text(widget.item.title),
                    Expanded(
                      child: Container(),
                    ),
                    Offstage(
                      offstage: widget.item.hotKey == null,
                      child: HotKeyVirtualView(
                          hotKey: widget.item.hotKey ?? _hotKey),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.only(top: 10),
                  child: Divider(height: 1.0, color: widget.item.getUIInfo().$1),
                ),
              ],
            ),
          ),
        ),
      ),
      onTap: () {
        handleTapAction();
      },
    );
  }
}
