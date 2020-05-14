import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:im_go/chat/ChatMessage.dart';
import 'package:im_go/contact/contacts.dart';
import 'package:im_go/dao/AppChatHistoryDao.dart';
import 'package:im_go/info/FriendInfo.dart';
import 'package:im_go/record/voice_widget.dart';
import 'package:im_go/util/time.dart';
import 'package:im_go/util/websocket.dart';
import 'package:image_picker/image_picker.dart';

import 'package:flutter/foundation.dart';

import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../main.dart';

var currentUserEmail;
var _scaffoldContext;

class ChatScreen extends StatefulWidget {
  ContactInfo _contactInfo;

  ChatScreen(this._contactInfo);

  @override
  ChatScreenState createState() {
    return new ChatScreenState(this._contactInfo);
  }
}

//文字
const int MESSAGE_TYPE_TEXT = 1;
//图片
const int MESSAGE_TYPE_IMAGE = 2;
//语音
const int MESSAGE_TYPE_VOICE = 3;

class ChatMessage {
  int id;

  //发送时间
  int time;

  //接收者Id
  int receiveId;
  String receiveName;

  //接收人的头像
  String receiveAvatar;

  int sendId;
  String sendName;
  String sendAvatar;

  //消息内容 图片 文字
  int messageType;
  String content;
  String url;

  //语音长度
  int speechLength;

  //是否发送者
  bool isSender;
}

class ChatScreenState extends State<ChatScreen> {
  ContactInfo _contactInfo;
  List<ChatMessage> chatMessages = new List();
  WebSocketManager webSocketManager = WebSocketManager();
  bool isDisPose = false;
  AppChatHistoryDao appChatHistoryDao = new AppChatHistoryDao();
  int defaultChatCount = 20;
  ScrollController scrollController = new ScrollController();

  @override
  void dispose() {
    super.dispose();
    isDisPose = true;
  }

  ChatScreenState(this._contactInfo);

  final TextEditingController _textEditingController =
      new TextEditingController();
  bool _isComposingMessage = false;

  void initChatHistoryMessage() {
    appChatHistoryDao
        .queryChatHistory(_contactInfo.contactId,
            start: 0, size: defaultChatCount)
        .then((List<Map<String, dynamic>> data) {
      if (chatMessages.length > 0) {
        chatMessages.clear();
      }
      for (var line in data) {
        var chatMessage = new ChatMessage();
        chatMessage.receiveId = line['receive_id'];
        chatMessage.sendId = userId;
        chatMessage.id = line['id'];
        chatMessage.messageType = line['media'];
        chatMessage.time = line['time'];
        chatMessage.url = line['url'];
        chatMessage.sendName = username;
        chatMessage.sendAvatar = avatar;
        chatMessage.receiveName = _contactInfo.username;
        chatMessage.receiveAvatar = _contactInfo.avatar;
        if (line['is_sender'] == 1) {
          chatMessage.isSender = true;
        } else if (line['is_sender'] == 0) {
          chatMessage.isSender = false;
        }
        chatMessage.speechLength = line['voice_len'];
        chatMessage.content = line['content'];
        chatMessages.add(chatMessage);
      }
      //
      scrollController.animateTo(
          scrollController.position.maxScrollExtent + 120, //滚动到底部
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut);
      setState(() {
        print('刷新聊天记录');
      });
    });
  }

  @override
  void initState() {
    super.initState();
    isDisPose = false;
    initChatHistoryMessage();

//    webSocketManager.addDataListen(new ChatMessageListen(this));
  }

