import 'package:ChatApp/enum/user_state.dart';

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
}
