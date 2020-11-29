part of 'text_bloc.dart';

@immutable
abstract class TextEvent {}


class AddText extends TextEvent{


  AddText();

  @override
  String toString() {
  return 'Add Text(Text Bloc)';
   }

}


class LoadText extends TextEvent{}


class ChangeTextColor extends TextEvent{

  final Color color;

  ChangeTextColor({this.color});

  @override
  String toString() {
  return 'Change Text Color';
   }

}

class ChangeTextFont extends TextEvent{

  final int index;

  ChangeTextFont({this.index});

  @override
  String toString() {
  return 'Change Font';
   }


}

class TextChanged extends TextEvent{

  final String text;
  final TextStyle textStyle;

  TextChanged({this.text,this.textStyle});

  @override
  String toString() {
    // TODO: implement toString
    return 'Text Changed';
  }

}

class OnScaleChanged extends TextEvent
{
    final int index;
    final Offset  position;
    final double scale;
    final double rotation;

    OnScaleChanged({this.index,this.position,this.scale,this.rotation});

}


class EditText extends TextEvent{

  final int index;

  EditText({this.index});

  @override
  String toString() {
  return 'Edit Text Event';
   }

}

class DeleteText extends TextEvent{

  final int index;

  DeleteText({this.index});

  @override
  String toString() {
  return 'Delete Text Event';
   }

}
