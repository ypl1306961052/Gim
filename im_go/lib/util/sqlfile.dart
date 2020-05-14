//初始化联系人

import 'package:sqflite/sqflite.dart';

int version = 2;
Database database;
String appContacts = "app_contacts";
String appChatList = "app_chat_list";
String appChatHistory = "app_chat_history";
//初始化contact table
initContactDb() async {
  var databasePath = await getDatabasesPath();
  String path = databasePath + "/im.db";
  database = await openDatabase(path,
      version: version,
      onUpgrade: (Database db, int oldVersion, int newVersion) {
        print('更新表');
        initCreate(db);
      },
      onOpen: (Database db) {},
      onCreate: (Database db, int version) async {
        print('创建表');
        initCreate(db);
      });
}

initCreate(Database db) async {
  print('创建了 app_contacts 表');
  await db.execute("create table if NOT EXISTS $appContacts(" +
      "id INT PRIMARY KEY," +
      "mobile VARCHAR(255)," +
      "avatar VARCHAR(255)," +
      "sex CHAR(1)," +
      "mode VARCHAR(255)," +
      "nick_name VARCHAR(255)" +
      ")");
  print('创建了 $appContacts 表成功');
  await db.execute("CREATE TABLE if NOT EXISTS $appChatList (" +
      "user_id int NOT NULL," +
      "recive_id INT NOT NULL," +
      "unread_count INT NOT NULL DEFAULT 0," +
      "create_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP," +
      "update_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP" +
      ")");
  print('创建了 $appChatList 表成功');
  //创建聊天记录表
//{"id":1,"time":1588863767634,"sendId":6,"receiveId":2,"cmd":1,"media":1,"content":"fasdda","url":"","voiceLen":0}
  await db.execute("CREATE TABLE if NOT EXISTS $appChatHistory("
          "id INT PRIMARY key," +
      "user_id int not null," +
      "receive_id INT NOT NULL," +
      "media TINYINT NOT NULL," +
      "content text ," +
      "url VARCHAR(255)," +
      "cmd TINYINT NOT null," +
      "is_sender tinyint not null," +
      "voice_len TINYINT NOT NULL DEFAULT 0," +
      "time TIMESTAMP"
          ")");
  print('创建了 $appChatHistory 表成功');

}

class AppChatList {
  int userId;
}

//插入数据
insertData(String sql) async {
  if (database == null) {
    initContactDb();
  }
  await database.execute(sql);
}

//insetBatchData(List<String> sql) async {
//  if (database == null) {
//    initContactDb();
//  }
//  sql.forEach((t) {
//    insertData(t);
//  });
//}
