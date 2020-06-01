import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/user.dart';


class DatabaseUserService {
    final String uid;
  DatabaseUserService({this.uid});

  final CollectionReference collection = Firestore.instance.collection('users');


  Future registerUser(String uid, String name, String email) async {
    try {
      return await collection.document(uid).setData({
        "name": name,
        "email": email,
        "createdAt": FieldValue.serverTimestamp(),
        "updatedAt": FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Hata oluştu!! : $e');
    }
  }

  Future getProfile(String uid) async {
    try {
      DocumentSnapshot result =
          await Firestore.instance
          .collection('users')
          .document(uid)
          .get();

          if(result.exists) {
            return User.fromFirestore(result);
          }
    } catch (e) {
      print('Hata oluştu!! : $e');
    }
  }

  Future editProfile(String uid, String name, String userImage) async {
    try {
      return await collection.document(uid).updateData({
        "name": name,
        "userImage" : userImage,
        "updatedAt": FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Hata oluştu!! : $e');
    }
  }

 
}
