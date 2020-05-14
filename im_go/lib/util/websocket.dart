import 'dart:ffi';
import 'dart:io';

import 'package:im_go/main.dart';
import 'package:im_go/util/HttpClient.dart';

class WebSocketManager {
  static WebSocketManager _webSocketManager;
  WebSocket _webSocket;
  List<WebSocketListen> _webSocketListen = new List();

  factory WebSocketManager() {
    if (_webSocketManager == null) {
      _webSocketManager = new WebSocketManager._();
    }
    return _webSocketManager;
  }

  void sendMessage(String data) {
    if (_webSocket == null) {
      initWebSocket().then((int code) {
        if (code == 1) {
          _webSocket.add(data);
        } else {
          print('发送数据失败');
        }
      });
    } else {
      _webSocket.add(data);
    }
  }

  void addDataListen(WebSocketListen webSocketListen) {
    _webSocketListen.add(webSocketListen);
  }

  Future<int> initWebSocket() async {
    print('正在初始化websocket...');
    if (_webSocket != null) {
      print('复用websocket...');
    } else {
      try {
        if (token == null) {
          print('初始化websocket失败 因为token为空');
          return -1;
        }
        _webSocket = await WebSocket.connect(addToken(webSocketHost));
        _webSocket.listen((data) {
          //复制数据
          //分发数据
          //监听数据
          print(data);
          _webSocketListen.forEach((t) {
            t.handle(data);
          });
        }, onDone: () {
          print('服务关闭了');
        }, cancelOnError: true);
      } on Exception catch (e) {
        print('websocket建立 失败');
        return -1;
      }
      return 0;
    }
  }

  void close() {
    if (_webSocket != null && _webSocket.closeCode == null) {
      _webSocket.close(-1, "正常关闭");
    }
  }

//构造函数私有化
  WebSocketManager._();
}

abstract class WebSocketListen {
  void handle(String data);
}
