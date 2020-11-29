import 'dart:async';

import 'package:bloc/bloc.dart';
// import 'package:Cha/blocs/ColorBloc/colour_bloc.dart';
import 'package:Chatify/screens/ImageEdit/blocs/ColorBloc/colour_bloc.dart';
// import 'package:chat_app/blocs/DrawingBloc/drawing_bloc.dart';
import 'package:Chatify/screens/ImageEdit/blocs/DrawingBloc/drawing_bloc.dart';
// import 'package:chat_app/blocs/imageEdit/imageedit_bloc.dart';
import 'package:Chatify/screens/ImageEdit/blocs/imageEdit/imageedit_bloc.dart';
import 'package:Chatify/models/models.dart';
// import 'package:chat_app/screens/image_upload.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'dart:async';

part 'canvas_event.dart';
part 'canvas_state.dart';

class CanvasBloc extends Bloc<CanvasEvent, CanvasState> {




  List<Pointer> points = List<Pointer>();
  Color color = Colors.pink;
  double width = 10.0;
  final ImageeditBloc imageeditBloc;
  final ColourBloc colorBloc;
  final DrawingBloc drawingBloc;
  StreamSubscription _colorSubs;
  StreamSubscription _streamSubscription;



  CanvasBloc(this.imageeditBloc,this.colorBloc,this.drawingBloc){
    _streamSubscription = imageeditBloc.listen((state) {
      if(state is ImageLoaded){
        add(ClearCanvas());
      }
      color = (colorBloc.state as ColourInitial).color;
      _colorSubs = colorBloc.listen((state){
          if(state is ColourInitial){
            add(ChangeColor(color: (state as ColourInitial).color));
          }
      })  ;
     });
  }

  // @override
  // void onTransition(Transition<CanvasEvent, CanvasState> transition) {
  //   // TODO: implement onTransition
  //   print(transition);
  // }



  @override
  CanvasState get initialState => CanvasInitial(points);

  @override
  Stream<CanvasState> mapEventToState(
    CanvasEvent event,
  ) async* {
    if(event is PanUpdate){
      yield * _mapPanUpdatetoEvent(event);
    }
    if(event is PanEnd){
      if((drawingBloc.state) is LineDrawing){
          points.add(null);
      yield CanvasInitial(points);
      }
    }
    if(event is ChangeColor){
      color = event.color;
      yield CanvasInitial(points);
    }
    if(event is UndoChange){
      yield* _mapUndoChangetoSate();
    }
    if(event is ClearCanvas){
      points.clear();
      yield CanvasInitial(points);
    }
  }

  Stream<CanvasState> _mapPanUpdatetoEvent(PanUpdate event) async*{
    if((drawingBloc.state) is LineDrawing){
          color = (colorBloc.color);
          points.add(Pointer(color:color,width: width,offset: event.point));
          yield CanvasInitial(points);
    }
  }

  Stream<CanvasState> _mapUndoChangetoSate() async* {
      if(points.isNotEmpty){
        points.removeLast();
        for(var i = points.length - 1 ; points[i] != null || i == 0 ; i--){
            points.removeLast();
        }
      }
      yield CanvasInitial(points);

  }

}
