import 'package:Chatify/models/group.dart';
import 'package:Chatify/models/user.dart';
import 'package:Chatify/services/database_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:Chatify/screens/groups/create_new_group.dart';

class AddAdminPage extends StatefulWidget {
  final Groups group;
  final bool edit;
  AddAdminPage({
    this.group,
    this.edit,
  });

  @override
  _AddAdminPageState createState() => _AddAdminPageState();
}

class _AddAdminPageState extends State<AddAdminPage> {
  var allUsersList;
  String currentuserid;
  String currentusername;
  String currentuserphoto;
  String bottomtext = "Proceed";
  SharedPreferences preferences;

  bool loading = true;
  List participants = [];
  List admin = [];
  @override
  void initState() {
    super.initState();
    getCurrUserId();
    if (widget.edit == true) {
      bottomtext = "Update";
      for (int i = 0; i < widget.group.users.length; i++) {
        participants.add(widget.group.users[i]);
        if (i < widget.group.admin.length) admin.add(widget.group.admin[i]);
      }
    }
    
    // check();
  }

  getCurrUserId() async {
    preferences = await SharedPreferences.getInstance();
    setState(() {
      currentuserid = preferences.getString("uid");
      currentusername = preferences.getString("name");
      currentuserphoto = preferences.getString("photo");
    });
  }

  void decide() async {
    final database = Provider.of<Database>(context, listen: false);
    if (widget.edit == true) {
      await Firestore.instance
          .document('Groups/${widget.group.gid}/')
          .updateData({"admin": admin});

      final updatedGroup = database.getGroupData(widget.group.gid);
      Navigator.pop(context, updatedGroup);
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          // builder: (context) => NewGroupPageAppBar(),
          builder: (context) => NewGroupPageAppBar(
            participants: participants,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final database = Provider.of<Database>(context, listen: false);
    participants.remove(currentuserid);
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Color(0xFF6B249C),
        centerTitle: true,
        title: Text(
          "Add  Admin",
          style: TextStyle(
              fontFamily: 'Courgette', letterSpacing: 1.25, fontSize: 24),
        ),
      ),
      body: ListView.builder(
          itemCount: participants.length,
          itemBuilder: (context, index) {
            return FutureBuilder<User>(
                future: database.getUserData(participants[index]),
                builder: (context, snapshot1) {
                  if (snapshot1.hasError || snapshot1.data == null) {
                    print("snapshot1 error ${snapshot1.error}");
                    return Container();
                  } else {
                    return CheckboxListTile(
                      value: admin.contains(participants[index]) ? true : false,
                      title: Text(
                          '${snapshot1.data.name}'), //${users[index].lname}'),
                      // subtitle: Text(
                      //   '${users[index].email}',
                      //   style: TextStyle(color: Colors.grey[400]),
                      // ),
                      onChanged: (value) {
                        if (value == true) {
                          setState(() {
                            admin.add(participants[index]);
                          });
                        } else {
                          admin.contains(participants[index])
                              ? print(true)
                              : print(false);
                          setState(() {
                            admin.remove(participants[index]);
                          });
                        }
                        print("admin $admin");
                      },
                      activeColor: Color(0xFF6B249C),
                    );
                  }

                  // print("snapsho1 ${snapshot1.data}");
                });
          }),
      bottomNavigationBar: GestureDetector(
        onTap: () {
          if (!participants.contains(currentuserid))
            participants.add(currentuserid);
          return decide();
        },
        child: Container(
          height: 50,
          color: Color(0xFF6B249C),
          child: Center(
              child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '$bottomtext',
                style: TextStyle(
                  fontFamily: 'Courgette',
                  letterSpacing: 1.25,
                  fontSize: 24,
                  color: Colors.white,
                ),
              ),
              SizedBox(width: 10),
              Icon(
                Icons.arrow_forward,
                size: 30,
                color: Colors.white,
              )
            ],
          )),
        ),
      ),
    );
  }
}
