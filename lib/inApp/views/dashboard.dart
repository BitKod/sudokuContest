import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../core/init/locale_keys.g.dart';
import '../../core/init/string_extensions.dart';
import '../../core/view/base/base_state.dart';
import '../../core/view/widget/loading/loading.dart';
import '../models/sudoku.dart';
import '../services/database_sudoku.dart';
import '../services/database_user.dart';
import 'sudoku_game.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _DashboardState();
}

class _DashboardState extends BaseState<Dashboard> {
  Box _sudokuBox;

  Future<Box> _openSudokuBox() async {
    _sudokuBox = await Hive.openBox('sudoku');
    return await Hive.openBox('sudoku');
  }

  Future<Box> _openCompletedSudokuBox() async {
    return await Hive.openBox('completed_sudoku');
  }

  String _dateDay;
  String _dateMonth;
  String _dateYear;

  List _sudokuDaily;
  List _sudokuMonthly;
  List _sudokuYearly;


  final _kTabs = <Tab>[
    Tab(
      icon: Icon(Icons.lock),
      text: LocaleKeys.appStrings_local.locale,
    ),
    Tab(
        icon: Icon(Icons.calendar_today),
        text: LocaleKeys.appStrings_daily.locale),
    Tab(
      icon: Icon(Icons.weekend),
      text: LocaleKeys.appStrings_monthly.locale,
    ),
    Tab(
        icon: Icon(Icons.calendar_view_day),
        text: LocaleKeys.appStrings_yearly.locale),
  ];

