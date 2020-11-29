import 'package:flutter/material.dart';
import 'package:flutter/material.dart' as mat;


class TextModel {

  String text;
  mat.TextStyle textStyle;
  Offset position;
  double rotation;
  double scale;

  TextModel({this.text,this.textStyle}){
    position = Offset(100,100);
    scale = 1;
    rotation = 0.0;
  }

  TextModel.editText({this.text,this.textStyle,TextModel removeText}){
      this.position = removeText.position;
      this.rotation = removeText.rotation;
      this.scale = removeText.scale;
  } 


}