  @override
  Widget build(BuildContext context) {
    isDisPose = false;
    return new Scaffold(
        appBar: new AppBar(
          centerTitle: true,
          title: new Text(this._contactInfo.username +
              "(" +
              this._contactInfo.contactId.toString() +
              ")"),
          elevation:
              Theme.of(context).platform == TargetPlatform.iOS ? 0.0 : 4.0,
          actions: <Widget>[
            new IconButton(
              icon: new Icon(Icons.exit_to_app),
            )
          ],
        ),
        body: new Container(
          child: new Column(
            children: <Widget>[
              //
              new Flexible(
                  child: ListView.separated(
                      itemBuilder: (BuildContext context, int index) {
                        return EntryItem(chatMessages[index]);
                      },
                      controller: scrollController,
                      reverse: false,
                      separatorBuilder: (BuildContext context, int index) {
                        return Divider(
                          color: Colors.white,
                          height: 18.0,
                          indent: 0,
                        );
                      },
                      padding: EdgeInsets.all(8.0),
                      itemCount: this.chatMessages.length)),
              new Divider(height: 1.0),
              new Container(
                decoration:
                    new BoxDecoration(color: Theme.of(context).cardColor),
                child: _buildTextComposer(),
              ),
              new Builder(builder: (BuildContext context) {
                _scaffoldContext = context;
                return new Container(width: 0.0, height: 0.0);
              })
            ],
          ),
          decoration: Theme.of(context).platform == TargetPlatform.iOS
              ? new BoxDecoration(
                  border: new Border(
                      top: new BorderSide(
                  color: Colors.grey[200],
                )))
              : null,
        ));
  }

  CupertinoButton getIOSSendButton() {
    return new CupertinoButton(
      child: new Text("Send"),
      onPressed: _isComposingMessage
          ? () => _textMessageSubmitted(_textEditingController.text)
          : null,
    );
  }

  IconButton getDefaultSendButton() {
    return new IconButton(
      icon: new Icon(Icons.send),
      onPressed: _isComposingMessage
          ? () => _textMessageSubmitted(_textEditingController.text)
          : null,
    );
  }

  Widget _buildTextComposer() {
    return new IconTheme(
        data: new IconThemeData(
          color: _isComposingMessage
              ? Theme.of(context).accentColor
              : Theme.of(context).disabledColor,
        ),
        child: new Container(
          margin: const EdgeInsets.symmetric(horizontal: 8.0),
          child: new Row(
            children: <Widget>[
              //照片
              new Container(
                margin: new EdgeInsets.symmetric(horizontal: 4.0),
                child: new IconButton(
                    icon: new Icon(
                      Icons.photo_camera,
                      color: Theme.of(context).accentColor,
                    ),
                    onPressed: () async {
//                      await _ensureLoggedIn();
                      File imageFile = await ImagePicker.pickImage();
                      int timestamp = new DateTime.now().millisecondsSinceEpoch;
                      StorageReference storageReference = FirebaseStorage
                          .instance
                          .ref()
                          .child("img_" + timestamp.toString() + ".jpg");
                      StorageUploadTask uploadTask =
                          storageReference.put(imageFile);
                      uploadTask.events.listen((event) {
                        print('EVENT ${event.type}');
                      });
//                      Uri downloadUrl = (await uploadTask.onComplete).downloadUrl;
                      Uri downloadUrl = null;
//                      _sendMessage(
//                          messageText: null, imageUrl: downloadUrl.toString());
                    }),
              ),
              //文本
              new Flexible(
                child: new TextField(
                  controller: _textEditingController,
//                  keyboardType: TextInputType.text,
                  keyboardType: TextInputType.text,
                  onChanged: (String messageText) {
                    setState(() {
                      _isComposingMessage = messageText.length > 0;
                    });
                  },
                  onSubmitted: _textMessageSubmitted,
                  decoration:
                      new InputDecoration.collapsed(hintText: "Send a message"),
                ),
              ),
              //发送
              new Container(
                margin: const EdgeInsets.symmetric(horizontal: 4.0),
                child: Theme.of(context).platform == TargetPlatform.iOS
                    ? getIOSSendButton()
                    : getDefaultSendButton(),
              ),
            ],
          ),
        ));
  }

