
import 'package:sudokuContest/core/model/base_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class User extends BaseModel{
  final String uid;
  final String name;
  final String email;
  final String userImage;
  final createdAt;
  final updatedAt;


  User({
    this.uid,
    this.name,
    this.email,
    this.userImage,
    this.createdAt,
    this.updatedAt
  });

  User.fromFirestore(DocumentSnapshot document)
      : uid = document.documentID,
        name = document['name'],
        email = document['email'],
        userImage = document['userImage'],
        createdAt = document['createdAt'],
        updatedAt = document['updatedAt'];

  @override
  fromJson(Map<String, Object> json) {
    throw UnimplementedError();
  }

  @override
  Map<String, Object> toJson() {
    throw UnimplementedError();
  }
  
}
  

