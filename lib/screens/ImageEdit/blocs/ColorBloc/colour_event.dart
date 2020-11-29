part of 'colour_bloc.dart';

@immutable
abstract class ColourEvent {}

class ColourChange extends ColourEvent{

  final Color color;

  ColourChange({this.color});

  @override
  String toString() {
  return 'Colour Change Event';
   }

}

class ColourReset extends ColourEvent{

  @override
  String toString() {
  return "Colour Reset Event";
   }

}