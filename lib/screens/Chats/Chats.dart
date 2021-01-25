import 'package:Chatify/components/chat_for_chats_screen.dart';
import 'package:Chatify/constants.dart';
import 'package:Chatify/models/group.dart';
import 'package:Chatify/screens/groups/add_participants.dart';
import 'package:Chatify/screens/groups/showGroups.dart';
import 'package:Chatify/services/database_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../ChatDetail/ChattingPage.dart';

class ChatsPage extends StatefulWidget {
  static Widget create(BuildContext context, {String uid}) {
    return Provider<Database>(
      create: (_) => DatabaseService(),
      child: ChatsPage(),
    );
  }
  @override
  _ChatsPageState createState() => _ChatsPageState();
}

class _ChatsPageState extends State<ChatsPage> with SingleTickerProviderStateMixin {
  // List allUsers = [];
  var allUsersWithDetails = [];
  String currentuserid;
  String currentusername;
  String currentuserphoto;
  SharedPreferences preferences;
  // bool isLoading = false;

  //variables used while creating groups
  // int _indexTab;

  List<Groups> allGroups;
  int x =0;

  TabController _tabController;
  ScrollController _scrollViewController;

  @override
  initState() {
    super.initState();
    _getUsersDetails();
    _tabController = TabController(length: 2, vsync: this);
    _scrollViewController = ScrollController();
    _tabController.addListener(() {
      setState(() {
        // _indexTab = _tabController.index;
      });
      // print("Selected Index: " + _tabController.index.toString());
      // var all = Firestore.instance.collection("Groups").getDocuments().then((value) => print(value.documents[0]["description"]));
      // print("all init ${all.documents}");
    });
  }

  @override
  void dispose(){
    _tabController.dispose();
    _scrollViewController.dispose();
    super.dispose();
  }

  getCurrUserId() async {
    preferences = await SharedPreferences.getInstance();
    setState(() {
      currentuserid = preferences.getString("uid");
      currentusername = preferences.getString("name");
      currentuserphoto = preferences.getString("photo");
    });
  }

  _getUsersDetails() async {
    await getCurrUserId();
    QuerySnapshot querySnapshot =
        await Firestore.instance.collection("Users").getDocuments();

    setState(() {
      allUsersWithDetails = querySnapshot.documents;
      allUsersWithDetails
          .removeWhere((element) => element["uid"] == currentuserid);
    });
  }

