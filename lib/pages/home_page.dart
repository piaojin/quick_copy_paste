import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hotkey_manager/hotkey_manager.dart';

import '../tools/pj_hotkey_manager.dart';
import 'clipboard_record_page.dart';
import 'manage_hotkey_page.dart';
import 'package:quick_copy_paste/tools/clipboard_manager.dart';

final kShortcutSimulateCtrlT = HotKey(
  KeyCode.keyT,
  modifiers: [
    Platform.isMacOS ? KeyModifier.meta : KeyModifier.control,
  ],
);


class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with SingleTickerProviderStateMixin {
  late TabController _tabcontroller;
  late var manageHotKeyPage = ManageHotKeyPage(title: "热键管理");
  late var clipboardRecordPage = const ClipboardRecordPage(title: "记录管理");
  int _currentTabIndex = 0;

  static const List<Tab> _homeTabList = <Tab>[
    Tab(text: "记录管理", icon: Icon(Icons.copy),),
    Tab(text: "热键管理", icon: Icon(Icons.keyboard),),
  ];

  @override
  void initState() {
    super.initState();
    _tabcontroller = TabController(length: _homeTabList.length, vsync: this);
    _tabcontroller.addListener(() {
      _currentTabIndex = _tabcontroller.index;
      manageHotKeyPage.setVisible(_currentTabIndex == manageHotKeyPage.index);
    });

    // 请求权限
    clipboardManager.isAccessAllowed().then((value) => {
        if (!value) {
          clipboardManager.requestAccess().then((value) => {
              scheduleMicrotask(() async {
                await pjHotKeyManager.registerAllHotKey();
              })
          })
        } else {
          scheduleMicrotask(() async {
            await pjHotKeyManager.registerAllHotKey();
          })
        }
    });
  }

  @override
  void dispose() {
    _tabcontroller.dispose();
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
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: null,
        toolbarHeight: 0,
        bottom: TabBar(
          tabs: _homeTabList, 
          controller: _tabcontroller,
          labelColor: const Color.fromARGB(255, 30, 144, 255),
          indicatorColor: const Color.fromARGB(255, 30, 144, 255),
          ),
      ),
      body: TabBarView(
        controller: _tabcontroller,
        children: [
          clipboardRecordPage,
          manageHotKeyPage,
        ],
      ),
       // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}