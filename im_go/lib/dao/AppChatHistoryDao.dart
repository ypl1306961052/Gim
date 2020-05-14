import 'dart:ffi';

import 'package:im_go/util/sqlfile.dart';

class AppChatHistoryDao {
  //插入消息

  Future<int> insetIntoChatHistory(int media, int userID, int receiveId,
      String content, int cmd, int time, bool isSender,
      {String url, int voiceLen}) {
    List<dynamic> args = new List();
    String id = userID.toString() + receiveId.toString() + time.toString();
//    args.add(id);
    args.add(userID);
    args.add(receiveId);
    args.add(media);
    args.add(content);
    if (url == null) {
      url = "";
    }
    args.add(url);
    args.add(cmd);
    if (voiceLen == null) {
      voiceLen = 0;
    }
    args.add(voiceLen);
    args.add(time);
    args.add(isSender);
    var insertSql =
        "insert into $appChatHistory(user_id,receive_id,media,content,url,cmd,voice_len,time,is_sender) values(?,?,?,?,?,?,?,?,?)";
    return database.rawInsert(insertSql, args);
  }

//查询消息
  Future<List<Map<String, dynamic>>> queryChatHistory(int receiveId,
      {int start, int size}) {
    //按照时间线
    var selectSql;
    List<dynamic> args = new List();
    if (start < 0 || size < 0) {
      selectSql =
          "select * from $appChatHistory where receive_id=? order by  time DESC";
      args.add(receiveId);
    } else {
      selectSql =
          "select * from $appChatHistory where receive_id=? order by  time DESC limit ?,?";
      args.add(receiveId);
      args.add(start);
      args.add(size);
    }
    return database.rawQuery(selectSql, args);
  }

  Future<int> deleteChatHistory(int id) {
    List<dynamic> args = new List();
    args.add(id);
    String deleteSql = "delete from $appChatHistory where id=?";

    return database.rawDelete(deleteSql, args);
  }

  Future<Map<int, String>> queryChatMessageLastNew(List<int> reId) async {
    Map<int, String> f = new Map<int, String>();
    for (var id in reId) {
      List<dynamic> args = new List();
      args.add(id);
      var re = await database.rawQuery(
          "select content from $appChatHistory where receive_id in (?) order by time desc limit 1",
          args);
      if (re.length == 1) {
        if (re[0].length == 1) {
          Map<int, String> d = new Map();
          d.putIfAbsent(id, () {
            return re[0]['content'];
          });
          f.addAll(d);
        }
      }
    }
    return Future(() {
      return f;
    });
  }
}
