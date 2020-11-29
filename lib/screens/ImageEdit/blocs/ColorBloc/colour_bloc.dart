import 'dart:async';

import 'package:bloc/bloc.dart';
// import 'package:chat_app/blocs/DrawingBloc/drawing_bloc.dart';
import 'package:Chatify/screens/ImageEdit/blocs/DrawingBloc/drawing_bloc.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

part 'colour_event.dart';
part 'colour_state.dart';

class ColourBloc extends Bloc<ColourEvent, ColourState> {

  Color color = Colors.pink;
  final DrawingBloc drawingBloc;
  StreamSubscription _drawSubs;



  ColourBloc({this.drawingBloc}){
    _drawSubs = drawingBloc.listen((state) {
        if(state is LineDrawing || state is AddingText){
          add(ColourReset());
        }
     });
  }

  @override
  ColourState get initialState => ColourInitial(color: color);

  // @override
  // void onTransition(Transition<ColourEvent, ColourState> transition) {
  //   // TODO: implement onTransition
  //   print(transition);
  // }

  @override
  Stream<ColourState> mapEventToState(
    ColourEvent event,
  ) async* {
    if(event is ColourChange){
      color = event.color;
      yield ColourInitial(color: event.color);
    }
    if(event is ColourReset){
      yield ColourInitial(color: Colors.pink);
    }
  }
}
