import 'package:cloud_firestore/cloud_firestore.dart';

class MyExpenses {
   Timestamp date;
   String description;
   String expenseid;
   String ownerid;
   String price;

  MyExpenses({this.date,this.expenseid,this.description,this.ownerid,this.price});

   Map<String,dynamic> toMap(){
    return {
      'date' : date,
      'description' : description,
      'expenseid' : expenseid,
      'ownerid' : ownerid,
      'price' : price,
    };
  }
  MyExpenses.fromSnapchot(DocumentSnapshot snapshot)
      : date = snapshot['date'],
        description = snapshot['description'],
        expenseid = snapshot['expenseid'],
        ownerid = snapshot['ownerid'],
        price = snapshot['price'];

  MyExpenses.fromFirestore(Map<String, dynamic> firestore)
      : date = firestore['date'],
        description = firestore['description'],
        expenseid = firestore['expenseid'],
        ownerid = firestore['ownerid'],
        price = firestore['price'];
}