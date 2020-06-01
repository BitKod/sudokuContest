import 'package:firebase_auth/firebase_auth.dart';

import '../models/user.dart';
import 'database_user.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseUserService _db = DatabaseUserService();

  User _userFromFirebaseUser(FirebaseUser user) {
    return user != null ? User(uid: user.uid) : null;
  }

  Stream<User> get user {
    return _auth.onAuthStateChanged.map(_userFromFirebaseUser);
  }

  Future<User> get currentUser async {
    FirebaseUser user= await _auth.currentUser();
    
    return _userFromFirebaseUser(user);
  }

  Future<String> get currentUserUid async {
    FirebaseUser user =
          (await FirebaseAuth.instance.currentUser());
      return user.uid;
  }

  Future logInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      FirebaseUser user =
          (await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      ))
              .user;
      return user;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future registerWithEmailAndPassword(
    String name,
    String email,
    String password,
  ) async {
    try {
      FirebaseUser user =
          (await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      )).user;
      await _db.registerUser(user.uid, name, email);
      return user;


    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future signOut() async {
    try {
      return await _auth.signOut();
    } catch (e) {
      print(e.toString());
      return null;
    }
  }
}
