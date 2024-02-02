import 'package:flutter/material.dart';
import 'package:quick_copy_paste/models/clipboard_item.dart';

class ClipboardItemWidget extends StatefulWidget {
  const ClipboardItemWidget({Key? key, required this.item, this.didTapRemoveClosure}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final ClipboardItem item;
  final Function(ClipboardItem)? didTapRemoveClosure;

  @override
  State<ClipboardItemWidget> createState() => _ClipboardItemWidgetState();
}

class _ClipboardItemWidgetState extends State<ClipboardItemWidget> {
  var isMouseEnter = false;
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
    return MouseRegion(
                onEnter: (_) {
                  isMouseEnter = true;
                  setState(() {});
                },
                onExit: (_) {
                  isMouseEnter = false;
                  setState(() {});
                },
                onHover: (_) => {},
                child: Center(
      child: Container(
        color: isMouseEnter ? const Color.fromARGB(255, 224, 224, 224) : i % 2 == 0 ? const Color.fromARGB(255, 242, 242, 242) : const Color.fromARGB(255, 251, 251, 251),
        child: Padding(
        padding: const EdgeInsets.only(top: 10.0, left: 10.0, right: 10.0, bottom: 5.0),
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
              )),

              Padding(
                padding: const EdgeInsets.only(right: 2),
                child: Offstage(
                        offstage: !isMouseEnter,
                        child: SizedBox(
                          width: 30,
                          height: 30,
                          child: IconButton(
                              onPressed: () {
                                if (widget.didTapRemoveClosure != null) {
                                  widget.didTapRemoveClosure!(widget.item);
                                }
                              },
                              splashRadius: 20.0,
                              padding: EdgeInsets.zero,
                              icon: const Icon(Icons.remove_circle_outlined, color: Colors.red)),
                        ),
                      ))
            ])
          ],
        ),
      ),
      )
    ),
              );
  }
}
