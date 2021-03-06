import 'package:cloud_firestore/cloud_firestore.dart';

class MyGroup {

  final String groupid;
  final String groupName;
  final String ownerid;
  final List<dynamic> members;
  final List<dynamic> prices;
  final bool iscalculated;

  MyGroup({this.groupid,this.groupName,this.ownerid,this.members,this.prices,this.iscalculated});

  Map<String,dynamic> toMap(){
    return {
      'groupid' : groupid,
      'groupName' : groupName,
      'members' : members,
      'ownerId' : ownerid,
      'prices' : prices,
      'iscalculated' : iscalculated,
    };
  }
  MyGroup.fromSnapchot(DocumentSnapshot snapshot)
      : groupid = snapshot['groupId'],
        groupName = snapshot['groupName'],
        ownerid = snapshot['ownerId'],
        members = snapshot['members'],
        prices = snapshot['prices'],
        iscalculated = snapshot['iscalculated'];

  MyGroup.fromFirestore(Map<String, dynamic> firestore)
      : groupid = firestore['groupId'],
        groupName = firestore['groupName'],
        ownerid = firestore['ownerId'],
        members = firestore['members'],
        prices = firestore['prices'],
        iscalculated = firestore['iscalculated'];
  
}