import 'dart:async';

import 'package:bloc/bloc.dart';
// import 'package:chat_app/blocs/ColorBloc/colour_bloc.dart';
// import 'package:chat_app/blocs/DrawingBloc/drawing_bloc.dart' as draw;
import 'package:Chatify/screens/ImageEdit/blocs/ColorBloc/colour_bloc.dart';
import 'package:Chatify/screens/ImageEdit/blocs/DrawingBloc/drawing_bloc.dart' as draw;
import 'package:Chatify/models/text.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

part 'text_event.dart';
part 'text_state.dart';

class TextBloc extends Bloc<TextEvent, TextState> {
  @override
  TextState get initialState => TextAdded(texts: this.texts);

  Color color = Colors.pink;
  List<TextModel> texts = List<TextModel>();
  draw.DrawingBloc drawingBloc;
  StreamSubscription drawBlocSubs;
  ColourBloc colourBloc;
  StreamSubscription colorSubs;
  String text;
  TextStyle textStyle;
  bool newText = true;
  TextModel removedText;

  List<Map> fonts = [
    {
      'title': 'Classic',
      'name':'Lato'
    },
    {
      'title':'Modern',
      'name': 'Modern'
    },
    {
      'title':'Typewriter',
      'name':'NimbusMono'
    }
  ];

  TextBloc(this.drawingBloc,this.colourBloc){
    drawBlocSubs = drawingBloc.listen((state) {
      if(state is draw.AddingText && newText){
        print("adding text");
        add(LoadText());
      }
    });
    colorSubs = colourBloc.listen((state) {
      if(state is ColourInitial){
        if(state.color != color && drawingBloc.state is draw.AddingText){
          color = state.color;
          add(ChangeTextColor(color: state.color));
        }
      }
    });
    
  }

  @override
  Stream<TextState> mapEventToState(
    TextEvent event,
  ) async* {
    if(event is AddText){
      if(text != '' && newText) {
      texts.add(TextModel(text: text,textStyle: textStyle));
      text = '';
      }
      else if(!newText){
        texts.add(TextModel.editText(text: text != '' ? text : removedText.text,textStyle: textStyle,removeText: removedText ));
        newText = true;
      }
      yield TextAdded(texts: texts);
    }
    if(event is ChangeTextColor){
      String font = (super.state as AddingText ).fontFamily;
      yield(AddingText(color: event.color,fontFamily: font));
    }
    if(event is LoadText){
      yield(AddingText(color: color,fontFamily: 'Lato'));
    }
    if(event is TextChanged){
      this.text = event.text;
      this.textStyle = event.textStyle;
    }
    if(event is OnScaleChanged){
      int index = event.index;
      texts[index].position = event.position;
      texts[index].scale = event.scale;
      texts[index].rotation = event.rotation;
      // yield TextAdded(texts: texts);
    }
    if(event is ChangeTextFont){
      Color color = (super.state as AddingText ).color;
      yield AddingText(color: color,fontFamily: fonts[event.index]['name']);
    }
    if(event is EditText){
      removedText = texts.removeAt(event.index);
      newText = false;
      yield AddingText(color: removedText.textStyle.color,fontFamily: removedText.textStyle.fontFamily,initalText: removedText.text);
      drawingBloc.add(draw.DrawText());
    }
    if(event is DeleteText){
      texts.removeAt(event.index);
      yield TextAdded(texts: texts);
    }
  }


  void changeProperties({Offset position,double scale,double rotation}){

  }


  // @override
  // void onTransition(Transition<TextEvent, TextState> transition) {
  //   // TODO: implement onTransition
  //   print(transition);
  // }
}
