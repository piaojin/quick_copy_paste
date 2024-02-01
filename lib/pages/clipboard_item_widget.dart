import 'package:flutter/material.dart';
import 'package:quick_copy_paste/models/clipboard_item.dart';

class ClipboardItemWidget extends StatefulWidget {
  const ClipboardItemWidget({Key? key, required this.item}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final ClipboardItem item;

  @override
  State<ClipboardItemWidget> createState() => _ClipboardItemWidgetState();
}

class _ClipboardItemWidgetState extends State<ClipboardItemWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
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
    var i = widget.item.index + 1;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            Row(children: [
              Padding(
                padding: const EdgeInsets.only(right: 20),
                child: Text(
                  "$i",
                  style: const TextStyle(
                    color: Color.fromARGB(255, 30, 144, 255),
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
              Expanded(
                  child: Text(
                "${widget.item.text}",
                maxLines: 6,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.black),
              ))
            ]),
            Container(
              padding: const EdgeInsets.only(top: 10),
              child: const Divider(
                  height: 1.0, color: Color.fromARGB(255, 220, 220, 220)),
            )
          ],
        ),
      ),
    );
  }
}
