import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HotKeyItemWidget extends StatefulWidget {
  const HotKeyItemWidget({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<HotKeyItemWidget> createState() => _HotKeyItemWidgetState();
}

class _HotKeyItemWidgetState extends State<HotKeyItemWidget> {
  String title = '热键名称';
  String hotKey = '';
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    _controller.addListener(() {
      print('did chnage text: ${_controller.text}');
    });
    super.initState();
  }

  @override
  void dispose() {
    _controller.removeListener(() {});
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
    return Center(
      child: Column(
        children: [
          Row(
            children: [
              Checkbox(value: true, 
              onChanged: (bool? value) {},
              ),
              Text(title),
              Expanded(
                child: Container(),
              ),

                RawKeyboardListener(
                autofocus: true,
                onKey: (event) {
                  if (event.runtimeType == RawKeyDownEvent || event.runtimeType == RawKeyUpEvent) {
                    if(event.data is RawKeyEventDataMacOs){
                      RawKeyEventDataMacOs datga = event.data as RawKeyEventDataMacOs;
                      ///获取按键键值 keycode
                      // _value = datga.keyCode.toString();
                      print('flutter down: ${datga.keyCode}');
                    }
                  }
                },
                focusNode: FocusNode(),
                child:  SizedBox(
                width: 150,
                height: 45,
                child: TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    hintText: '请设置热键',
                    counterText: '',
                    border: const OutlineInputBorder(),
                    enabled: true,
                    focusColor: Colors.grey,
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.close), 
                      onPressed: () {
                        _controller.clear();
                      },
                      ),
                  ),
                  maxLines: 1,
                  cursorColor: Colors.transparent,
                  textAlign: TextAlign.center,
                ),
              ),
              ),
            ],
          ),
          const Divider(height: 1.0, color: Colors.green),
        ],
      ),
    );
  }

  void onPressed() {
    _controller.clear();
  }
}
