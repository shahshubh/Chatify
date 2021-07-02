import 'package:Chatify/models/group.dart';
import 'package:Chatify/screens/groups/add_participants.dart';
import 'package:Chatify/screens/groups/create_new_group.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class GroupChatDetailPageAppBar extends StatelessWidget
    implements PreferredSizeWidget {

  final Groups group;

  GroupChatDetailPageAppBar({
    Key key,
 
    this.group,
  });
  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 15,
      automaticallyImplyLeading: false,
      backgroundColor: Colors.white,
      flexibleSpace: SafeArea(
        child: Container(
          padding: EdgeInsets.only(right: 16),
          child: InkWell(
             onTap: () {
              print("tap");
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => NewGroupPageAppBar(
                        group: group,
                        edit : true,
                      ),
                    ),
                  );
                },
              child: Row(
              children: <Widget>[
                IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Icon(
                    Icons.arrow_back,
                    color: Colors.black,
                  ),
                ),
                SizedBox(
                  width: 2,
                ),
                CircleAvatar(
                  backgroundImage: NetworkImage(group.photoUrl),
                  maxRadius: 20,
                ),
                SizedBox(
                  width: 12,
                ),

                Expanded(
                child:  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          group.name,
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        SizedBox(
                          height: 6,
                        ),
                        // StatusIndicator(
                        //   uid: receiverId,
                        //   screen: "chatDetailScreen",
                        // )
                        // SizedBox(
                        //       height: 5,
                        //     ),
                           
                        Text(
                          "${group.users.length} participants",
                          style: TextStyle(color: Colors.green, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                
                
              ],
            ),
          ),
        ),
      ),
      actions: [
        IconButton(
                icon: Icon(
                  // Icons.video_call,
                  Icons.add,
                  color: Colors.grey.shade700,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      // builder: (context) => NewGroupPageAppBar(),
                      builder: (context) => AddParticipantsPage(group: group,edit: true,),
                    ),
                  );
                },
                    
                    
              ),
      ],
    );
  }

  @override
  // implement preferredSize
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