  Widget peopleScreen() {
    return SingleChildScrollView(
      physics: BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          StreamBuilder(
            stream: Firestore.instance
                .collection("Users")
                .document(currentuserid)
                .collection("chatList")
                .orderBy("timestamp", descending: true)
                .snapshots(),
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
              } else if (snapshot.data.documents.length == 0) {
                return Container(
                  child: Column(
                    children: [
                      Text(
                        "No recent chats found",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "Start searching to chat",
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                    mainAxisAlignment: MainAxisAlignment.center,
                  ),
                  height: MediaQuery.of(context).copyWith().size.height -
                      MediaQuery.of(context).copyWith().size.height / 5,
                  width: MediaQuery.of(context).copyWith().size.width,
                );
              } else {
                return ListView.builder(
                  padding: EdgeInsets.only(top: 16),
                  itemCount: snapshot.data.documents.length,
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    return ChatChatsScreen(
                      data: snapshot.data.documents[index],
                    );
                  },
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget groupScreen(){
    final database = Provider.of<Database>(context, listen: true);
    // print("hello");
    
    return SingleChildScrollView(
      physics: BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            StreamBuilder<List<Groups>>(
                stream: database.getAllGroups(),
                initialData: [],
                builder: (context, snapshot) {
                  List<Groups> allGroups = snapshot.data;
                  List<Groups> groupsForCurrentUser = [];
                  if(snapshot.hasError){
                    print("=== stream has error=== ${snapshot.error}");
                  }
                  if(snapshot.hasData){
                    for(int i =0 ; i< allGroups.length; i++){
                      if (allGroups[i].users.contains('$currentuserid')) {
                        // print("Inside");
                        // groups.add(allGroups[i]);
                        groupsForCurrentUser.add(allGroups[i]);
                      }
                    }
                  }
                      // print("inside builder");
                      if (!snapshot.hasData) {
                        print("no data here");
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
                      } else if (groupsForCurrentUser.length == 0) {
                        // print("lenth 0");
                        return Container(
                          child: Column(
                            children: [
                              Text(
                                "No recent chats found",
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                "Start searching to chat",
                                style: TextStyle(fontSize: 16),
                              ),
                            ],
                            mainAxisAlignment: MainAxisAlignment.center,
                          ),
                          height: MediaQuery.of(context).copyWith().size.height -
                              MediaQuery.of(context).copyWith().size.height / 5,
                          width: MediaQuery.of(context).copyWith().size.width,
                        );
                      } else {
                        // print("groups : ${snapshot.data}");
                        // return Container();
                        return ListView.builder(
                          padding: EdgeInsets.only(top: 16),
                          itemCount: groupsForCurrentUser.length,
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            return ShowGroups(
                              group: groupsForCurrentUser[index],
                            );
                          },
                        );
                      }
                    },
              
            ),
          ],
      ),
    );
    // print("streambuilder over $allGroups and x=$x");
    // return Container(child:Text("hii"));
  }

  @override
  Widget build(BuildContext context) {
    // print("tab index ${_tabController.index}");
    return Scaffold(
      body: NestedScrollView(
        controller: _scrollViewController,
        headerSliverBuilder: (BuildContext context,bool boxIsScrolled){
          return <Widget>[
            SliverAppBar(
              actions: [
                IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () {
                    showSearch(
                        context: context,
                        delegate: DataSearch(
                            allUsersList: allUsersWithDetails,
                            currentuserid: currentuserid,
                            currentusername: currentusername,
                            currentuserphoto: currentuserphoto));
                  },
                )
              ],
              centerTitle: true,
              title: tab("Chats",24),
              pinned: true,
              floating: true,
              forceElevated: boxIsScrolled,
              bottom: TabBar(
                tabs:  <Widget>[
                  tab("Peoples",18),
                  tab("Groups",18),
                ],
                controller: _tabController,
              ),
            )
          ];
        },
        body: TabBarView(
          // physics: NeverScrollableScrollPhysics(),
          controller: _tabController,
          children: <Widget>[
            peopleScreen(),
            groupScreen(),
          ]
        ), 
        
      ),
      floatingActionButton: this._tabController.index == 1? floatingbutton() :Container(),
    );
  }
  ///////////////  build complete /////////////////////////
  ////////////// custom widgets start   /////////////////////////
  Widget tab(String text,double fontsize){
    return Tab(
      child: Text(
        text,
        style: TextStyle(
            fontFamily: 'Courgette', letterSpacing: 1.25, fontSize: fontsize),
      ),
    );
  }

  Widget floatingbutton(){
    return FloatingActionButton(
      tooltip: 'Create Group',
      heroTag: null,
      backgroundColor: Color(0xFF6F35A5),
      child: Icon(Icons.add),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            // builder: (context) => NewGroupPageAppBar(),
            builder: (context) => AddParticipantsPage(),
          ),
        );
      },
    );
  }
}

// Search Bar

class DataSearch extends SearchDelegate {
  DataSearch(
      {this.allUsersList,
      this.currentuserid,
      this.currentusername,
      this.currentuserphoto});
  var allUsersList;
  String currentuserid;
  String currentusername;
  String currentuserphoto;
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = "";
        },
      )
    ];
    // Actions for AppBar
    throw UnimplementedError();
  }

  @override
  Widget buildLeading(BuildContext context) {
    // Leading Icon on left of appBar
    return IconButton(
      icon: AnimatedIcon(
        icon: AnimatedIcons.menu_arrow,
        progress: transitionAnimation,
      ),
      onPressed: () {
        close(context, null);
      },
    );
    throw UnimplementedError();
  }

  @override
  Widget buildResults(BuildContext context) {
    // show some result based on selection

    throw UnimplementedError();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // Show when someone searches for something
    var userList = [];
    allUsersList.forEach((e) {
      userList.add(e);
    });
    var suggestionList = userList;

    if (query.isNotEmpty) {
      suggestionList = [];
      userList.forEach((element) {
        if (element["name"].toLowerCase().startsWith(query.toLowerCase())) {
          suggestionList.add(element);
        }
      });
    }
    return ListView.builder(
        itemBuilder: (context, index) => ListTile(
              onTap: () {
                close(context, null);
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return Chat(
                    receiverId: suggestionList[index]["uid"],
                    receiverAvatar: suggestionList[index]["photoUrl"],
                    receiverName: suggestionList[index]["name"],
                    currUserId: currentuserid,
                    currUserName: currentusername,
                    currUserAvatar: currentuserphoto,
                  );
                }));
              },
              leading: Icon(Icons.person),
              title: RichText(
                text: TextSpan(
                    text: suggestionList[index]["name"]
                        .toLowerCase()
                        .substring(0, query.length),
                    style: TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold),
                    children: [
                      TextSpan(
                          text: suggestionList[index]["name"]
                              .toLowerCase()
                              .substring(query.length),
                          style: TextStyle(color: Colors.grey))
                    ]),
              ),
            ),
        itemCount: suggestionList.length);
    throw UnimplementedError();
  }
}
