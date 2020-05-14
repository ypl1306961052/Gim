import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

//附近
class NearView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return NearViewStateful();
  }
}

class NearViewStateful extends State<NearView> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      body: Center(
        child: Text("附近"),
      ),
    );
  }
}
