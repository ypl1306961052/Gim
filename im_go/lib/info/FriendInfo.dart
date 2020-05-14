import 'package:flui/flui.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:im_go/chat/ChatScreen.dart';
import 'package:im_go/contact/contacts.dart';
import 'package:im_go/dao/AppChatListDao.dart';
import 'package:im_go/main.dart';
import 'package:im_go/util/sqlfile.dart';

class FriendInfoPage extends StatefulWidget {
  ContactInfo _contactInfo;

  FriendInfoPage(ContactInfo contactInfo) {
    _contactInfo = contactInfo;
  }

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return FriendInfoPageSate(_contactInfo);
  }
}

class FriendInfoPageSate extends State<FriendInfoPage> {
  ContactInfo _contactInfo;
  AppChatListDao appChatListDao = new AppChatListDao();

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        leading: Container(
          child: Icon(Icons.navigate_before),
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
//          ListTile(
//            title: Text("用户名字:" + _contactInfo.username),
//            subtitle: Text("手机号:" + _contactInfo.mobile),
//            leading: FLAvatar(
//              image: (_contactInfo.avatar == null || _contactInfo.avatar == "")
//                  ? Image.asset("images/timg.jpg")
//                  : Image.network(_contactInfo.avatar),
//              width: 50,
//              height: 50,
//              radius: 40, // if not specify, will be width / 2
//            ),
//          ),
          Container(
              padding: EdgeInsets.all(10),
              child: Card(
                  child: Container(
                width: double.infinity,
                child: Stack(
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(top: 10, left: 5),
                      child: FLAvatar(
                        image: (_contactInfo.avatar == null ||
                                _contactInfo.avatar == "")
                            ? Image.asset("images/timg.jpg")
                            : Image.network(_contactInfo.avatar),
                        width: 50,
                        height: 50,
                        radius: 40, // if not specify, will be width / 2
                      ),
                    ),
                    Column(
                      children: <Widget>[
                        Container(
                          margin: EdgeInsets.only(left: 70, top: 5, right: 10),
                          height: 20,
                          child: Text("用户名字:" + _contactInfo.username ?? ""),
                          width: 320,
                        ),
                        Container(
                          margin: EdgeInsets.only(left: 70, top: 5, right: 10),
                          height: 20,
                          child: Text(
                              "用户ID:" + _contactInfo.contactId.toString() ??
                                  ""),
                          width: 320,
                        ),
                        Container(
                          margin: EdgeInsets.only(
                              left: 70, top: 5, right: 10, bottom: 5),
                          height: 20,
                          child: Text("用户手机号:" +
                              ((_contactInfo.mobile == null)
                                  ? ""
                                  : _contactInfo.mobile)),
                          width: 320,
                        ),
                      ],
                    )
                  ],
                ),
              ))),
          Container(
            child: _contactInfo.isShowSendBtu
                ? FLFlatButton(
                    expanded: true,
                    color: Colors.green,
                    textColor: Colors.white,
                    child: Text('发送消息', textAlign: TextAlign.center),
                    onPressed: () {
                      // ...
                      saveAppChatList(_contactInfo);
                      intoChatPage(_contactInfo, context);
                    })
                : null,
            margin: EdgeInsets.only(left: 10, right: 10),
          ),
        ],
      ),
    );
  }

  void intoChatPage(ContactInfo contactInfo, BuildContext context) {
    Navigator.pushReplacement(
        context,
        new PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 500),
          pageBuilder: (context, _, __) => ChatPage(_contactInfo),
          transitionsBuilder:
              (_, Animation<double> animation, __, Widget child) =>
                  new FadeTransition(
            opacity: animation,
            child: child,
//                  child: new RotationTransition(
//                    turns: new Tween<double>(begin: 0.0, end: 1.0)
//                        .animate(animation),
//                    child: child,
//                  ),
          ),
        ));

//    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
//      return ChatScreen(_contactInfo);
//    })
//    );
  }

  FriendInfoPageSate(ContactInfo contactInfo) {
    _contactInfo = contactInfo;
  }

  void saveAppChatList(ContactInfo contactInfo) async {
    var resultList = await appChatListDao.queryAppChatList(userId,
        receiveId: contactInfo.contactId);
    if (resultList.length > 0) {
      //存在跟新
      print('更新数据');
      await appChatListDao.updateAppChatList(userId, contactInfo.contactId);
    } else {
      //插入数据
      print('插入数据');
      await appChatListDao.insertIntoAppChatList(userId, contactInfo.contactId,
          unreadCount: 0);
    }
  }
}