  Future<Null> _textMessageSubmitted(String text) async {
    _textEditingController.clear();
    //显示消息
    var chatMessage = new ChatMessage();
    chatMessage.isSender = true;
    chatMessage.time = currentTimeMillis();
    chatMessage.sendId = userId;
    chatMessage.sendName = username;
    chatMessage.sendAvatar = avatar;
    //接收人ID
    chatMessage.receiveId = _contactInfo.contactId;
    chatMessage.receiveName = _contactInfo.username;
    chatMessage.receiveAvatar = _contactInfo.avatar;

    chatMessage.messageType = MESSAGE_TYPE_TEXT;
    chatMessage.content = text;
    chatMessages.add(chatMessage);
    //保存数据到本地
    await saveChatMessage(chatMessage);
    scrollController.animateTo(
        scrollController.position.maxScrollExtent + 120, //滚动到底部
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut);
    setState(() {
      //重新渲染数据
      _isComposingMessage = false;
    });

//    await _ensureLoggedIn();
    _sendMessage(chatMessage, imageUrl: null);
  }

  void _sendMessage(ChatMessage message, {String imageUrl}) {
//    reference.push().set({
//      'text': messageText,
//      'email': googleSignIn.currentUser.email,
//      'imageUrl': imageUrl,
//      'senderName': googleSignIn.currentUser.displayName,
//      'senderPhotoUrl': googleSignIn.currentUser.photoUrl,
//    });

    //日志打印
    print('userId:' +
        message.sendId.toString() +
        ">receiveId:" +
        message.receiveId.toString() +
        "type:" +
        message.messageType.toString() +
        "content:" +
        message.content +
//                "url:" +
//                message.url ==
//            null
//        ? ""
//        : message.url +
        "time:" +
        new DateTime.fromMicrosecondsSinceEpoch(message.time).toString());
    //构造数据
    var chatMessage = {
      "id": 0,
      "time": message.time,
      "sendId": message.sendId,
      "receiveId": message.receiveId,
//      单聊
      "cmd": 1,
      "media": 1,
      "content": message.content
    };
    var chatMessageJson = jsonEncode(chatMessage);

    webSocketManager.sendMessage(chatMessageJson);

//    httpPost(url, body)
    //
  }

  Future<Void> saveChatMessage(ChatMessage chatMessage) async {
    appChatHistoryDao
        .insetIntoChatHistory(
            chatMessage.messageType,
            userId,
            chatMessage.receiveId,
            chatMessage.content,
            1,
            chatMessage.time,
            chatMessage.isSender)
        .then((int code) {
      if (code > 1) {
        print('聊天历史保存成功');
      }
    });
  }
}

///构造发送的信息
class EntryItem extends StatelessWidget {
  final ChatMessage message;

  const EntryItem(this.message);

  Widget row() {
    ///由自己发送，在右边显示
    if (message.isSender) {
      return new Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Flexible(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  new Container(
                    padding: EdgeInsets.only(top: 2, bottom: 2),
//                    color: Colors.lightGreen,
                    child: new Text(
                      message.content,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.black, fontSize: 16),
                    ),
                  )
                ]),
          ),
          new Container(
            margin: const EdgeInsets.only(left: 12.0, right: 12.0),
            child: new CircleAvatar(
              backgroundImage:
                  (message.sendAvatar == "" || message.sendAvatar == null)
                      ? AssetImage("images/timg.jpg")
                      : NetworkImage(message.sendAvatar),
              radius: 24.0,
            ),
          ),
        ],
      );
    } else {
      ///对方发送，左边显示
      return new Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          new Container(
            margin: const EdgeInsets.only(left: 12.0, right: 12.0),
            child: new CircleAvatar(
              backgroundImage:
                  (message.sendAvatar == "" || message.sendAvatar == null)
                      ? AssetImage("images/timg_orther.jpg")
                      : NetworkImage(message.sendAvatar),
              radius: 24.0,
            ),
          ),
          Flexible(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  new Container(
                    margin: const EdgeInsets.only(top: 5.0),
                    child: new Text(
                      message.content,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.black, fontSize: 16),
                    ),
                  )
                ]),
          ),
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return new Container(
      child: row(),
    );
  }
}

//消息监听
class ChatMessageListen extends WebSocketListen {
  ChatPageState _chatScreenState;
  bool isDisPose;

