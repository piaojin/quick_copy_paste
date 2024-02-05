import 'package:flutter/material.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:quick_copy_paste/models/hotkey.dart';

class HotKeyItemWidget extends StatefulWidget {
  const HotKeyItemWidget(
      {Key? key,
      required this.index,
      this.didSelectClosure,
      this.didUpdateStateClosure,
      this.didRemoveHotKeyClosure,
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
  final Function(int)? didRemoveHotKeyClosure;

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

  void handleTapItemAction() {
    if (widget.didSelectClosure != null) {
      widget.didSelectClosure!(widget.index);
    }
    setState(() {});
  }

  void handleTapCustomHotKeyAction() {
    if (widget.item.isSelect && widget.item.type == HotKeyType.custom) {
      widget.item.isSelectCustomHotKey = !widget.item.isSelectCustomHotKey;
      widget.item.isSelectReplacementHotKey = false;
      setState(() {});
    } else {
      handleTapItemAction();
    }
  }

  void handleTapReplacementHotKeyAction() {
    if (widget.item.isSelect && widget.item.type == HotKeyType.custom) {
      widget.item.isSelectReplacementHotKey =
          !widget.item.isSelectReplacementHotKey;
      widget.item.isSelectCustomHotKey = false;
      setState(() {});
    } else {
      handleTapItemAction();
    }
  }

  void handleRemoveHotKeyAction() {
    if (widget.didRemoveHotKeyClosure != null) {
      widget.didRemoveHotKeyClosure!(widget.index);
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
        padding: const EdgeInsets.only(top: 10, left: 10, right: 10),
        child: Container(
          decoration: BoxDecoration(
            border: Border.fromBorderSide(BorderSide(
                width: 3,
                color: widget.item.getUIInfo().$1,
                style: widget.item.isSelect
                    ? BorderStyle.solid
                    : BorderStyle.none)),
          ),
          child: Center(
            child: Column(
              children: [
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Checkbox(
                        value: widget.item.isEnable,
                        activeColor: const Color.fromARGB(255, 30, 144, 255),
                        onChanged: (bool? value) {
                          handleCheckBoxAction(value ?? false);
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: GestureDetector(
                        onTap: handleTapCustomHotKeyAction,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            border: Border.fromBorderSide(BorderSide(
                                width: 2,
                                color: widget.item.getUIInfo().$1,
                                style: () {
                                  if (widget.item.type == HotKeyType.custom &&
                                      widget.item.isSelectCustomHotKey) {
                                    return BorderStyle.solid;
                                  }
                                  return BorderStyle.none;
                                }())
                                ),
                          ),
                          child: Visibility(
                            visible: () {
                              if (widget.item.type == HotKeyType.custom && widget.item.customHotKey != null) {
                                return true;
                              }
                              return false;
                            }(),
                            replacement: Text(widget.item.title),
                            child: Padding(
                              padding: const EdgeInsets.only(right: 2),
                              child: (){
                                var customReplaceHotKey = widget.item.customHotKey;
                                if (customReplaceHotKey != null) {
                                  return HotKeyVirtualView(
                                    hotKey: customReplaceHotKey);
                                } else {
                                  return Text(widget.item.title);
                                }
                              }(),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: GestureDetector(
                        onTap: handleTapReplacementHotKeyAction,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            border: Border.fromBorderSide(BorderSide(
                                width: 2,
                                color: widget.item.getUIInfo().$1,
                                style: () {
                                  if (widget.item.type == HotKeyType.custom &&
                                      widget.item.isSelectReplacementHotKey) {
                                    return BorderStyle.solid;
                                  }
                                  return BorderStyle.none;
                                }())),
                          ),
                          child: Visibility(
                            visible: widget.item.hotKey != null,
                            replacement: const Text("请录制..."),
                            child: Padding(
                              padding: const EdgeInsets.only(right: 2),
                              child: Offstage(
                                offstage: widget.item.hotKey == null,
                                child: HotKeyVirtualView(
                                    hotKey: widget.item.hotKey ?? _hotKey),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                        padding: const EdgeInsets.only(top: 8, right: 2),
                        child: Offstage(
                          offstage: widget.item.hotKey == null ||
                              widget.item.isSelect == false,
                          child: SizedBox(
                            width: 30,
                            height: 30,
                            child: IconButton(
                                onPressed: () {
                                  handleRemoveHotKeyAction();
                                },
                                splashRadius: 20.0,
                                padding: EdgeInsets.zero,
                                icon: const Icon(Icons.clear_sharp)),
                          ),
                        )),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.only(top: 10),
                  child:
                      Divider(height: 1.0, color: widget.item.getUIInfo().$1),
                ),
              ],
            ),
          ),
        ),
      ),
      onTap: () {
        handleTapItemAction();
      },
    );
  }
}
