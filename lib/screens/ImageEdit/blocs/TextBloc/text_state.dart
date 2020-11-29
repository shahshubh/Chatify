part of 'text_bloc.dart';

@immutable
abstract class TextState {}

class TextInitial extends TextState{}

class AddingText extends TextState {
    final Color color;
    final String fontFamily;
    final String initalText;

    AddingText({this.color,this.fontFamily,this.initalText});

    @override
    String toString() {
    return 'Adding Text';
     }
}

class TextAdded extends TextState{

  final List<TextModel> texts;

  TextAdded({this.texts});

  @override
  String toString() {
  return 'Text Added';
   }
}
