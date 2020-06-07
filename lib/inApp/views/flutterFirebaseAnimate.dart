import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sudokuContest/core/init/locale_keys.g.dart';
import 'package:sudokuContest/core/init/string_extensions.dart';
import 'package:sudokuContest/core/view/base/base_state.dart';
import 'package:sudokuContest/core/view/widget/loading/loading.dart';
import 'package:sudokuContest/inApp/models/sudoku.dart';
import 'package:sudokuContest/inApp/services/database_sudoku.dart';
import 'package:sudokuContest/inApp/services/database_user.dart';

class FlutterFirebaseAnimate extends StatefulWidget {
  @override
  _FlutterFirebaseAnimateState createState() => _FlutterFirebaseAnimateState();
}

class _FlutterFirebaseAnimateState extends BaseState<FlutterFirebaseAnimate> {
  ScrollController controller = ScrollController();
  bool closeTopContainer = false;
  double topContainer = 0;

  String _dateDay;
  String _dateMonth;
  String _dateYear;

  List _sudokuYearly;

  @override
  void initState() {
    super.initState();
    _dateDay = DateFormat('dd').format(DateTime.now());
    _dateMonth = DateFormat('MM').format(DateTime.now());
    _dateYear = DateFormat('yyyy').format(DateTime.now());
    controller.addListener(() {
      double value = controller.offset / 119;

      setState(() {
        topContainer = value;
        closeTopContainer = controller.offset > 50;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          children: <Widget>[
            StreamBuilder<QuerySnapshot>(
              stream: DatabaseSudokuService()
                  .getFilteredSudoku(null, null, _dateYear),
              builder: (context, snapshotYearly) {
                switch (snapshotYearly.connectionState) {
                  case ConnectionState.none:
                  case ConnectionState.waiting:
                    return Loading();
                  default:
                    _sudokuYearly = snapshotYearly.data.documents.map((doc) {
                      return Sudoku.fromFirestore(doc);
                    }).toList();
                    //sorting
                    print(_sudokuYearly);
                    _sudokuYearly.sort((a, b) => a.score.compareTo(b.score));
                    return Expanded(
                      child: ListView.builder(
                        //physics: NeverScrollableScrollPhysics(),
                        controller: controller,
                        physics: BouncingScrollPhysics(),
                        shrinkWrap: true,
                        padding: EdgeInsets.fromLTRB(
                          dynamicWidth(0.05),
                          dynamicHeight(0.005),
                          dynamicWidth(0.05),
                          dynamicHeight(0.001),
                        ),
                        itemCount: _sudokuYearly.length,
                        itemBuilder: (context, index) {
                          double scale = 1.0;
                          if (topContainer > 0.5) {
                            scale = index + 0.5 - topContainer;
                            if (scale < 0) {
                              scale = 0;
                            } else if (scale > 1) {
                              scale = 1;
                            }
                          }
                          return Opacity(
                            opacity: scale,
                            child: Transform(
                              transform: Matrix4.identity()
                                ..scale(scale, scale),
                              alignment: Alignment.bottomCenter,
                              child: Align(
                                child: Align(
                                  heightFactor: 0.7,
                                  alignment: Alignment.topCenter,
                                  child: Container(
                                    height: 150,
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 10),
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(20.0)),
                                        color: Colors.white,
                                        boxShadow: [
                                          BoxShadow(
                                              color:
                                                  Colors.black.withAlpha(100),
                                              blurRadius: 10.0),
                                        ]),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 20.0, vertical: 10),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: <Widget>[
                                              FutureBuilder(
                                                future: DatabaseUserService()
                                                    .getProfile(
                                                        "${_sudokuYearly[index].userUid}"),
                                                builder: (BuildContext context,
                                                    AsyncSnapshot snapshot) {
                                                  if (!snapshot.hasData) {
                                                    return Loading();
                                                  } else {
                                                    var user = snapshot.data;
                                                    return Text(
                                                      LocaleKeys
                                                              .appStrings_playerName
                                                              .locale +
                                                          " : ${user.name}",
                                                      //"User Name : user.name",
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.black,
                                                      ),
                                                      softWrap: true,
                                                    );
                                                  }
                                                },
                                              ),
                                              Text(
                                                LocaleKeys.appStrings_score
                                                        .locale +
                                                    " : ${_sudokuYearly[index].score.toString()}",
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black,
                                                ),
                                              ),
                                              SizedBox(
                                                height: 10,
                                              ),
                                              Text(
                                                LocaleKeys
                                                        .appStrings_gameDuration
                                                        .locale +
                                                    " ${_sudokuYearly[index].duration}",
                                                style: TextStyle(
                                                    color: Colors.black,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              Text(
                                                LocaleKeys
                                                        .appStrings_remainingHint
                                                        .locale +
                                                    " : ${_sudokuYearly[index].hint}",
                                                style: TextStyle(
                                                    color: Colors.black,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ],
                                          ),
                                          SizedBox(
                                            width: dynamicWidth(0.05),
                                            child: Text(
                                              "${(index + 1).toString()}",
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
