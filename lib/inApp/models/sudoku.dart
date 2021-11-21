import 'package:sudokuContest/core/model/base_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Sudoku extends BaseModel{
  Sudoku({
    this.id,
    this.userUid,
    this.dateDay,
    this.dateMonth,
    this.dateYear,
    this.duration,
    this.level,
    this.hint,
    this.score,
    this.sudokuSteps,
    this.createdAt,
    this.updatedAt,
  });

  Sudoku.fromFirestore(DocumentSnapshot document)
      : id = document.documentID,
        userUid = document['userUid'],
        dateDay = document['dateDay'],
        dateMonth = document['dateMonth'],
        dateYear = document['dateYear'],
        duration = document['duration'],
        level = document['level'],
        hint=document['hint'],
        score=document['score'],
        sudokuSteps=document['sudokuSteps'],
        createdAt = document['createdAt'],
        updatedAt = document['updatedAt'];

  final String id;
  final String userUid;
  final String dateDay;
  final String dateMonth;
  final String dateYear;
  final int duration;
  final int level;
  final int hint;
  final int score;
  final List sudokuSteps;
  final Timestamp createdAt;
  final Timestamp updatedAt;

  @override
  fromJson(Map<String, Object> json) {
    throw UnimplementedError();
  }

  @override
  Map<String, Object> toJson() {
    throw UnimplementedError();
  }
}
