import 'package:Chatify/constants.dart';
import 'package:Chatify/widgets/ProgressWidget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class LogListContainer extends StatefulWidget {
  final String currentuserid;
  LogListContainer({@required this.currentuserid});

  @override
  _LogListContainerState createState() => _LogListContainerState();
}

class _LogListContainerState extends State<LogListContainer> {
  getIcon(String callStatus) {
    Icon _icon;
    double _iconSize = 15;

    switch (callStatus) {
      case CALL_STATUS_DIALLED:
        _icon = Icon(
          Icons.call_made,
          size: _iconSize,
          color: Colors.green,
        );
        break;

      case CALL_STATUS_MISSED:
        _icon = Icon(
          Icons.call_missed,
          color: Colors.red,
          size: _iconSize,
        );
        break;

      default:
        _icon = Icon(
          Icons.call_received,
          size: _iconSize,
          color: Colors.grey,
        );
        break;
    }

    return Container(
      margin: EdgeInsets.only(right: 5),
      child: _icon,
    );
  }

  @override
  Widget build(BuildContext context) {
    return widget.currentuserid == null
        ? oldcircularprogress()
        : FutureBuilder(
            future: Firestore.instance
                .collection("Users")
                .document(widget.currentuserid)
                .collection("callLogs")
                .orderBy("timestamp", descending: true)
                .getDocuments(),
            builder: (BuildContext context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return oldcircularprogress();
              }

              if (snapshot.hasData) {
                if (snapshot.data.documents.length > 0) {
                  return ListView.builder(
                    physics: BouncingScrollPhysics(),
                    itemCount: snapshot.data.documents.length,
                    itemBuilder: (context, i) {
                      var _log = snapshot.data.documents[i];
                      bool hasDialled =
                          _log["callStatus"] == CALL_STATUS_DIALLED;

                      return InkWell(
                        onLongPress: () => showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                                  title: Text("Delete this Log?"),
                                  content: Text(
                                      "Are you sure you want to delete this log?"),
                                  actions: [
                                    FlatButton(
                                      child: Text("YES"),
                                      onPressed: () async {
                                        Navigator.pop(context);
                                        Firestore.instance
                                            .collection("Users")
                                            .document(widget.currentuserid)
                                            .collection("callLogs")
                                            .document(_log["timestamp"])
                                            .delete();
                                        if (mounted) {
                                          setState(() {});
                                        }
                                      },
                                    ),
                                    FlatButton(
                                      child: Text("NO"),
                                      onPressed: () => Navigator.pop(context),
                                    ),
                                  ],
                                )),
                        child: Container(
                          padding: EdgeInsets.only(
                              left: 16, right: 16, top: 10, bottom: 10),
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                child: Row(
                                  children: <Widget>[
                                    Stack(
                                      children: [
                                        CircleAvatar(
                                          backgroundImage: NetworkImage(
                                              hasDialled
                                                  ? _log["receiverPic"]
                                                  : _log["callerPic"]),
                                          maxRadius: 30,
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      width: 16,
                                    ),
                                    Expanded(
                                      child: Container(
                                        color: Colors.transparent,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Text(hasDialled
                                                ? _log["receiverName"]
                                                : _log["callerName"]),
                                            SizedBox(
                                              height: 6,
                                            ),
                                            Row(
                                              children: [
                                                getIcon(_log["callStatus"]),
                                                Text(
                                                  DateFormat(
                                                          "dd MMMM yyy hh:mm aa")
                                                      .format(DateTime.parse(
                                                          _log["timestamp"])),
                                                  style: TextStyle(
                                                      fontSize: 14,
                                                      color:
                                                          Colors.grey.shade500,
                                                      fontStyle:
                                                          FontStyle.italic),
                                                )
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }
                return Container(
                  child: Column(
                    children: [
                      Text(
                        "This is where all your call logs are listed",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "Call people with just one click",
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                    mainAxisAlignment: MainAxisAlignment.center,
                  ),
                  height: MediaQuery.of(context).copyWith().size.height -
                      MediaQuery.of(context).copyWith().size.height / 5,
                  width: MediaQuery.of(context).copyWith().size.width,
                );
              }

              return Container(
                child: Column(
                  children: [
                    Text(
                      "This is where all your call logs are listed",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "Video Call people with just one click",
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                  mainAxisAlignment: MainAxisAlignment.center,
                ),
                height: MediaQuery.of(context).copyWith().size.height -
                    MediaQuery.of(context).copyWith().size.height / 5,
                width: MediaQuery.of(context).copyWith().size.width,
              );
            },
          );
  }
}
