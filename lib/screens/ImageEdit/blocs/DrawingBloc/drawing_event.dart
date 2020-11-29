part of 'drawing_bloc.dart';

@immutable
abstract class DrawingEvent {}
class DrawLine extends DrawingEvent{

  @override
  String toString() {
  return 'Draw Line Event';
   }
}

class DrawText extends DrawingEvent{

  @override
  String toString() {
  return 'Draw Text Event';
   }
}


class LineDrawn extends DrawingEvent{

  @override
  String toString() {
  return 'Text Drawn';
   }
}

class TextInserted extends DrawingEvent{

  @override
  String toString() {
    return 'Text Inserted';
  }
}

class TextDraggingStart extends DrawingEvent{

  @override
  String toString() {
  return 'Text Dragging Start event';
   }
}

class TextDraggingEnd extends DrawingEvent{


  @override
  String toString() {
    return 'Text Dragging End event';
  }
}

class TextDragginOnBin extends DrawingEvent{


  @override
  String toString() {
  return 'Text Dragging on Bin event';
   }
}