  @override
  initState() {
    super.initState();
    getUserUid();
    _dateDay = DateFormat('dd').format(DateTime.now());
    _dateMonth = DateFormat('MM').format(DateTime.now());
    _dateYear = DateFormat('yyyy').format(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Box>(
        future: _openSudokuBox(),
        builder: (context, snapshot) {
          if (snapshot.hasData)
            return ValueListenableBuilder<Box>(
                valueListenable: snapshot.data.listenable(),
                builder: (context, box, _) {
                  return Scaffold(
                    
                    appBar: _getAppBar(),
                    backgroundColor: currentTheme.primaryColorLight,
                    body: _tabController(),
                    /* floatingActionButton: FloatingActionButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => FlutterFirebaseAnimate()),
                        );
                      },
                    ), */
                  );
                });
          return Loading();
        });
  }

  _getAppBar() {
    return AppBar(
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: EdgeInsets.only(
          left: dynamicWidth(0.02),
          right: dynamicWidth(0.02),
          top: dynamicHeight(0.01),
          bottom: dynamicHeight(0.01),
        ),
        title: ValueListenableBuilder<Box>(
            valueListenable: _sudokuBox.listenable(keys: ['sudokuRows']),
            builder: (context, box, _) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  PopupMenuButton(
                    icon: Icon(
                      Icons.computer,
                      color: Colors.white,
                      size: dynamicWidth(0.09),
                    ),
                    onSelected: (deger) {
                      if (_sudokuBox.isOpen) {
                        _sudokuBox.put('level', deger);
                        _sudokuBox.put('sudokuRows', null);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => SudokuGame()),
                        );
                      }
                    },
                    itemBuilder: (context) => <PopupMenuEntry>[
                      PopupMenuItem(
                        value: LocaleKeys.appStrings_levelChoose.locale,
                        child: Text(
                          LocaleKeys.appStrings_levelChoose.locale,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).textTheme.bodyText1.color,
                          ),
                        ),
                        enabled: false,
                      ),
                      for (String k in sudokuLevel.keys)
                        PopupMenuItem(
                          value: k,
                          child: Text(k),
                        ),
                    ],
                  ),
                  Expanded(
                    child: Text(
                      LocaleKeys.appStrings_sudokuContestApp.locale,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  if (box.isOpen && box.get('sudokuRows') != null)
                    IconButton(
                      icon: Icon(
                        Icons.play_circle_outline,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => SudokuGame()),
                        );
                      },
                    ),
                  InkWell(
                    onTap: () {
                      Navigator.pushNamed(context, '/profile');
                    },
                    child: Icon(
                      Icons.supervised_user_circle,
                      color: Colors.white,
                      size: dynamicWidth(0.09),
                    ),
                  ),
                ],
              );
            }),
      ),
    );
  }

  _tabController() {
    List<Widget> _kTabPages = <Widget>[
      _localResultTab(),
      _dailyContestResultTab(),
      _monthlyContestResultTab(),
      _yearlyContestResultTab(),
    ];
    
    return DefaultTabController(
      length: _kTabs.length,
      child: Scaffold(
        backgroundColor: currentTheme.primaryColorLight,
        appBar: TabBar(
          labelColor: Colors.blueGrey[800],
          unselectedLabelColor: Colors.blueGrey[200],
          indicatorColor: Colors.red,
          tabs: _kTabs,
        ),
        body: TabBarView(
          children: _kTabPages,
        ),
      ),
    );
  }

  _localResultTab() {
    return FutureBuilder<Box>(
      future: _openCompletedSudokuBox(),
      builder: (context, snapshot) {
        if (snapshot.hasData)
          return ValueListenableBuilder<Box>(
            valueListenable: snapshot.data.listenable(),
            builder: (context, box, _) {
              return ListView.builder(
                //reverse: true,
                itemCount: box.length,
                itemBuilder: (BuildContext context, int index) {
                  var item = box.getAt(index);
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                    color: currentTheme.primaryColorDark,
                    elevation: 8.0,
                    shadowColor: currentTheme.primaryColorLight,
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: () {
                        /* box.deleteAt(index); */
                      },
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(
                            dynamicWidth(0.05),
                            dynamicHeight(0.01),
                            dynamicWidth(0.05),
                            dynamicHeight(0.01)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: <Widget>[
                                Text(
                                  LocaleKeys.appStrings_gameDate.locale,
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  LocaleKeys.appStrings_gameDuration.locale,
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  "${item['date']}",
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  "${Duration(seconds: item['duration'])}"
                                      .split('.')
                                      .first,
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          );
        return Loading();
      },
    );
  }

  _dailyContestResultTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: DatabaseSudokuService()
          .getFilteredSudoku(_dateDay, _dateMonth, _dateYear),
      builder: (context, snapshotDaily) {
        switch (snapshotDaily.connectionState) {
          case ConnectionState.none:
          case ConnectionState.waiting:
            return Loading();
          default:
            _sudokuDaily = snapshotDaily.data.documents.map((doc) {
              return Sudoku.fromFirestore(doc);
            }).toList();
            // sort list
            _sudokuDaily.sort((a, b) => a.score.compareTo(b.score));
            return ListView.builder(
              shrinkWrap: true,
              padding: EdgeInsets.fromLTRB(
                dynamicWidth(0.05),
                dynamicHeight(0.005),
                dynamicWidth(0.05),
                dynamicHeight(0.001),
              ),
              itemCount: _sudokuDaily.length,
              itemBuilder: (context, index) {
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                  color: (_sudokuDaily[index].userUid == userUid)
                      ? currentTheme.focusColor
                      : currentTheme.primaryColorDark,
                  elevation: 8.0,
                  shadowColor: currentTheme.primaryColorLight,
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () {},
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                          dynamicWidth(0.05),
                          dynamicHeight(0.01),
                          dynamicWidth(0.05),
                          dynamicHeight(0.01)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          SizedBox(
                            width: dynamicWidth(0.05),
                            child: Text("${(index + 1).toString()}"),
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              FutureBuilder(
                                future: DatabaseUserService().getProfile(
                                    "${_sudokuDaily[index].userUid}"),
                                builder: (BuildContext context,
                                    AsyncSnapshot snapshot) {
                                  if (!snapshot.hasData) {
                                    return Loading();
                                  } else {
                                    var user = snapshot.data;
                                    return Text(
                                      LocaleKeys.appStrings_playerName.locale +
                                          " : ${user.name}",
                                      //"User Name : user.name",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                      softWrap: true,
                                    );
                                  }
                                },
                              ),
                              Text(
                                LocaleKeys.appStrings_score.locale +
                                    " : ${_sudokuDaily[index].score.toString()}",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                LocaleKeys.appStrings_gameDuration.locale +
                                    " ${_sudokuDaily[index].duration}",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                              Text(
                                LocaleKeys.appStrings_remainingHint.locale +
                                    " : ${_sudokuDaily[index].hint}",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
        }
      },
    );
  }

  _monthlyContestResultTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: DatabaseSudokuService()
          .getFilteredSudoku(null, _dateMonth, _dateYear),
      builder: (context, snapshotMonthly) {
        switch (snapshotMonthly.connectionState) {
          case ConnectionState.none:
          case ConnectionState.waiting:
            return Loading();
          default:
            _sudokuMonthly = snapshotMonthly.data.documents.map((doc) {
              return Sudoku.fromFirestore(doc);
            }).toList();
            // sort list
            _sudokuMonthly.sort((a, b) => a.score.compareTo(b.score));
            return ListView.builder(
              shrinkWrap: true,
              padding: EdgeInsets.fromLTRB(
                dynamicWidth(0.05),
                dynamicHeight(0.005),
                dynamicWidth(0.05),
                dynamicHeight(0.001),
              ),
              itemCount: _sudokuMonthly.length,
              itemBuilder: (context, index) {
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                  color: (_sudokuMonthly[index].userUid == userUid)
                      ? currentTheme.focusColor
                      : currentTheme.primaryColorDark,
                  elevation: 8.0,
                  shadowColor: currentTheme.primaryColorLight,
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () {},
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                          dynamicWidth(0.05),
                          dynamicHeight(0.01),
                          dynamicWidth(0.05),
                          dynamicHeight(0.01)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          SizedBox(
                            width: dynamicWidth(0.05),
                            child: Text("${(index + 1).toString()}"),
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              FutureBuilder(
                                future: DatabaseUserService().getProfile(
                                    "${_sudokuMonthly[index].userUid}"),
                                builder: (BuildContext context,
                                    AsyncSnapshot snapshot) {
                                  if (!snapshot.hasData) {
                                    return Loading();
                                  } else {
                                    var user = snapshot.data;
                                    return Text(
                                      LocaleKeys.appStrings_playerName.locale +
                                          " : ${user.name}",
                                      //"User Name : user.name",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                      softWrap: true,
                                    );
                                  }
                                },
                              ),
                              Text(
                                LocaleKeys.appStrings_score.locale +
                                    " : ${_sudokuMonthly[index].score.toString()}",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                LocaleKeys.appStrings_gameDuration.locale +
                                    " ${_sudokuMonthly[index].duration}",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                              Text(
                                LocaleKeys.appStrings_remainingHint.locale +
                                    " : ${_sudokuMonthly[index].hint}",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
        }
      },
    );
  }

  _yearlyContestResultTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: DatabaseSudokuService().getFilteredSudoku(null, null, _dateYear),
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
            _sudokuYearly.sort((a, b) => a.score.compareTo(b.score));
            return ListView.builder(
              shrinkWrap: true,
              padding: EdgeInsets.fromLTRB(
                dynamicWidth(0.05),
                dynamicHeight(0.005),
                dynamicWidth(0.05),
                dynamicHeight(0.001),
              ),
              itemCount: _sudokuYearly.length,
              itemBuilder: (context, index) {
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                  color: (_sudokuYearly[index].userUid == userUid)
                      ? currentTheme.focusColor
                      : currentTheme.primaryColorDark,
                  elevation: 8.0,
                  shadowColor: currentTheme.primaryColorLight,
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () {},
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                          dynamicWidth(0.05),
                          dynamicHeight(0.01),
                          dynamicWidth(0.05),
                          dynamicHeight(0.01)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          SizedBox(
                            width: dynamicWidth(0.05),
                            child: Text("${(index + 1).toString()}"),
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              FutureBuilder(
                                future: DatabaseUserService().getProfile(
                                    "${_sudokuYearly[index].userUid}"),
                                builder: (BuildContext context,
                                    AsyncSnapshot snapshot) {
                                  if (!snapshot.hasData) {
                                    return Loading();
                                  } else {
                                    var user = snapshot.data;
                                    return Text(
                                      LocaleKeys.appStrings_playerName.locale +
                                          " : ${user.name}",
                                      //"User Name : user.name",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                      softWrap: true,
                                    );
                                  }
                                },
                              ),
                              Text(
                                LocaleKeys.appStrings_score.locale +
                                    " : ${_sudokuYearly[index].score.toString()}",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                LocaleKeys.appStrings_gameDuration.locale +
                                    " ${_sudokuYearly[index].duration}",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                              Text(
                                LocaleKeys.appStrings_remainingHint.locale +
                                    " : ${_sudokuYearly[index].hint}",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
        }
      },
    );
  }
}
