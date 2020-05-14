import 'dart:convert';

import 'package:flui/flui.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:im_go/chat/ChatScreen.dart';
import 'package:im_go/contact/contacts.dart';
import 'package:im_go/dao/AppChatHistoryDao.dart';
import 'package:im_go/dao/AppChatListDao.dart';
import 'package:im_go/util/Dialog.dart';
import 'package:im_go/util/HttpClient.dart';

import '../main.dart';

class ChatView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return ChatViewStateful();
  }
}

class ChatViewStateful extends State<ChatView> {
  AppChatHistoryDao appChatHistoryDao = new AppChatHistoryDao();
  List<Chat> _datas = [];
  bool _cancelConnect = false;
  AppChatListDao appChatListDao = new AppChatListDao();

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initContacts();
//    print('来了');
  }

  Future<List<Chat>> getDatas() async {
    _cancelConnect = false;
    final response = await http
        .get('http://rap2.taobao.org:38080/app/mock/245766/api/chat/list');
    if (response.statusCode == 200) {
      var respones_Body = json.decode(response.body);

      List<Chat> chat_list = respones_Body['chat_list']
          .map<Chat>((item) => Chat.formJson(item))
          .toList();
      return chat_list;
    } else {
      throw Exception('stateCode=${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: _datas.length == 0
            ? Center(
                child: Text("loading"),
              )
            : ListView.separated(
                itemCount: _datas.length,
                separatorBuilder: (BuildContext context, int index) {
//                  return index % 2 == 0
//                      ? Divider(color: Colors.blue)
//                      : Divider(color: Colors.red);
                  return Divider(
                    color: Colors.black38,
                  );
                },
                itemBuilder: (BuildContext context, int index) {
                  return ListTile(
                    onTap: () {
                      Navigator.push(context, new MaterialPageRoute(
                          builder: (BuildContext context) {
                        ContactInfo c = new ContactInfo();
                        c.contactId = _datas[index].receiveId;
                        c.username = _datas[index].name;
                        return ChatPage(c);
                      }));
                    },
//                    isThreeLine: true,
                    dense: true,
                    leading: FLAvatar(
                      image: (_datas[index].imageUrl == null ||
                              _datas[index].imageUrl == "")
                          ? Image.asset("images/timg_orther.jpg")
                          : Image.network(_datas[index].imageUrl),
                      width: 50,
                      height: 50,
                      radius: 40, // if not specify, will be width / 2
                    ),
//                    leading: Container(
//                      height: 50,
//                      width: 50,
//                      decoration: BoxDecoration(
////                          borderRadius: BorderRadius.circular(8),
//                          image: DecorationImage(
////                              fit: BoxFit.fitHeight,
//                              image: (_datas[index].imageUrl == null ||
//                                      _datas[index].imageUrl == "")
//                                  ? AssetImage("images/timg_orther.jpg")
//                                  : NetworkImage(_datas[index].imageUrl))),
//                    ),
                    title: Text(_datas[index].name),
                    subtitle: Container(
                      child: Text((_datas[index].lastChatMessage == "" ||
                              _datas[index].lastChatMessage == null)
                          ? ""
                          : _datas[index].lastChatMessage),
                      height: 20,
                    ),
                  );
                }),
      ),
      appBar: AppBar(
//        centerTitle: true,
        title: Text(
          "聊天",
          style: TextStyle(color: Colors.white),
        ),
        actions: <Widget>[
          Container(
            margin: EdgeInsets.only(right: 15, bottom: 0),
            child: PopupMenuButton(
              offset: Offset(0, 150),
              child: Image(
                image: AssetImage('icons/heart/Add.png'),
                height: 30,
                width: 30,
              ),
              itemBuilder: _PopMenuItemBuild,
              color: Colors.green,
            ),
          )
        ],
      ),
    );
  }

  List<PopupMenuItem<String>> _PopMenuItemBuild(BuildContext context) {
    return <PopupMenuItem<String>>[
      _CreatPopMenuBuildItem('images/群聊.png', '发起群聊'),
      _CreatPopMenuBuildItem('images/添加朋友.png', '添加朋友'),
    ];
  }

  PopupMenuItem<String> _CreatPopMenuBuildItem(String imageName, String title) {
    return PopupMenuItem<String>(
      child: Row(
        children: <Widget>[
          Image(
            image: AssetImage(imageName),
            width: 25,
          ),
          SizedBox(width: 20),
          Text(
            title,
            style: TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }

  void initContacts() async {
    appChatListDao
        .queryAppChatList(userId)
        .then((List<Map<String, dynamic>> dataMap) {
      List<String> userIds = new List();
      dataMap.forEach((t) {
        userIds.add(t['recive_id'].toString());
      });
      if (userIds.length == 0) {
        print('没有聊天记录');
        return;
      }
      var body = {'userIds': userIds.join(",")};
      print(body);

      httpPost(host + userInfo, body).then((Response response) {
        print(response.statusCode);
        if (response.statusCode == 200) {
          var dataJson = jsonDecode(response.body);

          if (dataJson['code'] == 1) {
            //todo 显示历史聊天记录
            print("chat:" + dataJson.toString());
            List<int> ids = new List();
            for (var line in dataJson['data']) {
              Chat chat = new Chat(
                  name: line['NickName'],
                  message: "",
                  imageUrl: line['Avatar'],
                  receiveId: line['Id']);
//              queryChatMessageLastNew
              ids.add(line['Id']);
              this._datas.add(chat);
            }
            var reFu = appChatHistoryDao.queryChatMessageLastNew(ids);
            if (reFu != null) {
              reFu.then((Map<int, String> data) {
                for (var c in _datas) {
                  c.lastChatMessage = data[c.receiveId];
                }
                setState(() {
                  print('渲染历史信息');
                });
              });
            }
            //查询聊天最新的记录
            setState(() {
              print('渲染历史聊天界面');
            });
          } else {
            showAlertDialog(context, desc: dataJson['msg']);
          }
        } else {}
      });
    });
  }
}

class Chat {
  final String name;
  final String message;
  final String imageUrl;
  final int receiveId;
  String lastChatMessage;

  Chat(
      {this.name,
      this.message,
      this.imageUrl,
      this.receiveId,
      this.lastChatMessage});

  factory Chat.formJson(Map json) {
    return Chat(
      name: json['user_name'],
      message: json['message'],
      imageUrl: json['image_url'],
    );
  }
}
