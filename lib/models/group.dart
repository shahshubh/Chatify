
class Groups {
  final String gid;
  final List users;
  final List admin;
  final String name;
  final String photoUrl;
  // final int rid;
  final String lastMessageTime;
  final String description;
  final String lastMessage;
  final int lastMessageType;
  final String lastSender;

  Groups(
      {this.gid,
      this.users,
      this.admin,
      this.name,
      this.photoUrl,
      // this.rid = 1,
      this.lastMessageTime,
      this.description = "",
      this.lastMessage,
      this.lastSender,
      this.lastMessageType,});

  Map<String, dynamic> toMap() {
    return {
      'gid': gid,
      'users': users,
      'admin': admin,
      'name': name,
      'photoUrl': photoUrl,
      // 'rid': rid,
      'lastMessageTime': lastMessageTime,
      'description' : description,
      'lastMessage' : lastMessage,
      'lastSender' : lastSender,
      'lastMessageType' : lastMessageType,
    };
  }

  factory Groups.fromMap(Map<dynamic, dynamic> data) {
    return Groups(
      gid: data["gid"],
      users: data["users"],
      admin: data["admin"],
      name: data["name"],
      photoUrl: data["photoUrl"],
      // rid: data["rid"],
      // lastMessageTime: data["lastMessageTime"] == null
      //     ? null
      //     : DateTime.fromMillisecondsSinceEpoch(
      //     (data["lastMessageTime"] as Timestamp).millisecondsSinceEpoch),
      lastMessageTime: data["lastMessageTime"],
      description: data["description"],
      lastMessage: data["lastMessage"],
      lastSender: data["lastSender"],
      lastMessageType : data["lastMessageType"],
    );
  }
}
