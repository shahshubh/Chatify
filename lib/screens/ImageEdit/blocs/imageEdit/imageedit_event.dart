part of 'imageedit_bloc.dart';

@immutable
abstract class ImageeditEvent {}

class LoadImage extends ImageeditEvent{
  final File file;
  LoadImage({this.file});

  @override
  String toString() {
  return 'Load Image ${file.path}';
   }
}

