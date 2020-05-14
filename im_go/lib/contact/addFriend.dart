import 'dart:convert';

import 'package:flui/flui.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:im_go/main.dart';
import 'package:im_go/util/Dialog.dart';
import 'package:im_go/util/HttpClient.dart';

class AddFriendPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return AddFriendPageSate();
  }
}

class AddFriendPageSate extends State<AddFriendPage> {
  var newFriend = "";

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text("添加好友"),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
            child: TextField(
              cursorColor: Colors.green,
              keyboardType: TextInputType.number,
              onChanged: (String value) {
                newFriend = "";
              },
            ),
            padding: EdgeInsets.only(left: 10, right: 10),
          ),
          Container(
            padding: EdgeInsets.only(left: 10, right: 10),
            child: FLFlatButton(
              expanded: true,
              color: Colors.green,
              textColor: Colors.white,
              child: Text('添加好友', textAlign: TextAlign.center),
              onPressed: () {
                var body = {'ownerId': userId.toString(), "destId": newFriend};
                var url = host + addFriend;

                var respose = httpPost(addToken(url), body);
                respose.then((Response res) {
                  if (res.statusCode == 200) {
                    var resJson = jsonDecode(res.body);
                    if (resJson['code'] == 0) {
                      showInfoDialog(context, desc: resJson['msg']);
                    } else {
                      showAlertDialog(context, desc: resJson['msg']);
                    }
                  } else {
                    showAlertDialog(context, desc: res.body);
                  }
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}
