import 'package:Chatify/models/group.dart';
import 'package:Chatify/services/database_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../constants.dart';
import 'package:Chatify/screens/groups/create_new_group.dart';

class AddParticipantsPage extends StatefulWidget {
  final Groups group;
  final bool edit;
  AddParticipantsPage({
    this.group,
    this.edit,
  });

  @override
  _AddParticipantsPageState createState() => _AddParticipantsPageState();
}

class _AddParticipantsPageState extends State<AddParticipantsPage> {

  var allUsersList;
  String currentuserid;
  String currentusername;
  String currentuserphoto;
  String bottomtext = "Proceed";
  SharedPreferences preferences;


  bool loading = true;
  List participants = [];
  // List admin = [];
  @override
  void initState() {
    super.initState();
    getCurrUserId();
    if(widget.edit == true) {
      bottomtext = "Update";
      for(int i=0;i<widget.group.users.length;i++){
        participants.add(widget.group.users[i]);
        // admin.add(widget.group.admin[i]);
      }
    };
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

  void decide() async{
    final database = Provider.of<Database>(context, listen: false);
    if(widget.edit == true){
      await Firestore.instance
      .document('Groups/${widget.group.gid}/')
      .updateData({"users" : participants});

      final updatedGroup = database.getGroupData(widget.group.gid);
      Navigator.pop(context,updatedGroup);
    }else{
      Navigator.push(
          context,
          MaterialPageRoute(
            // builder: (context) => NewGroupPageAppBar(),
            builder: (context) => NewGroupPageAppBar(participants: participants,),
          ),
        );
     
    }
  }

  

  @override
  Widget build(BuildContext context) {
    // final database = Provider.of<Database>(context, listen: false);
    // participants.add(currentuserid);
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Color(0xFF6B249C),
        title: Text(
          "Add  Participants",
          style: TextStyle(
              fontFamily: 'Courgette', letterSpacing: 1.25, fontSize: 24),
        ),
      ),
      
      body : StreamBuilder(
              stream: Firestore.instance.collection("Users").snapshots(),
              builder: (context, snapshot) {
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
                } else {
                  snapshot.data.documents
                      .removeWhere((i) => i["uid"] == currentuserid);
                  allUsersList = snapshot.data.documents;
                  allUsersList.removeWhere((i) => i["uid"] == currentuserid);
                  // print(allUsersList);
                  return ListView.builder(
                    itemCount: allUsersList.length,
                    itemBuilder: (context, index) {
                      return CheckboxListTile(
                        value: participants.contains(allUsersList[index]["uid"]) ? true : false,
                        title: Text('${allUsersList[index]["name"]}'), //${users[index].lname}'),
                        // subtitle: Text(
                        //   '${users[index].email}',
                        //   style: TextStyle(color: Colors.grey[400]),
                        // ),
                        onChanged: (value) {
                          if (value == true) {
                            setState(() {
                              participants.add(allUsersList[index]["uid"]);
                            });
                          } else {
                            participants.contains(allUsersList[index]["uid"])
                                ? print(true)
                                : print(false);
                            setState(() {
                              participants.remove(allUsersList[index]["uid"]);
                            });
                          }
                          print(participants);
                        },
                        activeColor: Color(0xFF6B249C),
                      );
                    },
                  );
                }
              },
            ),
      bottomNavigationBar: GestureDetector(
        onTap: () {
          if(!participants.contains(currentuserid))  participants.add(currentuserid);
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
                  fontFamily: 'Courgette', letterSpacing: 1.25, fontSize: 24,color: Colors.white,),
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
