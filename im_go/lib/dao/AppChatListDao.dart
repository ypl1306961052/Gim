import 'dart:ffi';

import 'package:im_go/util/sqlfile.dart';
import 'package:im_go/util/time.dart';

class AppChatListDao {
  Future<List<Map<String, dynamic>>> queryAppChatList(int userId,
      {int receiveId}) {
    if (receiveId == null) {
      List<String> args = new List();
      args.add(userId.toString());
      var appChatQuerySql =
          "select user_id,recive_id,unread_count from $appChatList where user_id=? ";
      print(appChatQuerySql + args.toString());
      return database.rawQuery(appChatQuerySql, args);
    } else {
      List<String> args = new List();
      args.add(userId.toString());
      args.add(receiveId.toString());
      var appChatQuerySql =
          "select user_id,recive_id,unread_count from $appChatList where user_id=? and recive_id=?";
      print(appChatQuerySql + args.toString());
      return database.rawQuery(appChatQuerySql, args);
    }
  }

  Future<int> insertIntoAppChatList(int userId, int receiveId,
      {int unreadCount}) async {
    List<dynamic> args = new List();
    args.add(userId);
    args.add(receiveId);
    if (unreadCount == null) {
      args.add(0);
    } else {
      args.add(unreadCount);
    }

    var appChatInsertSql =
        "insert into $appChatList(user_id,recive_id,unread_count) values(?,?,?)";
    return database.rawInsert(appChatInsertSql, args);
  }

  Future<int> updateAppChatList(int userId, int receiveId, {int unReadCount}) {
    if (unReadCount == null) {
      List<dynamic> args = new List();
      args.add(currentTimeMillis());
      args.add(userId);
      args.add(receiveId);
      var appChatUpdateSql =
          "update  $appChatList set update_time=? where user_id=? and recive_id=?";
      return database.rawUpdate(appChatUpdateSql, args);
    } else {
      List<dynamic> args = new List();
      args.add(currentTimeMillis());
      args.add(unReadCount);
      args.add(userId);
      args.add(receiveId);
      var appChatUpdateSql =
          "update table $appChatList set update_time=? and unread_count=?  where user_id=? and recive_id=?";
      return database.rawUpdate(appChatUpdateSql, args);
    }
  }
}
