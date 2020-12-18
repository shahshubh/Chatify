import 'package:Chatify/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

oldcircularprogress() {
  return Container(
    alignment: Alignment.center,
    padding: EdgeInsets.only(top: 12.0),
    child: CircularProgressIndicator(
      valueColor: AlwaysStoppedAnimation(kPrimaryColor),
    ),
  );
}

circularprogress() {
  return SizedBox(
    child: CircularProgressIndicator(
      valueColor: AlwaysStoppedAnimation(Colors.white),
    ),
    height: 20.0,
    width: 20.0,
  );
}
