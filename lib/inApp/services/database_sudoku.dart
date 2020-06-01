import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/sudoku.dart';

class DatabaseSudokuService {
  final String uid;
  DatabaseSudokuService({this.uid});

  final CollectionReference collection = Firestore.instance.collection('users');

  //Sudoku list from snapshot

  List<Sudoku> _sudokuListFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.documents.map((doc) {
      return Sudoku.fromFirestore(doc);
    }).toList();
  }

  // get sudoku
  Stream<List<Sudoku>> get userSudoku {
    return collection
        .document(uid)
        .collection('sudoku')
        .snapshots()
        .map(_sudokuListFromSnapshot);
  }

    Stream<List<Sudoku>> get sudoku {
    return collection
        .document(uid)
        .collection('sudoku')
        .snapshots()
        .map(_sudokuListFromSnapshot);
  }

  // get filtered Sudoku
  Stream getFilteredSudoku(
    String dateDay,
    String dateMonth,
    String dateYear,
    //String level
  ) {
    return Firestore.instance.collectionGroup('sudoku')
        .where('dateDay', isEqualTo: dateDay)
        .where('dateMonth', isEqualTo: dateMonth)
        .where('dateYear', isEqualTo: dateYear)
        .snapshots();
  }

  Future createSudoku(
    String uid,
    String dateDay,
    String dateMonth,
    String dateYear,
    int duration,
    int level,
    int hint,
    int score,
  ) async {
    try {
      await collection.document(uid).collection('sudoku').document().setData({
        "userUid": uid,
        "dateDay": dateDay,
        "dateMonth": dateMonth,
        "dateYear": dateYear,
        "duration": duration,
        "level": level,
        "hint": hint,
        "score": score,
        "createdAt": FieldValue.serverTimestamp(),
        "updatedAt": FieldValue.serverTimestamp(),
      });
      return uid;
    } catch (e) {
      print('Hata oluştu!! : $e');
      //return null;
    }
  }

  Future deleteSudoku(String uid, String id) async {
    try {
      await collection
          .document(uid)
          .collection('sudoku')
          .document(id)
          .delete();
      return uid;
    } catch (e) {
      print('Hata oluştu!! : $e');
      return null;
    }
  }

}
