part of 'colour_bloc.dart';

@immutable
abstract class ColourState {}

class ColourInitial extends ColourState {

   final Color color;

   ColourInitial({this.color});

   @override
   String toString() {
   return 'Colour Inital State';
    }

}
