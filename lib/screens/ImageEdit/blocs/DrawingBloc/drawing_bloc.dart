import 'dart:async';

import 'package:bloc/bloc.dart';
// import 'package:chat_app/blocs/TextBloc/text_bloc.dart';
import 'package:Chatify/screens/ImageEdit/blocs/TextBloc/text_bloc.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

part 'drawing_event.dart';
part 'drawing_state.dart';

class DrawingBloc extends Bloc<DrawingEvent, DrawingState> {
  @override
  DrawingState get initialState => DrawingInitial();

  @override
  Stream<DrawingState> mapEventToState(
    DrawingEvent event,
  ) async* {
    if(event is DrawLine){
      yield LineDrawing();
    }
    if(event is DrawText)
    {
      yield AddingText();
    }
    if(event is LineDrawn){
      yield DrawingInitial();
    }
    if(event is TextInserted){
      yield DrawingInitial();
    }
    if(event is TextDraggingStart){
      yield TextDragged(binColor: Colors.transparent);
    }
    if(event is TextDraggingEnd){
      yield DrawingInitial();
    }
    if(event is TextDragginOnBin){
      yield  TextDragged(binColor: Colors.red);
    }
  }

  @override
  void onTransition(Transition<DrawingEvent, DrawingState> transition) {
    // TODO: implement onTransition
    print(transition);
  }
}
