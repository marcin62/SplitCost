import 'package:cloud_firestore/cloud_firestore.dart';

class MyDetails {
   String detailid;
   String howmuch;
   String owner;
   String who;

  MyDetails({this.detailid,this.howmuch,this.owner,this.who});

   Map<String,dynamic> toMap(){
    return {
      'detailid' : detailid,
      'howmuch' : howmuch,
      'owner' : owner,
      'who' : who,
    };
  }
  MyDetails.fromSnapchot(DocumentSnapshot snapshot)
      : detailid = snapshot['detailid'],
        howmuch = snapshot['howmuch'],
        owner = snapshot['owner'],
        who = snapshot['who'];

  MyDetails.fromFirestore(Map<String, dynamic> firestore)
      : detailid = firestore['detailid'],
        howmuch = firestore['howmuch'],
        owner = firestore['owner'],
        who = firestore['who'];
}