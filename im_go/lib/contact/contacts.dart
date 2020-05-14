import 'dart:convert';

import 'package:flui/flui.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:im_go/contact/addFriend.dart';
import 'package:im_go/info/FriendInfo.dart';
import 'package:im_go/util/HttpClient.dart';
import 'package:im_go/util/sqlfile.dart';

import '../main.dart';

const INDEX_WORDS = [
  '🔍',
  '☆',
  'A',
  'B',
  'C',
  'D',
  'E',
  'F',
  'G',
  'H',
  'I',
  'J',
  'K',
  'L',
  'M',
  'N',
  'O',
  'P',
  'Q',
  'R',
  'S',
  'T',
  'U',
  'V',
  'W',
  'X',
  'Y',
  'Z'
];
//好友界面
var WechatThemeColor = Colors.green;

class ContactsView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return ContactsViewStateful();
  }
}

class ContactsViewStateful extends State<ContactsView> {
  @override
  void initState() {
    super.initState();
    initFriendData();
//    loadData();
  }

  void initFriendData() {
    var body = {'ownerId': userId.toString()};
    //需要使用接口判断用户是否添加了新的好友

    httpPost(addToken(host + loadFriend), body).then((Response response) {
      //渲染数据
      //保存数据 to sql中以便后面的用户
      if (response.statusCode == 200) {
        var dataJson = jsonDecode(response.body);
        print(dataJson);
        //清楚之前的数据
        _ListDatas.clear();
//        header_datas.clear();
//        for (var i = 0; i < 4; i++) {
//          var contactInfo = new ContactInfo();
//          contactInfo.indexLetter = i;
//          contactInfo.username = "好友";
//          header_datas.add(contactInfo);
//        }

        if (dataJson['code'] == 1) {
          var datas = dataJson['data'];
          var index = header_datas.length;
          for (var line in datas) {
            var contact = ContactInfo.fromMap(line);
            contact.indexLetter = index;
            _ListDatas.add(contact);
            index++;
          }
          //重新渲染数据
          saveContact(_ListDatas);
          setState(() {
            itemCount = _ListDatas.length;
          });
        } else {}
      } else {
        print('加载数据失败');
      }
    });
  }

  int itemCount = 0;
  List<ContactInfo> _ListDatas = new List();
  List<ContactInfo> header_datas = new List();

//  List<CityInfo> _cityList = List();
//  List<CityInfo> _hotCityList = List();
//
//  int _suspensionHeight = 40;
//  int _itemHeight = 50;
//  String _suspensionTag = "";
  Widget _CellForRow(BuildContext context, int index) {
//    //前4个分组为微信固定的 新的朋友，群聊，标签，公众号4个cell
//    if (index < header_datas.length) {
//      return _FriendsCell(
//        assertImage: header_datas[index].avatar,
//        name: header_datas[index].username,
//      );
//    }
//
//    // 当indexLetter值相同的时候，创建cell，使用_FriendsCell方法不传入groupTitle值，使得当前cell不展示头部；
//    if (index > 4 &&
//        _ListDatas[index - 4].indexLetter ==
//            _ListDatas[index - 5].indexLetter) {
//      return _FriendsCell(
//        assertImage: _ListDatas[index - 4].avatar,
//        name: _ListDatas[index - 4].username,
//      );
//    }
//
//    // 当indexLetter值不相同的时候，创建cell，使用_FriendsCell方法传入groupTitle值，使得当前cell展示头部；

    return _FriendsCell(
      assertImage: _ListDatas[index].avatar,
      name: _ListDatas[index].username,
    );
  }

