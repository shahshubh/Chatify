import 'package:Chatify/enum/message_type.dart';
import 'package:flutter/material.dart';

class StickerGif extends StatelessWidget {
  String gifName;
  Function onSendMessage;
  StickerGif({@required this.gifName, @required this.onSendMessage});

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      onPressed: () => onSendMessage(gifName, MessageType.Sticker),
      child: Image.asset(
        'images/$gifName.gif',
        width: 50.0,
        height: 50.0,
        fit: BoxFit.cover,
      ),
    );
  }
}
