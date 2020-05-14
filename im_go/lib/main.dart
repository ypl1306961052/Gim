import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:im_go/util/sqlfile.dart';
import 'package:im_go/util/time.dart';
import 'package:im_go/util/websocket.dart';
import 'package:path_provider/path_provider.dart';

import 'Home.dart';
import 'login/LoginPage.dart';
import 'package:http/http.dart' as http;

//void main() => runApp(MyApp());
String host = "http://192.168.0.111:8080";
String loginPath = "/user/login";
String loadFriend = "/user/loadFriend";
String addFriend = "/user/addFriend";
String userInfo = "/user/info";
String webSocketHost = "ws://192.168.0.111:8080/user/chat";
int userId = 0;
String token = "";
int lastLoginTime = -1;
String username = "";
String avatar = "";
String mobile = "";
//token失效为30天
int tokenInvalid = 30;
WebSocketManager webSocketManager;

void main() {
  runApp(new MaterialApp(
    title: 'IM',
    theme: new ThemeData(
        brightness: Brightness.light,
        backgroundColor: Colors.white,
        platform: TargetPlatform.iOS),
    home: new SplashScreen(),
    routes: <String, WidgetBuilder>{
      '/home': (BuildContext context) => new MyHomePage()
    },
  ));
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => new _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  startTime() async {
    //设置启动图生效时间
    var _duration = new Duration(seconds: 1);
    return new Timer(_duration, navigationPage);
  }

  void navigationPage() {
    if (token != "" && token != null) {
      print('进入主页');
      Navigator.of(context).pushReplacementNamed('/home');
    } else {
      print('进入登录页');
      Navigator.of(context).pushReplacement(
          new MaterialPageRoute(builder: (BuildContext context) {
        return LoginPage();
      }));
    }
  }

  @override
  void initState() {
    super.initState();
    //初始化contactdb
    _readToken().then((TokenInfo tokenInfo) {
      //int userId = 0;
      //String token = "";
      //int lastLoginTime = -1;
      //String username = "";
      //String avatar = "";
      //String mobile = "";
      if (tokenInfo != null) {
        userId = tokenInfo.id;
        token = tokenInfo.token;
        lastLoginTime = tokenInfo.time;
        username = tokenInfo.username;
        avatar = tokenInfo.avatar;
        mobile = tokenInfo.mobile;
        print('初始化token成功');
        print('token:' + token + "id:" + userId.toString() + "mobile" + mobile);
      } else {
        print('初始化token失败,tokenInfo 为空');
      }
    });
    initContactDb();
    initTokenAndWebSocket();
    startTime();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: new Center(
        child: new Image.asset(
          'images/logo.gif',
        ),
      ),
    );
  }
}

class HomeView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Center(
      child: Image(
        image: new AssetImage("images/homeview.jpeg"),
      ),
    );
  }
}

void initTokenAndWebSocket() {
  print('初始化token');
  _readToken().then((TokenInfo tokenInfo) {
    if (tokenInfo == null) {
      print('token为空');
    } else {
      if (tokenInfo.id != 0 &&
          tokenInfo.token != null &&
          tokenInfo.token != "") {
        //初始化 个人信息
        username = tokenInfo.username;
        userId = tokenInfo.id;
        avatar = tokenInfo.avatar;
        mobile = tokenInfo.mobile;
        webSocketManager = WebSocketManager();
        webSocketManager.initWebSocket();
        print('token:' + token + "username:" + username + "mobile:" + mobile);
        print('初始化token成功');
      } else {
        print('初始化token失败');
      }
    }
  });
}

Future<TokenInfo> _readToken() async {
  File file = await _getLocalTokenFile();
  var content = file.readAsStringSync();
  if (content == null || "" == content) {
    return null;
  }
  var tokenJson = jsonDecode(content);
  var tokenInfo = new TokenInfo();
  tokenInfo.id = tokenJson['id'];
  tokenInfo.token = tokenJson['token'];
  tokenInfo.time = tokenJson['time'];
  tokenInfo.avatar = tokenJson['avatar'];
  tokenInfo.mobile = tokenJson['mobile'];
  tokenInfo.sex = tokenJson['sex'];
  tokenInfo.username = tokenJson['username'];
  return tokenInfo;
}

Future<File> _getLocalTokenFile() async {
  String dir = (await getApplicationDocumentsDirectory()).path;
  File file = new File('$dir/token.txt');
  if (!file.existsSync()) {
    file.createSync(recursive: true);
  }
  return file;
}

//保存token
Future<bool> saveToken(
    int id, String token, mobile, avatar, sex, username) async {
  try {
    File file = await _getLocalTokenFile();
    var tokenInfo = new TokenInfo();
    tokenInfo.id = id;
    tokenInfo.token = token;
    tokenInfo.avatar = avatar;
    tokenInfo.mobile = mobile;
    tokenInfo.sex = sex;
    tokenInfo.username = username;
    tokenInfo.time = currentTimeMillis();
    var tokenStr = jsonEncode(tokenInfo);
    file.writeAsStringSync(tokenStr,
        flush: true, encoding: utf8, mode: FileMode.writeOnly);
    return true;
  } on Exception catch (e) {
    print(e.toString());
    return false;
  }
}

class TokenInfo {
  int id;
  String token;
  int time;
  String username;
  String avatar;
  String sex;
  String mobile;
  String desc;

  static TokenInfo fromMap(Map<String, dynamic> map) {
    TokenInfo tokenInfo = new TokenInfo();
    tokenInfo.id = map['id'];
    tokenInfo.token = map['token'];
    tokenInfo.time = map['time'];
    tokenInfo.mobile = map['mobile'];
    tokenInfo.username = map['username'];
    tokenInfo.desc = map['desc'];
    return tokenInfo;
  }

  Map toJson() {
    Map map = new Map();
    map["id"] = this.id;
    map["token"] = this.token;
    map["time"] = this.time;
    map["username"] = this.username;
    map["avatar"] = this.avatar;
    map["sex"] = this.sex;
    map["mobile"] = this.mobile;
    return map;
  }
}