  ScrollController _scrollController = ScrollController();
  final Map _groupMap = {
    INDEX_WORDS[0]: 0.0,
    INDEX_WORDS[1]: 0.0,
  };

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
//      body: new ListView.separated(
//          itemBuilder: (BuildContext context, int index) {
//            return Container(
//              child: Row(
//                children: <Widget>[
//                  Column(
//                    children: <Widget>[
//                      new Text('id:' +
//                          _contactList[index].contactId.toString() +
//                          'username: ' +
//                          _contactList[index].username),
//                    ],
//                  ),
//                ],
//              ),
//            );
//          },
//          separatorBuilder: (BuildContext context, int index) {
//            return new Container(height: 1);
//          },
//          itemCount: itemCount),
        appBar: AppBar(
          backgroundColor: WechatThemeColor,
          centerTitle: true,
          title: Text('通讯录'),
          //标题
          leading: //左按钮
              GestureDetector(
            onTap: () {
//          Navigator.of(context)
//              .push(MaterialPageRoute(builder: (BuildContext context) {
//            return SubDiscover_Page(
//              title: '添加好友',
//            );
//          }));
            },
          ),
          actions: <Widget>[
            //右按钮
            GestureDetector(
              child: Container(
                margin: EdgeInsets.only(right: 15),
                child: Image(
                  image: AssetImage('icons/heart/add_user.png'),
                  width: 25,
                ),
              ),
              onTap: () {
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (BuildContext context) {
                  return AddFriendPage();
                }));
              },
            ),
          ],
        ),
        body: Stack(
          children: <Widget>[
            Container(
              child: ListView.separated(
                controller: _scrollController, //传入已经创建好的ScrollController实例化对象
//                itemCount: _ListDatas.length + header_datas.length,
                itemCount: _ListDatas.length,

                itemBuilder: (BuildContext context, int index) {
                  return ListTile(
                    onTap: () {
                      var data = _ListDatas[index];
                      //保存数据
                      //聊天历史记录
                      //userId
                      //receiveId
                      //

                      Navigator.push(
                          context,
                          new PageRouteBuilder(
                            transitionDuration:
                                const Duration(milliseconds: 500),
                            pageBuilder: (context, _, __) => new FriendInfoPage(_ListDatas[index]),
                            transitionsBuilder: (_, Animation<double> animation,
                                    __, Widget child) =>
                                new FadeTransition(
                              opacity: animation,
                              child: child,

                            ),
                          ));
                    },
                    leading: FLAvatar(
                      image:(_ListDatas[index].avatar == null ||
                          _ListDatas[index].avatar == "")
                          ? Image.asset("images/timg_orther.jpg")
                          : Image.network(_ListDatas[index].avatar),
                      width: 50,
                      height: 50,
                      radius: 40, // if not specify, will be width / 2
                    ),
//                    leading: Container(
//                      height: 45,
//                      width: 45,
//                      decoration: BoxDecoration(
//                          borderRadius: BorderRadius.circular(8),
//                          image: DecorationImage(
//                              fit: BoxFit.fitHeight,
//                              image: (_ListDatas[index].avatar == null ||
//                                      _ListDatas[index].avatar == "")
//                                  ? AssetImage("images/timg.jpg")
//                                  : NetworkImage(_ListDatas[index].avatar))),
//                    ),
                    title: Text(_ListDatas[index].username +
                        "(" +
                        _ListDatas[index].contactId.toString() +
                        ")"),
                  );
                },
                separatorBuilder: (BuildContext context, int index) {
                  return Divider(
                    color: Colors.black38,
                  );
                },
              ),
            ), //通讯录列表

//            IndexBar(
//              indexBarCallBack: (String string) {
//                print(_groupMap[string]);
//                if (_groupMap[string] != null) {
//                  _scrollController.animateTo(_groupMap[string],
//                      duration: Duration(milliseconds: 100),
//                      curve: Curves.easeIn);
//                }
//              },
//            ),
          ],
        ));
  }

  Widget _FriendsCell({assertImage, name, groupTitle}) {
    return ListTile(
//      leading: Container(
//        height: 45,
//        width: 45,
//        decoration: BoxDecoration(
//            borderRadius: BorderRadius.circular(8),
//            image: DecorationImage(
//                fit: BoxFit.fitHeight,
//                image: AssetImage("images/timg.jpg")
////                    ?
////                    : NetworkImage(assertImage))),
//      ))),
      title: name,
      subtitle: groupTitle,
    );
  }
}

