import 'package:cloud_firestore/cloud_firestore.dart';

class MyGroup {

  final String groupid;
  final String groupName;
  final String ownerid;
  final List<dynamic> members;

  MyGroup({this.groupid,this.groupName,this.ownerid,this.members});

  Map<String,dynamic> toMap(){
    return {
      'groupid' : groupid,
      'groupName' : groupName,
      'members' : members,
      'ownerId' : ownerid,
    };
  }
  MyGroup.fromSnapchot(DocumentSnapshot snapshot)
      : groupid = snapshot['groupId'],
        groupName = snapshot['groupName'],
        ownerid = snapshot['ownerId'],
        members = snapshot['members'];

  MyGroup.fromFirestore(Map<String, dynamic> firestore)
      : groupid = firestore['groupId'],
        groupName = firestore['groupName'],
        ownerid = firestore['ownerId'],
        members = firestore['members'];
  
}