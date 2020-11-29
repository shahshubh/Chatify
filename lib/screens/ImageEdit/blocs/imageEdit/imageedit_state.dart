part of 'imageedit_bloc.dart';

@immutable
abstract class ImageeditState {}

class ImageeditInitial extends ImageeditState {}

class ImageLoaded extends ImageeditState{

  final File file;

  ImageLoaded({this.file});

  @override
  String toString() {
  return 'Image Loaded ${file.path}';
   }

}


