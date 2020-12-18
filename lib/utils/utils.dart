import 'package:Chatify/enum/user_state.dart';
import 'package:Chatify/enum/message_type.dart';

class Utils {
  static int stateToNum(UserState userState) {
    switch (userState) {
      case UserState.Offline:
        return 0;
      case UserState.Online:
        return 1;
      default:
        return 2;
    }
  }

  static UserState numToState(int number) {
    switch (number) {
      case 0:
        return UserState.Offline;
      case 1:
        return UserState.Online;
      default:
        return UserState.Waiting;
    }
  }

  static int msgToNum(MessageType msgType) {
    switch (msgType) {
      case MessageType.Text:
        return 0;
      case MessageType.Image:
        return 1;
      case MessageType.Gif:
        return 2;
      case MessageType.Sticker:
        return 3;
      case MessageType.Deleted:
        return -1;
    }
  }

  static MessageType numToMsg(int number) {
    switch (number) {
      case 0:
        return MessageType.Text;
      case 1:
        return MessageType.Image;
      case 2:
        return MessageType.Gif;
      case 3:
        return MessageType.Sticker;
      case -1:
        return MessageType.Deleted;
    }
  }
}
