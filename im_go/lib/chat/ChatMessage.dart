import 'dart:ffi';

class TransferChatMessage {
  int id;
  int time;
  int sendId;
  int receiveId;
  int cmd;
  String content;
  String url;
  int voiceLen;
  int media;

  static TransferChatMessage forMap(Map<String, dynamic> map) {
    TransferChatMessage chatMessage = new TransferChatMessage();
    chatMessage.id = map['id'];
    chatMessage.time = map['time'];
    chatMessage.sendId = map['sendId'];
    chatMessage.receiveId = map['receiveId'];
    chatMessage.cmd= map['cmd'];
    chatMessage.content = map['content'];
    chatMessage.url = map['url'];
    chatMessage.voiceLen = map['voiceLen'];
    chatMessage.media = map['media'];
    return chatMessage;
  }
}
