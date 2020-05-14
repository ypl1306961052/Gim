import 'package:flui/flui.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'chat/chat.dart';
import 'contact/contacts.dart';
import 'near/near.dart';

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "IM",
      theme: ThemeData(primarySwatch: Colors.green),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return HomePageStateful();
  }
}

class HomePageStateful extends State<HomePage> {
  int _currentIndex = 0;
  final _viewOptions = [ChatView(), ContactsView(), NearView()];
  bool showBadge = true;
  static int chatUnreadCount;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
//      appBar: AppBar(
//        title: Text("IM"),
//      ),
      body: _viewOptions[_currentIndex],
//      drawer: ,
      bottomNavigationBar: BottomNavigationBar(
        items: _createBottomNavigationBarItem(chatUnreadCount: chatUnreadCount),
        currentIndex: _currentIndex,
        fixedColor: Colors.blue,
        onTap: _onItem,
      ),
    );
  }

  List<BottomNavigationBarItem> _createBottomNavigationBarItem(
      {int chatUnreadCount}) {
    return <BottomNavigationBarItem>[
      BottomNavigationBarItem(
        icon: FLBadge(
          child: Icon(Icons.chat),
          hidden: (chatUnreadCount == null),
          text:
              (chatUnreadCount == null) ? "" : "" + chatUnreadCount.toString(),
        ),
        title: Text('chat'),
      ),
      BottomNavigationBarItem(icon: Icon(Icons.contacts), title: Text("好友")),
      BottomNavigationBarItem(icon: Icon(Icons.near_me), title: Text("附近"))
    ];
  }

  void _onItem(int curIndex) {
    setState(() {
      _currentIndex = curIndex;
    });
  }
}
