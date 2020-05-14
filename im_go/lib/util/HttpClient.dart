import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/http.dart';

import '../main.dart';

var client;

initHttpClient() {
  if (client == null) {
    client = http.Client();
  }
}


Future<Response> httpPost(String url,  body,
    {Map<String, String> headers}) async {
  initHttpClient();
  var uriResponse =
      await client.post(url, body: body, encoding: utf8, headers: headers);
  return uriResponse;
}

Future<Response> httpGet(String url, {Map<String, String> headers}) async {
  initHttpClient();
  var uriResponse = await client.get(url, headers: headers);
  return uriResponse;
}

String addToken(String url) {
  return url + "?id=" + userId.toString() + "&token=" + token;
}