void saveContact(List<ContactInfo> contactList) {
//
  List<String> sqls = new List();
  contactList.forEach((c) {
    var sqlLine = "insert into $appContacts "
        "set mobile =${c.mobile},"
        "avatar=${c.avatar},"
        "sex=${c.sex},"
        "nick_name=${c.username}"
        "on duplicate key id=${c.contactId}";
//      insertData(sqlLine);
  });
}

//  void loadData() async {
//    _hotCityList.add(CityInfo(name: "北京市", tagIndex: "★"));
//    _hotCityList.add(CityInfo(name: "广州市", tagIndex: "★"));
//    _hotCityList.add(CityInfo(name: "成都市", tagIndex: "★"));
//    _hotCityList.add(CityInfo(name: "深圳市", tagIndex: "★"));
//    _hotCityList.add(CityInfo(name: "杭州市", tagIndex: "★"));
//    _hotCityList.add(CityInfo(name: "武汉市", tagIndex: "★"));
//
//    //加载城市列表
//    rootBundle.loadString('assets/data/china.json').then((value) {
//      Map countyMap = json.decode(value);
//      List list = countyMap['china'];
//      list.forEach((value) {
//        _cityList.add(CityInfo(name: value['name']));
//      });
//      _handleList(_cityList);
//      setState(() {
//        _suspensionTag = _hotCityList[0].getSuspensionTag();
//      });
//    });
//  }

//  void _handleList(List<CityInfo> list) {
//    if (list == null || list.isEmpty) return;
//    for (int i = 0, length = list.length; i < length; i++) {
//      String pinyin = PinyinHelper.getPinyinE(list[i].name);
//      String tag = pinyin.substring(0, 1).toUpperCase();
//      list[i].namePinyin = pinyin;
//      if (RegExp("[A-Z]").hasMatch(tag)) {
//        list[i].tagIndex = tag;
//      } else {
//        list[i].tagIndex = "#";
//      }
//    }
//    //根据A-Z排序
//    SuspensionUtil.sortListBySuspensionTag(_cityList);
//  }

//  void _onSusTagChanged(String tag) {
//    setState(() {
//      _suspensionTag = tag;
//    });
//  }

//  Widget _buildSusWidget(String susTag) {
//    susTag = (susTag == "★" ? "热门城市" : susTag);
//    return Container(
//      height: _suspensionHeight.toDouble(),
//      padding: const EdgeInsets.only(left: 15.0),
//      color: Color(0xfff3f4f5),
//      alignment: Alignment.centerLeft,
//      child: Text(
//        '$susTag',
//        softWrap: false,
//        style: TextStyle(
//          fontSize: 14.0,
//          color: Color(0xff999999),
//        ),
//      ),
//    );
//  }

//  Widget _buildListItem(CityInfo model) {
//    String susTag = model.getSuspensionTag();
//    susTag = (susTag == "★" ? "热门城市" : susTag);
//    return Column(
//      children: <Widget>[
//        Offstage(
//          offstage: model.isShowSuspension != true,
//          child: _buildSusWidget(susTag),
//        ),
//        SizedBox(
//          height: _itemHeight.toDouble(),
//          child: ListTile(
//            title: Text(model.name),
//            onTap: () {
//              print("OnItemClick: $model");
//              Navigator.pop(context, model);
//            },
//          ),
//        )
//      ],
//    );
//  }

