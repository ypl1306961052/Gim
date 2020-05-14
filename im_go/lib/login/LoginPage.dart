import 'dart:async';
import 'dart:convert';

import 'package:flui/flui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:im_go/util/Dialog.dart';

import '../Home.dart';
import '../main.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  //焦点
  FocusNode _focusNodeUserName = new FocusNode();
  FocusNode _focusNodePassWord = new FocusNode();

  //用户名输入框控制器，此控制器可以监听用户名输入框操作
  TextEditingController _userNameController = new TextEditingController();

  //表单状态
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  var _password = ''; //用户名
  var _username = ''; //密码
  var _isShowPwd = false; //是否显示密码
  var _isShowClear = false; //是否显示输入框尾部的清除按钮
  BuildContext _context;

  @override
  void initState() {
    // TODO: implement initState
    //设置焦点监听
    _focusNodeUserName.addListener(_focusNodeListener);
    _focusNodePassWord.addListener(_focusNodeListener);
    //监听用户名框的输入改变
    _userNameController.addListener(() {
      print(_userNameController.text);

      // 监听文本框输入变化，当有内容的时候，显示尾部清除按钮，否则不显示
      if (_userNameController.text.length > 0) {
        _isShowClear = true;
      } else {
        _isShowClear = false;
      }

      setState(() {});
    });
    Timer(Duration(milliseconds: 1000), () {
      print('加载用户名字');
      if (mobile != "") {
        _username = mobile;
        print('加载用户名字:' + mobile);
      }
      setState(() {});
    });
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    // 移除焦点监听
    _focusNodeUserName.removeListener(_focusNodeListener);
    _focusNodePassWord.removeListener(_focusNodeListener);
    _userNameController.dispose();
    super.dispose();
  }

  // 监听焦点
  Future<Null> _focusNodeListener() async {
    if (_focusNodeUserName.hasFocus) {
      print("用户名框获取焦点");
      // 取消密码框的焦点状态
      _focusNodePassWord.unfocus();
    }
    if (_focusNodePassWord.hasFocus) {
      print("密码框获取焦点");
      // 取消用户名框焦点状态
      _focusNodeUserName.unfocus();
    }
  }

  /**
   * 验证用户名
   */
  String validateUserName(value) {
    // 正则匹配手机号
    RegExp exp = RegExp(
        r'^((13[0-9])|(14[0-9])|(15[0-9])|(16[0-9])|(17[0-9])|(18[0-9])|(19[0-9]))\d{8}$');
    if (value.isEmpty) {
      return '用户名不能为空!';
    } else if (!exp.hasMatch(value)) {
      return '请输入正确手机号';
    }
    return null;
  }

  /**
   * 验证密码
   */
  String validatePassWord(value) {
    if (value.isEmpty) {
      return '密码不能为空';
    } else if (value.trim().length < 6 || value.trim().length > 18) {
      return '密码长度不正确';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
//    ScreenUtil.instance = ScreenUtil(width:750,height:1334)..init(context);
    ScreenUtil.init(context, width: 750, height: 1334);
    print(ScreenUtil().scaleHeight);
    _context = context;

    // logo 图片区域
    Widget logoImageArea = new Container(
      alignment: Alignment.topCenter,
      // 设置图片为圆形
      child: ClipOval(
        child: Image.asset(
          "images/logo.gif",
          height: 180,
          width: 180,
          fit: BoxFit.cover,
        ),
      ),
    );

    //输入文本框区域
    Widget inputTextArea = new Container(
      margin: EdgeInsets.only(left: 20, right: 20),
      decoration: new BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          color: Colors.white),
      child: new Form(
        key: _formKey,
        child: new Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            new TextFormField(
              controller: _userNameController,
              focusNode: _focusNodeUserName,
              //设置键盘类型

              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "用户名",
                hintText: "请输入手机号",
                prefixIcon: Icon(Icons.person),
                //尾部添加清除按钮
                suffixIcon: (_isShowClear)
                    ? IconButton(
                        icon: Icon(Icons.clear),
                        onPressed: () {
                          // 清空输入框内容
                          _userNameController.clear();
                        },
                      )
                    : null,
              ),
              //验证用户名
              validator: validateUserName,
              //保存数据
              onSaved: (String value) {
                _username = value;
              },
            ),
            new TextFormField(
              focusNode: _focusNodePassWord,
              decoration: InputDecoration(
                  labelText: "密码",
                  hintText: "请输入密码",
                  prefixIcon: Icon(Icons.lock),
                  // 是否显示密码
                  suffixIcon: IconButton(
                    icon: Icon(
                        (_isShowPwd) ? Icons.visibility : Icons.visibility_off),
                    // 点击改变显示或隐藏密码
                    onPressed: () {
                      setState(() {
                        _isShowPwd = !_isShowPwd;
                      });
                    },
                  )),
              obscureText: !_isShowPwd,
              //密码验证
              validator: validatePassWord,
              //保存数据
              onSaved: (String value) {
                _password = value;
              },
            )
          ],
        ),
      ),
    );
    bool _loading=false;
    // 登录按钮区域
    Widget loginButtonArea = new Container(
      margin: EdgeInsets.only(left: 20, right: 20),
      height: 45.0,
      child: FLLoadingButton(
          child: Text('Login'),
          color: Colors.green,
          disabledColor: Colors.green,
          indicatorColor: Colors.white,
          textColor: Colors.white,
          loading: _loading,
          minWidth: 200,
          indicatorOnly: true,
          onPressed: () {
            setState(() => _loading = true);
            loginPressed(_loading);
//            Future.delayed(
//                Duration(seconds: 3), () => setState(() => ));
          }),
//      child: new RaisedButton(
//        color: Colors.blue[300],
//        child: Text(
//          "登录",
//          style: Theme.of(context).primaryTextTheme.headline,
//        ),
//        // 设置按钮圆角
//        shape:
//            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
//        onPressed: loginPressed,
//      ),
    );

    //第三方登录区域
    Widget thirdLoginArea = new Container(
      margin: EdgeInsets.only(left: 20, right: 20),
      child: new Column(
        children: <Widget>[
          new Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Container(
                width: 80,
                height: 1.0,
                color: Colors.grey,
              ),
              Text('第三方登录'),
              Container(
                width: 80,
                height: 1.0,
                color: Colors.grey,
              ),
            ],
          ),
          new SizedBox(
            height: 18,
          ),
          new Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              IconButton(
                color: Colors.green[200],
                // 第三方库icon图标
                icon: Icon(FontAwesomeIcons.weixin),
                iconSize: 40.0,
                onPressed: () {},
              ),
              IconButton(
                color: Colors.green[200],
                icon: Icon(FontAwesomeIcons.facebook),
                iconSize: 40.0,
                onPressed: () {},
              ),
              IconButton(
                color: Colors.green[200],
                icon: Icon(FontAwesomeIcons.qq),
                iconSize: 40.0,
                onPressed: () {},
              )
            ],
          )
        ],
      ),
    );

    //忘记密码  立即注册
    Widget bottomArea = new Container(
      margin: EdgeInsets.only(right: 20, left: 30),
      child: new Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          FlatButton(
            child: Text(
              "忘记密码?",
              style: TextStyle(
                color: Colors.blue[400],
                fontSize: 16.0,
              ),
            ),
            //忘记密码按钮，点击执行事件
            onPressed: () {},
          ),
          FlatButton(
            child: Text(
              "快速注册",
              style: TextStyle(
                color: Colors.blue[400],
                fontSize: 16.0,
              ),
            ),
            //点击快速注册、执行事件
            onPressed: () {},
          )
        ],
      ),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      // 外层添加一个手势，用于点击空白部分，回收键盘
      body: new GestureDetector(
        onTap: () {
          // 点击空白区域，回收键盘
          print("点击了空白区域");
          _focusNodePassWord.unfocus();
          _focusNodeUserName.unfocus();
        },
        child: new ListView(
          children: <Widget>[
            new SizedBox(
              height: ScreenUtil().setHeight(80),
            ),
            logoImageArea,
            new SizedBox(
              height: ScreenUtil().setHeight(70),
            ),
            inputTextArea,
            new SizedBox(
              height: ScreenUtil().setHeight(80),
            ),
            loginButtonArea,
            new SizedBox(
              height: ScreenUtil().setHeight(60),
            ),
            thirdLoginArea,
            new SizedBox(
              height: ScreenUtil().setHeight(60),
            ),
            bottomArea,
          ],
        ),
      ),
    );
  }

