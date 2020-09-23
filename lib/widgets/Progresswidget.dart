import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

circularprogress() {
  return SizedBox(
    child: CircularProgressIndicator(
      valueColor: AlwaysStoppedAnimation(Colors.white),
    ),
    height: 20.0,
    width: 20.0,
  );
}

linearprogress() {
  return Container(
    alignment: Alignment.center,
    padding: EdgeInsets.only(top: 12.0),
    child: LinearProgressIndicator(
      valueColor: AlwaysStoppedAnimation(Colors.lightBlueAccent),
    ),
  );
}