  ChatMessageListen(this._chatScreenState);

  @override
  void handle(String data) {
    try {
      TransferChatMessage chatMessage =
          TransferChatMessage.forMap(jsonDecode(data));
      //接受数据
      if (_chatScreenState._contactInfo.contactId == chatMessage.sendId &&
          chatMessage.receiveId == userId) {
        if (chatMessage.media == MESSAGE_TYPE_TEXT) {
          //文字
          ChatMessage message = new ChatMessage();

          message.isSender = false;
          message.time = chatMessage.time;
          message.sendId = userId;
          message.sendName = username;
          message.sendAvatar = avatar;
          //接收人ID
          //注意该是发送者的
          message.receiveId = chatMessage.sendId;
          message.receiveName = _chatScreenState._contactInfo.username;
          message.receiveAvatar = _chatScreenState._contactInfo.avatar;

          message.messageType = MESSAGE_TYPE_TEXT;
          message.content = chatMessage.content;

          _chatScreenState._msgList.add(message);

          //保存数据到本地
          _chatScreenState.saveChatMessage(message);
        } else if (chatMessage.media == MESSAGE_TYPE_IMAGE) {
        } else if (chatMessage.media == MESSAGE_TYPE_VOICE) {}
      }
      //保存聊天数据
      if (_chatScreenState.isDisPose == false) {
        _chatScreenState.setState(() {
          //重新渲染数据
          print('重新渲染数据');
          print(_chatScreenState._msgList.toString());
        });
      }
    } on Exception catch (e) {}
  }
}

/////////////////////////////////////////////////////////////

/// 聊天界面示例
class ChatPage extends StatefulWidget {
  ContactInfo _contactInfo;

  ChatPage(this._contactInfo);

  @override
  ChatPageState createState() {
    return ChatPageState(_contactInfo);
  }
}

class ChatPageState extends State<ChatPage> {
  ContactInfo _contactInfo;
  bool isDisPose = false;
  int start = 0;
  int size = 20;

  //显示文字
  bool isSendText = true;

  ChatPageState(this._contactInfo); // 信息列表
  List<ChatMessage> _msgList = new List();
  AppChatHistoryDao appChatHistoryDao = new AppChatHistoryDao();

  // 输入框
  TextEditingController _textEditingController;

  // 滚动控制器
  ScrollController _scrollController;

  int defaultChatCount = 20;

  Future<Void> saveChatMessage(ChatMessage chatMessage) async {
    appChatHistoryDao
        .insetIntoChatHistory(
            chatMessage.messageType,
            userId,
            chatMessage.receiveId,
            chatMessage.content,
            1,
            chatMessage.time,
            chatMessage.isSender)
        .then((int code) {
      if (code > 1) {
        print('聊天历史保存成功');
      }
    });
  }

  void initChatHistoryMessage(int start, int size) {
    print('记录的开始:' + start.toString() + ":" + size.toString());
    appChatHistoryDao
        .queryChatHistory(_contactInfo.contactId, start: start, size: size)
        .then((List<Map<String, dynamic>> data) {
//      if (_msgList.length > 0) {
//        _msgList.clear();
//      }
      for (var line in data) {
        var chatMessage = new ChatMessage();
        chatMessage.receiveId = line['receive_id'];
        chatMessage.sendId = userId;
        chatMessage.id = line['id'];
        chatMessage.messageType = line['media'];
        chatMessage.time = line['time'];
        chatMessage.url = line['url'];
        chatMessage.sendName = username;
        chatMessage.sendAvatar = avatar;
        chatMessage.receiveName = _contactInfo.username;
        chatMessage.receiveAvatar = _contactInfo.avatar;
        if (line['is_sender'] == 1) {
          chatMessage.isSender = true;
        } else if (line['is_sender'] == 0) {
          chatMessage.isSender = false;
        }
        chatMessage.speechLength = line['voice_len'];
        chatMessage.content = line['content'];
        _msgList.add(chatMessage);
      }
      //
//      _scrollController.animateTo(
//          _scrollController.position.maxScrollExtent + 120, //滚动到底部
//          duration: const Duration(milliseconds: 300),
//          curve: Curves.easeOut);
      setState(() {
        print('刷新聊天记录');
      });
    });
  }