//登录
  loginPressed(bool loading) async {
    //点击登录按钮，解除焦点，回收键盘
    _focusNodePassWord.unfocus();
    _focusNodeUserName.unfocus();

    if (_formKey.currentState.validate()) {
      //只有输入通过验证，才会执行这里
      _formKey.currentState.save();
      //todo 登录操作
      print("$_username + $_password");
      var url = host + loginPath;
      var response = await http.post(url,
          body: {'mobile': _username, 'password': _password}, encoding: utf8);
      if (response.statusCode == 200 || response.statusCode == 204) {
        print('请求登录');
        var resultObject = jsonDecode(response.body);
        if (resultObject['code'] == 0) {
          //登录成功
          //保存 id 以及 token 到 sql
          var id = resultObject['data']['Id'];
          var _token = resultObject['data']['Token'];
          var mobile = resultObject['data']['Mobile'];
          var avatar = resultObject['data']['Avatar'];
          var sex = resultObject['data']['Sex'];
          var username = resultObject['data']['NickName'];
          userId = id;
          token = _token;
          saveIdAndToken(id, _token, mobile, avatar, sex, username);
          initTokenAndWebSocket();
//          Navigator.of(context).pop(context);
//          Navigator.pushAndRemoveUntil(context,  new PageRouteBuilder(
//            transitionDuration: const Duration(milliseconds: 500),
//            pageBuilder: (context, _, __) => new MyHomePage(),
//            transitionsBuilder:
//                (_, Animation<double> animation, __, Widget child) =>
//            new FadeTransition(
//              opacity: animation,
//              child: child,
////                  child: new RotationTransition(
////                    turns: new Tween<double>(begin: 0.0, end: 1.0)
////                        .animate(animation),
////                    child: child,
////                  ),
//            ),
//          ), null);
          Navigator.of(context).pushReplacement(new PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 500),
            pageBuilder: (context, _, __) => new MyHomePage(),
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
        } else {
          //登录失败
          //弹出失败的原因
          var msg = resultObject['msg'];
          print(msg);
          showAlertDialog(_context, desc: msg);
        }
      } else {}
      loading = false;
    }
  }

  void saveIdAndToken(id, token, mobile, avatar, sex, username) {
    saveToken(id, token, mobile, avatar, sex, username).then((bool) {
      if (bool) {
        print('保存token成功');
      } else {
        print('保存token失败');
      }
    });
  }
}
