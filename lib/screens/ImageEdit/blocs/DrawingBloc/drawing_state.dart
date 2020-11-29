part of 'drawing_bloc.dart';

@immutable
abstract class DrawingState {}

class DrawingInitial extends DrawingState {

  @override
  String toString() {
  return 'Draw Inital State';
   }
}

class LineDrawing extends DrawingState{

  @override
  String toString() {
  return 'Line Drawing State';
   }
}

class AddingText extends DrawingState{


  @override
  String toString() {
  return 'Adding Text State';
   }
}

class TextDragged extends DrawingState{

  final Color binColor;


  TextDragged({this.binColor});

  @override
  String toString() {
  return 'Text Dragged State';
   }

}