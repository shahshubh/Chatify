part of 'canvas_bloc.dart';

@immutable
abstract class CanvasState {}

class CanvasInitial extends CanvasState {

  final List<Pointer> points;

  CanvasInitial(this.points);

}




