part of 'canvas_bloc.dart';

@immutable
abstract class CanvasEvent {}

class PanUpdate extends CanvasEvent{

   final Offset point;

  PanUpdate({this.point});

  @override
  String toString() {
  return 'Pan Update Event';
   }

}

class PanEnd extends CanvasEvent{


  @override
  String toString() {
  return 'Pan End Event';
   }

}

class ChangeColor extends CanvasEvent{
  final Color color;
  
  ChangeColor({this.color});

  @override
  String toString() {
  return 'Canvas Colour Change Event';
   }
}

class ChangeStrokeWidth extends CanvasEvent{}

class UndoChange extends CanvasEvent{}

class ClearCanvas extends CanvasEvent{}
