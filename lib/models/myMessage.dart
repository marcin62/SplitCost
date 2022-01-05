import 'package:cloud_firestore/cloud_firestore.dart';

class MyMessage {
   Timestamp date;
   String groupid;
   String message;
   bool see;
   String messageid;

  MyMessage({this.date,this.groupid,this.message});

   Map<String,dynamic> toMap(){
    return {
      'groupid' : groupid,
      'date' : date,
      'message' : message,
      'see' : see,
      'messageid' : messageid,
    };
  }
  MyMessage.fromSnapchot(DocumentSnapshot snapshot)
      : date = snapshot['date'],
        groupid = snapshot['groupid'],
        message = snapshot['message'],
        see = snapshot['see'],
        messageid = snapshot['messageid'];

  MyMessage.fromFirestore(Map<String, dynamic> firestore)
      : date = firestore['date'],
        groupid = firestore['groupid'],
        message = firestore['message'],
        see = firestore['see'],
        messageid = firestore['messageid'];
}