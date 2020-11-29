import 'dart:async';
import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

part 'imageedit_event.dart';
part 'imageedit_state.dart';

class ImageeditBloc extends Bloc<ImageeditEvent, ImageeditState> {
  @override
  ImageeditState get initialState => ImageeditInitial();

  @override
  Stream<ImageeditState> mapEventToState(
    ImageeditEvent event,
  ) async* {
    if(event is LoadImage){
      yield * _mapLoadImagetoState(event);
    }
  }

 Stream<ImageeditState> _mapLoadImagetoState(LoadImage event) async*{

    yield ImageLoaded(file: event.file);
  }

  @override
  void onTransition(Transition<ImageeditEvent, ImageeditState> transition) {
    // TODO: implement onTransition
    print(transition);
  }
}
