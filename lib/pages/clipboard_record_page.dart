import 'dart:async';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:quick_copy_paste/models/clipboard_item.dart';
import 'package:quick_copy_paste/pages/clipboard_item_widget.dart';
import '../tools/eventbus_manager.dart';

class ClipboardRecordPage extends StatefulWidget {
  const ClipboardRecordPage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<ClipboardRecordPage> createState() => _ClipboardRecordPageState();
}

class _ClipboardRecordPageState extends State<ClipboardRecordPage> with AutomaticKeepAliveClientMixin {

  final List<ClipboardItem> _items = [];
  late StreamSubscription eventBusSubscription;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    eventBusSubscription = eventBusManager.eventBus.on<ClipboardItem>().listen((event) {
      _items.add(event);
      if (mounted) {
        setState(() {});
      }
      String text = event.text ?? "";
      print("收到event bus: ${text}");
      BotToast.showText(text: "收到event bus: ${text}");
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget createRow(int i) {
    var item = _items[i];
    item.index = i;
    return ClipboardItemWidget(item: item);
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
      body: ListView.builder(
        itemCount: _items.length,
        itemBuilder: (BuildContext context, int position) {
          return createRow(position);
        },
      ),
       // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}