//  @override
//  Widget build(BuildContext context) {
//    return Column(
//      children: <Widget>[
//        Container(
//          alignment: Alignment.centerLeft,
//          padding: const EdgeInsets.only(left: 15.0),
//          height: 50.0,
//          child: Text("当前城市: 成都市"),
//        ),
//        Expanded(
//            flex: 1,
//            child: AzListView(
//              data: _cityList,
//              topData: _hotCityList,
//              itemBuilder: (context, model) => _buildListItem(model),
//              suspensionWidget: _buildSusWidget(_suspensionTag),
//              isUseRealIndex: true,
//              itemHeight: _itemHeight,
//              suspensionHeight: _suspensionHeight,
//              onSusTagChanged: _onSusTagChanged,
//              //showCenterTip: false,
//            )),
//      ],
//    );
//  }
//}

class CityInfo {
  String name;
  String tagIndex;

  CityInfo({this.name, this.tagIndex});
}

class ContactInfo {
  //好友Id
  int contactId;

  //手机号
  String mobile;

  //头像
  String avatar;

  //用户名字
  String username; //NickName;
//描述
  String medo;

  //性别
  String sex; //M F U;

  int indexLetter;

  bool isShowSendBtu=true;

  static ContactInfo fromMap(Map<String, dynamic> map) {
    ContactInfo contactInfo = new ContactInfo();
    contactInfo.contactId = map['Id'];
    contactInfo.mobile = map['Mobile'];
    contactInfo.avatar = map['Avatar'];
    contactInfo.username = map['NickName'];
    contactInfo.medo = map['medo'];
    contactInfo.sex = map['sex'];
    return contactInfo;
  }
}

class IndexBar extends StatefulWidget {
  final void Function(String string) indexBarCallBack;

  const IndexBar({Key key, this.indexBarCallBack}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _IndexBarState();
  }
}

int GetIndex(BuildContext context, Offset globalPosition) {
  RenderBox box = context.findRenderObject();
  double y = box.globalToLocal(globalPosition).dy;
  //每一个Item的高度
  var ItemHeight = ScreenHeignt(context) / 2 / INDEX_WORDS.length;

  //clamp 防止越界
  int index = (y ~/ ItemHeight).clamp(0, INDEX_WORDS.length - 1);

  return index;
  print(' index = $index  ,${INDEX_WORDS[index]}');
}

double ScreenHeignt(BuildContext context) {
  return MediaQuery.of(context).size.height;
}

class _IndexBarState extends State<IndexBar> {
  var _selectedIndex = -1;

  Color _IndexBarBackColor = Color.fromRGBO(1, 1, 1, 0.0);
  Color _TextColor = Colors.black;

  @override
  Widget build(BuildContext context) {
    List<Widget> _WordsWidget = [];

    var x = ScreenHeignt(context) / (INDEX_WORDS.length) - 20;
    for (int i = 0; i < INDEX_WORDS.length; i++) {
      _WordsWidget.add(Container(
        padding: EdgeInsets.only(top: x),
        child: Text(
          INDEX_WORDS[i],
          style: TextStyle(color: _TextColor, height: 1),
        ),
      ));
    }
    return Positioned(
      right: 10.0,
      width: 30,
      top: 0,
      height: ScreenHeignt(context),
      child: GestureDetector(
        child: Container(
          color: _IndexBarBackColor,
          child: Column(
            children: _WordsWidget,
          ),
        ),

        onVerticalDragUpdate: (DragUpdateDetails details) {
          if (_selectedIndex != GetIndex(context, details.globalPosition)) {
            _selectedIndex = GetIndex(context, details.globalPosition);
            widget.indexBarCallBack(INDEX_WORDS[_selectedIndex]);
          } //重复点击添加容错处理
        },

        //按下
        onVerticalDragDown: (DragDownDetails details) {
          setState(() {
            _IndexBarBackColor = Color.fromRGBO(1, 1, 1, 0.3);
            _TextColor = WechatThemeColor;
          });
          widget.indexBarCallBack(
              INDEX_WORDS[GetIndex(context, details.globalPosition)]);
        },

        onVerticalDragEnd: (DragEndDetails details) {
          setState(() {
            _IndexBarBackColor = Color.fromRGBO(1, 1, 1, 0.0);
            _TextColor = Colors.black;
          });
        },
      ),
    );
  }
}
