

import 'package:flutter/material.dart';

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

class _ClipboardRecordPageState extends State<ClipboardRecordPage> {

  final List _widgets = [];

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < 100; i++) {
      _widgets.add(getRow(i));
    }
  }

  Widget getRow(int i) {
    return GestureDetector(
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Text("Row $i"),
      ),
      onTap: () {
        setState(() {
          _widgets.add(getRow(_widgets.length + 1));
          print('row $i');
        });
      },
    );
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
      body: ListView.builder(
        itemCount: _widgets.length,
        itemBuilder: (BuildContext context, int position) {
          return getRow(position);
        },
      ),
       // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}