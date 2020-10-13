import 'package:Chatify/utils/utils.dart';
import 'package:Chatify/constants.dart';
import 'package:Chatify/enum/user_state.dart';
import 'package:Chatify/resources/user_state_methods.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class StatusIndicator extends StatelessWidget {
  final String uid;
  final String screen;
  final UserStateMethods userStateMethods = UserStateMethods();

  StatusIndicator({@required this.uid, @required this.screen});
  @override
  Widget build(BuildContext context) {
    getColor(int state) {
      switch (Utils.numToState(state)) {
        case UserState.Offline:
          return Colors.red;
        case UserState.Online:
          return Colors.green;
        default:
          return Colors.orange;
      }
    }

    return StreamBuilder(
      stream: userStateMethods.getUserStream(uid: uid),
      builder: (context, snapshot) {
        var user;
        if (!snapshot.hasData) {
          return Container(
            child: Center(
              child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(
                kPrimaryColor,
              )),
            ),
            height: MediaQuery.of(context).copyWith().size.height -
                MediaQuery.of(context).copyWith().size.height / 5,
            width: MediaQuery.of(context).copyWith().size.width,
          );
        }
        user = snapshot.data.data;
        if (screen == "chatDetailScreen") {
          return Text(
            user["state"] == 1
                ? "Online"
                : "Last Seen " +
                    DateFormat("dd MMMM, hh:mm aa").format(
                        DateTime.fromMillisecondsSinceEpoch(
                            int.parse(user["lastSeen"]))),
            style: TextStyle(
                color:
                    user["state"] == 1 ? getColor(user["state"]) : Colors.grey,
                fontSize: 12),
          );
        } else {
          return Container(
            height: 10,
            width: 10,
            decoration: BoxDecoration(
                shape: BoxShape.circle, color: getColor(user["state"])),
            margin: EdgeInsets.only(top: 15),
          );
        }
      },
    );
  }
}
