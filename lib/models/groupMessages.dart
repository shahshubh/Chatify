
class GroupMessages {
  final String mid;
  final String rid;
  final DateTime createdAt;
  final String createdBy;
  // final String name;
  // final bool chargeable;
  // final String eName;
  // final String problemList;
  // final String description;
  // final bool completed;

  // final String billNumber;
  // final String visitDate;
  final String timestamp;
  final String content;
  final int type;

  GroupMessages(
      {this.mid,
      this.rid,
      this.createdAt,
      this.createdBy,
      this.timestamp,
      this.content,
      this.type,
      });

  Map<String, dynamic> toMap() {
    return {
      "mid": mid,
      "rid": rid,
      "createdAt": createdAt,
      "createdBy": createdBy,
      "timestamp" : timestamp,
      "content" : content,
      "type" : type,
    };
  }

  factory GroupMessages.fromMap(Map<String, dynamic> data) {
    return GroupMessages(
      mid: data["mid"],
      rid: data["rid"],
      // createdAt: DateTime.fromMillisecondsSinceEpoch(
      //     (data["createdAt"] as Timestamp).millisecondsSinceEpoch),
      createdAt: data["createdAt"],
      createdBy: data["createdBy"],
      timestamp: data["timestamp"],
      content: data["content"],
      type: data["type"],
    );
  }
}