  @override
  void initState() {
    super.initState();
    isDisPose = false;
    webSocketManager.addDataListen(new ChatMessageListen(this));
    _msgList.clear();
    initChatHistoryMessage(start, size);

    _textEditingController = TextEditingController();
    _textEditingController.addListener(() {
      setState(() {});
    });
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    super.dispose();
    isDisPose = true;
    _textEditingController.dispose();
    _scrollController.dispose();
  }

  void _sendMessage(ChatMessage message, {String imageUrl}) {
//    reference.push().set({
//      'text': messageText,
//      'email': googleSignIn.currentUser.email,
//      'imageUrl': imageUrl,
//      'senderName': googleSignIn.currentUser.displayName,
//      'senderPhotoUrl': googleSignIn.currentUser.photoUrl,
//    });

    //日志打印
    print('userId:' +
        message.sendId.toString() +
        ">receiveId:" +
        message.receiveId.toString() +
        "type:" +
        message.messageType.toString() +
        "content:" +
        message.content +
//                "url:" +
//                message.url ==
//            null
//        ? ""
//        : message.url +
        "time:" +
        new DateTime.fromMicrosecondsSinceEpoch(message.time).toString());
    //构造数据
    var chatMessage = {
      "id": 0,
      "time": message.time,
      "sendId": message.sendId,
      "receiveId": message.receiveId,
//      单聊
      "cmd": 1,
      "media": 1,
      "content": message.content
    };
    var chatMessageJson = jsonEncode(chatMessage);

    webSocketManager.sendMessage(chatMessageJson);

//    httpPost(url, body)
    //
  }

  // 发送消息
  void _sendMsg(String msg) async {
    _textEditingController.clear();
    //显示消息
    var chatMessage = new ChatMessage();
    chatMessage.isSender = true;
    chatMessage.time = currentTimeMillis();
    chatMessage.sendId = userId;
    chatMessage.sendName = username;
    chatMessage.sendAvatar = avatar;
    //接收人ID
    chatMessage.receiveId = _contactInfo.contactId;
    chatMessage.receiveName = _contactInfo.username;
    chatMessage.receiveAvatar = _contactInfo.avatar;

    chatMessage.messageType = MESSAGE_TYPE_TEXT;
    chatMessage.content = msg;
    _msgList.insert(_msgList.length, chatMessage);
    //保存数据到本地
    await saveChatMessage(chatMessage);
    _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 120, //滚动到底部
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut);

