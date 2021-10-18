import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:splitcost/models/myUser.dart';
import 'package:splitcost/services/database.dart';

class AuthService {
  
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // create user object based on FirebasUser
  MyUser _userFromFirebaseUser(User user){
    return user != null ? MyUser(uid: user.uid) : null;
  }

  // auth change user stream
  Stream<MyUser> get user{
    return _auth.authStateChanges().map(_userFromFirebaseUser);
  }

  // sign in anon
  Future signInAnon() async {
    try {
      UserCredential result = await _auth.signInAnonymously();
      User user = result.user;
      return _userFromFirebaseUser(user);
    } catch(e){
      print(e.toString());
      return null;
    }
  }

  // sign in email & password
  Future signInWithEmailAndPassword(String email, String password) async {
    try{
      UserCredential result = await _auth.signInWithEmailAndPassword(email: email, password: password);
      User user = result.user;
      return _userFromFirebaseUser(user);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  // register with email $ password
  Future registerWithEmailAndPassword(String email, String password, String name, String phone) async {
    try{
      UserCredential result = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      User user = result.user;
      await DatabaseService(uid: user.uid).updateUserData(name, user.uid, phone, email);
      return _userFromFirebaseUser(user);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future checkIfUsernameIsAvaviable(String userName) async {
    try{
      dynamic result = await DatabaseService().checUserName(userName);
      return result;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

   Future checkIfPhoneIsAvaviable(String phone) async {
    try{
      dynamic result = await DatabaseService().checPhone(phone);
      return result;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  // sign out
  Future signOut() async {
    try{
      return await _auth.signOut();
    } catch (e){
      print(e.toString());
      return null;
    }
  }
}