    _sendMessage(chatMessage, imageUrl: null);
    setState(() {
//      _isComposingMessage = false;
    });
    _scrollController.animateTo(0.0,
        duration: Duration(milliseconds: 300), curve: Curves.linear);
  }

  @override
  Widget build(BuildContext context) {
    isDisPose = false;
    return Scaffold(
      appBar: AppBar(
        title: Text(_contactInfo.username ?? ""),
        centerTitle: false,
        backgroundColor: Colors.green,
        elevation: 0.0,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.more_horiz),
            onPressed: () {
              _contactInfo.isShowSendBtu = false;
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) {
                    return FriendInfoPage(_contactInfo);
                  },
                ),
              );
            },
          ),
        ],
      ),
      backgroundColor: Colors.grey[200],
      body: Column(
        children: <Widget>[
          Divider(
            height: 0.5,
          ),
          Expanded(
            flex: 1,
            child: LayoutBuilder(
              builder: (context, constraints) {
                // 判断列表内容是否大于展示区域
                bool overflow = false;
                double heightTmp = 0.0;
                for (ChatMessage entity in _msgList) {
                  heightTmp +=
                      _calculateMsgHeight(context, constraints, entity);
                  if (heightTmp > constraints.maxHeight) {
                    overflow = true;
                  }
                }
                return EasyRefresh.custom(
                  scrollController: _scrollController,
                  reverse: true,
                  footer: CustomFooter(
                      enableInfiniteLoad: false,
                      extent: 40.0,
                      triggerDistance: 50.0,
                      footerBuilder: (context,
                          loadState,
                          pulledExtent,
                          loadTriggerPullDistance,
                          loadIndicatorExtent,
                          axisDirection,
                          float,
                          completeDuration,
                          enableInfiniteLoad,
                          success,
                          noMore) {
                        return Stack(
                          children: <Widget>[
                            Positioned(
                              bottom: 0.0,
                              left: 0.0,
                              right: 0.0,
                              child: Container(
                                width: 30.0,
                                height: 30.0,
                                child: SpinKitCircle(
                                  color: Colors.green,
                                  size: 30.0,
                                ),
                              ),
                            ),
                          ],
                        );
                      }),
                  slivers: <Widget>[
                    if (overflow)
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            return _buildMsg(_msgList[index]);
                          },
                          childCount: _msgList.length,
                        ),
                      ),
                    if (!overflow)
                      SliverToBoxAdapter(
                        child: Container(
                          height: constraints.maxHeight,
                          width: double.infinity,
                          child: Column(
                            children: <Widget>[
                              for (ChatMessage entity in _msgList.reversed)
                                _buildMsg(entity),
                            ],
                          ),
                        ),
                      ),
                  ],
                  onLoad: () async {
                    start = start + size;
                    initChatHistoryMessage(start, size);
//                    await Future.delayed(Duration(seconds: 2), () {
//                      //
//                      start = start+size;
//
//                      if (mounted) {
//                        setState(() {
////                          _msgList.addAll([
////                            MessageEntity(true, "It's good!"),
////                            MessageEntity(false, 'EasyRefresh'),
////                          ]);
//                          print('继续加载');
//                        });
//                      }
//                    });
                  },
                );
              },
            ),
          ),
          SafeArea(
            child: Container(
              color: Colors.grey[100],
              padding: EdgeInsets.only(
                left: 10.0,
                right: 10.0,
                top: 10.0,
                bottom: 10.0,
              ),
              child: Row(
                children: <Widget>[
                  (isSendText)
                      ? InkWell(
                          onTap: () {
                            setState(() {
                              isSendText = false;
                            });
                          },
                          child: Container(
                            height: 30.0,
                            width: 40.0,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.all(Radius.circular(
                                4.0,
                              )),
                            ),
                            child: Image.asset("images/record.png"),
                          ),
                        )
                      : InkWell(
                          onTap: () {
                            setState(() {
                              isSendText = true;
                            });
                          },
                          child: Container(
                            height: 30.0,
                            width: 40.0,
                            alignment: Alignment.center,
//                            margin: EdgeInsets.only(
//                              left: 15.0,
//                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.all(Radius.circular(
                                4.0,
                              )),
                            ),
                            child: Image.asset("images/key.png"),
                          ),
                        ),
                  (isSendText)
                      ? Expanded(
                          flex: 1,
                          child: Container(
//                            margin: EdgeInsets.only(left: 15),
                            padding: EdgeInsets.only(
                              left: 5.0,
                              right: 5.0,
                              top: 14.0,
                              bottom: 14.0,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.all(Radius.circular(
                                4.0,
                              )),
                            ),
                            child: TextField(
                              controller: _textEditingController,
                              decoration: null,
                              onSubmitted: (value) {
                                if (_textEditingController.text.isNotEmpty) {
                                  _sendMsg(_textEditingController.text);
                                  _textEditingController.text = '';
                                }
                              },
                            ),
                          ),
                        )
                      : Expanded(
                          flex: 1,
                          child: VoiceWidget(),
                        ),
                  InkWell(
                    onTap: () {
                      if (_textEditingController.text.isNotEmpty) {
                        _sendMsg(_textEditingController.text);

                        _textEditingController.text = '';
                      }
                    },
                    child: Container(
                      height: 30.0,
                      width: 60.0,
                      alignment: Alignment.center,
                      margin: EdgeInsets.only(
                        left: 15.0,
                      ),
                      decoration: BoxDecoration(
                        color: _textEditingController.text.isEmpty
                            ? Colors.grey
                            : Colors.green,
                        borderRadius: BorderRadius.all(Radius.circular(
                          4.0,
                        )),
                      ),
                      child: Text(
                        "发送",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.0,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 构建消息视图
  Widget _buildMsg(ChatMessage entity) {
    if (entity == null || entity.isSender == null) {
      return Container();
    }
    if (entity.isSender) {
      return Container(
        margin: EdgeInsets.all(
          10.0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Text(
                  entity.sendName ?? "",
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 13.0,
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(
                    top: 5.0,
                  ),
                  padding: EdgeInsets.all(10.0),
                  decoration: BoxDecoration(
                    color: Colors.lightGreen,
                    borderRadius: BorderRadius.all(Radius.circular(
                      4.0,
                    )),
                  ),
                  constraints: BoxConstraints(
                    maxWidth: 200.0,
                  ),
                  child: Text(
                    entity.content ?? '',
                    overflow: TextOverflow.clip,
                    style: TextStyle(
                      fontSize: 16.0,
                    ),
                  ),
                )
              ],
            ),
            Card(
              margin: EdgeInsets.only(
                left: 10.0,
              ),
              clipBehavior: Clip.hardEdge,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20.0)),
              ),
              elevation: 0.0,
              child: Container(
                height: 40.0,
                width: 40.0,
                child: (entity.sendAvatar == null || entity.sendAvatar == "")
                    ? Image.asset('images/timg.jpg')
                    : Image.network(entity.sendAvatar),
              ),
            ),
          ],
        ),
      );
    } else {
      return Container(
        margin: EdgeInsets.all(
          10.0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Card(
              margin: EdgeInsets.only(
                right: 10.0,
              ),
              clipBehavior: Clip.hardEdge,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20.0)),
              ),
              elevation: 0.0,
              child: Container(
                height: 40.0,
                width: 40.0,
                child:
                    (entity.receiveAvatar == null || entity.receiveAvatar == "")
                        ? Image.asset('images/timg.jpg')
                        : Image.network(entity.receiveAvatar),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  entity.receiveName,
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 13.0,
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(
                    top: 5.0,
                  ),
                  padding: EdgeInsets.all(10.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(
                      4.0,
                    )),
                  ),
                  constraints: BoxConstraints(
                    maxWidth: 200.0,
                  ),
                  child: Text(
                    entity.content ?? '',
                    overflow: TextOverflow.clip,
                    style: TextStyle(
                      fontSize: 16.0,
                    ),
                  ),
                )
              ],
            ),
          ],
        ),
      );
    }
  }

  // 计算内容的高度
  double _calculateMsgHeight(
      BuildContext context, BoxConstraints constraints, ChatMessage entity) {
    return 45.0 +
        _calculateTextHeight(
          context,
          constraints,
          text: entity.sendName,
          textStyle: TextStyle(
            fontSize: 13.0,
          ),
        ) +
        _calculateTextHeight(
          context,
          constraints.copyWith(
            maxWidth: 200.0,
          ),
          text: entity.content ?? '',
          textStyle: TextStyle(
            fontSize: 16.0,
          ),
        );
  }

  /// 计算Text的高度
  double _calculateTextHeight(
    BuildContext context,
    BoxConstraints constraints, {
    String text = '',
    @required TextStyle textStyle,
    List<InlineSpan> children = const [],
  }) {
    final span = TextSpan(text: text, style: textStyle, children: children);

    final richTextWidget = Text.rich(span).build(context) as RichText;
    final renderObject = richTextWidget.createRenderObject(context);
    renderObject.layout(constraints);
    return renderObject.computeMinIntrinsicHeight(constraints.maxWidth);
  }
}

/// 信息实体
class MessageEntity {
  bool own;
  String msg;

  MessageEntity(this.own, this.msg);
}
