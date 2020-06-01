import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:wakelock/wakelock.dart';

import '../../core/constants/app_constants.dart';
import '../../core/constants/app_sudoku.dart';
import '../../core/init/locale_keys.g.dart';
import '../../core/init/string_extensions.dart';
import '../../core/view/base/base_state.dart';
import '../services/database_sudoku.dart';

class SudokuGame extends StatefulWidget {
  @override
  _SudokuGameState createState() => _SudokuGameState();
}

class _SudokuGameState extends BaseState<SudokuGame> {
  final Box _sudokuBox = Hive.box('sudoku');
  final Box completedSudokuBox = Hive.box('completed_sudoku');

  // main sudoku
  List _sudoku = [];
  //steps in sudoku
  List _sudokuHistory = [];

  String _sudokuActive;

  bool _note = false;
  bool _sudokuCompleted = false;

  Timer _sayac;

  // create a sudoku for game
  void _sudokuCreate() {
    // how many blank box in game
    int inputNumber = sudokuLevel[_sudokuBox.get('level',
        defaultValue: LocaleKeys.appStrings_level2.locale)];

    // Choose one sudoku from sudoku data
    _sudokuActive = appSudoku[Random().nextInt(appSudoku.length)];
    _sudokuBox.put('sudokuActive', _sudokuActive);
    _sudokuBox.put('sudokuHistory', []);

    // create 9*9 sudoku
    _sudoku = List.generate(
      9,
      (y) => List.generate(
        9,
        (x) => "e" + _sudokuActive.substring(y * 9, (y + 1) * 9).split('')[x],
      ),
    );

    // choose blank boxes for game according to inputNumber
    int i = 0;
    while (i < 81 - inputNumber) {
      int y = Random().nextInt(9);
      int x = Random().nextInt(9);

      if (_sudoku[y][x] != "0") {
        print('y:$y / x:$x');
        print(_sudoku[y][x]);
        _sudoku[y][x] = "0";
        i++;
      }
    }

    _sudokuBox.put('sudokuRows', _sudoku);
    _sudokuBox.put('yx', "99");
    _sudokuBox.put('hint', AppConstants.HINT_NUMBER);
    _sudokuBox.put('duration', 0);

    Map historyItem = {
      'sudokuRows': _sudokuBox.get('sudokuRows'),
      'yx': _sudokuBox.get('yx'),
      'hint': _sudokuBox.get('hint'),
    };
    _sudokuHistory.add(jsonEncode(historyItem));
    _sudokuBox.put('sudokuHistory', _sudokuHistory);
  }

  // save every step
  void _saveStep() async {
    String sudokuLastState = _sudokuBox.get('sudokuRows').toString();
    if (sudokuLastState.contains("0")) {
      Map historyItem = {
        'sudokuRows': _sudokuBox.get('sudokuRows'),
        'yx': _sudokuBox.get('yx'),
        'hint': _sudokuBox.get('hint'),
      };
      _sudokuHistory.add(jsonEncode(historyItem));
      _sudokuBox.put('sudokuHistory', _sudokuHistory);
    } else {
      _sudokuActive = _sudokuBox.get('sudokuActive');
      String control = sudokuLastState.replaceAll(RegExp(r'[e, \][]'), '');
      String message = LocaleKeys.appStrings_errorSudoku.locale;

      if (control == _sudokuActive) {
        message = LocaleKeys.appStrings_congratulation.locale;
        Map completedSudoku = {
          'date': DateFormat('dd-MM-yyyy – kk:mm').format(DateTime.now()),
          'completed': _sudokuBox.get('sudokuRows'),
          'duration': _sudokuBox.get('duration'),
          'sudokuHistory': _sudokuBox.get('sudokuHistory'),
        };
        completedSudokuBox.add(completedSudoku);

        // Firebase Issues
        String dateDay = DateFormat('dd').format(DateTime.now());
        String dateMonth = DateFormat('MM').format(DateTime.now());
        String dateYear = DateFormat('yyyy').format(DateTime.now());
        int duration = _sudokuBox.get('duration');
        int level = 81-sudokuLevel[_sudokuBox.get('level')];
        int hint = _sudokuBox.get('hint');
        //calculate score
        int score=duration-(10*hint)-(level*5);

        await DatabaseSudokuService().createSudoku(userUid, dateDay, dateMonth,
            dateYear, duration,level,hint,score);

        setState(() {
          _sudokuCompleted = true;
        });
        Navigator.pop(context);
      }

      Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_LONG,
        timeInSecForIosWeb: 3,
      );
    }
  }

  @override
  void initState() {
    super.initState();
    getUserUid();
    // The following line will enable the Android and iOS wakelock.
    Wakelock.enable();
    if (_sudokuBox.get('sudokuRows') == null)
      _sudokuCreate();
    else
      _sudoku = _sudokuBox.get('sudokuRows');

    _sayac = Timer.periodic(Duration(seconds: 1), (timer) {
      int duration = _sudokuBox.get('duration');
      _sudokuBox.put('duration', ++duration);
    });
  }

  @override
  void dispose() {
    if (_sayac != null && _sayac.isActive) _sayac.cancel();
    // The next line disables the wakelock again.
    Wakelock.disable();
    if (_sudokuCompleted) {
      _sudokuBox.put('sudokuRows', null);
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(LocaleKeys.appStrings_sudokuGame.locale),
        actions: <Widget>[
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: ValueListenableBuilder<Box>(
                valueListenable: _sudokuBox.listenable(keys: ['duration']),
                builder: (context, box, _) {
                  String duration =
                      Duration(seconds: box.get('duration')).toString();
                  return Text(duration.split('.').first);
                },
              ),
            ),
          ),
        ],
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            Text(
              _sudokuBox.get('level',
                  defaultValue: LocaleKeys.appStrings_level2.locale),
              style: TextStyle(
                color: currentTheme.errorColor,
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            AspectRatio(
              aspectRatio: 1,
              child: ValueListenableBuilder<Box>(
                  valueListenable:
                      _sudokuBox.listenable(keys: ['yx', 'sudokuRows']),
                  builder: (context, box, widget) {
                    String yx = box.get('yx');
                    int yC = int.parse(yx.substring(0, 1)),
                        xC = int.parse(yx.substring(1));
                    List sudokuRows = box.get('sudokuRows');
                    return Container(
                      color: currentTheme.primaryColor,
                      padding: EdgeInsets.all(2.0),
                      margin: EdgeInsets.all(8.0),
                      child: Column(
                        children: <Widget>[
                          for (int y = 0; y < 9; y++)
                            Expanded(
                              child: Column(
                                children: <Widget>[
                                  Expanded(
                                    child: Row(
                                      children: <Widget>[
                                        for (int x = 0; x < 9; x++)
                                          Expanded(
                                            child: Row(
                                              children: <Widget>[
                                                Expanded(
                                                  child: Container(
                                                    margin: EdgeInsets.all(1.0),
                                                    color: xC == x && yC == y
                                                        ? currentTheme
                                                            .highlightColor
                                                        : currentTheme
                                                            .secondaryHeaderColor
                                                            .withOpacity(
                                                                xC == x ||
                                                                        yC == y
                                                                    ? 0.8
                                                                    : 1.0),
                                                    alignment: Alignment.center,
                                                    child:
                                                        "${sudokuRows[y][x]}"
                                                                .startsWith('e')
                                                            ? Text(
                                                                "${sudokuRows[y][x]}"
                                                                    .substring(
                                                                        1),
                                                                style: TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    fontSize:
                                                                        22.0),
                                                              )
                                                            : InkWell(
                                                                onTap: () {
                                                                  print("$y$x");
                                                                  _sudokuBox.put(
                                                                      'yx',
                                                                      "$y$x");
                                                                },
                                                                child: Center(
                                                                  child: "${sudokuRows[y][x]}"
                                                                              .length >
                                                                          8
                                                                      ? Column(
                                                                          children: <
                                                                              Widget>[
                                                                            for (int i = 0;
                                                                                i < 9;
                                                                                i += 3)
                                                                              Expanded(
                                                                                child: Row(
                                                                                  children: <Widget>[
                                                                                    for (int j = 0; j < 3; j++)
                                                                                      Expanded(
                                                                                        child: Center(
                                                                                          child: Text(
                                                                                            "${sudokuRows[y][x]}".split('')[i + j] == "0" ? "" : "${sudokuRows[y][x]}".split('')[i + j],
                                                                                            style: TextStyle(fontSize: 10.0),
                                                                                          ),
                                                                                        ),
                                                                                      ),
                                                                                  ],
                                                                                ),
                                                                              )
                                                                          ],
                                                                        )
                                                                      : Text(
                                                                          sudokuRows[y][x] != "0"
                                                                              ? sudokuRows[y][x]
                                                                              : "",
                                                                          style:
                                                                              TextStyle(fontSize: 20.0),
                                                                        ),
                                                                ),
                                                              ),
                                                  ),
                                                ),
                                                if (x == 2 || x == 5)
                                                  SizedBox(width: 2),
                                              ],
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  if (y == 2 || y == 5) SizedBox(height: 2),
                                ],
                              ),
                            ),
                        ],
                      ),
                    );
                  }),
            ),
            SizedBox(height: 8.0),
            Expanded(
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Column(
                      children: <Widget>[
                        Expanded(
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                child: Card(
                                  color: currentTheme.primaryColorLight,
                                  margin: EdgeInsets.all(8.0),
                                  child: InkWell(
                                    onTap: () {
                                      String yx = _sudokuBox.get('yx');
                                      if (yx != "99") {
                                        int yC = int.parse(yx.substring(0, 1)),
                                            xC = int.parse(yx.substring(1));
                                        _sudoku[yC][xC] = "0";
                                        _sudokuBox.put('sudokuRows', _sudoku);
                                        _saveStep();
                                      }
                                    },
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: <Widget>[
                                        Icon(
                                          Icons.delete,
                                          color: currentTheme.errorColor,
                                        ),
                                        Text(
                                          LocaleKeys.appStrings_delete.locale,
                                          style: TextStyle(
                                              color: currentTheme.errorColor),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: ValueListenableBuilder<Box>(
                                  valueListenable:
                                      _sudokuBox.listenable(keys: ['hint']),
                                  builder: (context, box, widget) {
                                    return Card(
                                      color: currentTheme.primaryColorLight,
                                      margin: EdgeInsets.all(8.0),
                                      child: InkWell(
                                        onTap: () {
                                          String yx = box.get('yx');

                                          if (yx != "99" &&
                                              box.get('hint') > 0) {
                                            int yC = int.parse(
                                                    yx.substring(0, 1)),
                                                xC = int.parse(yx.substring(1));

                                            String solutionString =
                                                box.get('sudokuActive');

                                            List solutionSudoku = List.generate(
                                              9,
                                              (i) => List.generate(
                                                9,
                                                (j) => solutionString
                                                    .substring(
                                                        i * 9, (i + 1) * 9)
                                                    .split('')[j],
                                              ),
                                            );

                                            if (_sudoku[yC][xC] !=
                                                solutionSudoku[yC][xC]) {
                                              _sudoku[yC][xC] =
                                                  solutionSudoku[yC][xC];
                                              box.put('sudokuRows', _sudoku);

                                              box.put(
                                                  'hint', box.get('hint') - 1);
                                              _saveStep();
                                            }
                                          }
                                        },
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: <Widget>[
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: <Widget>[
                                                Icon(
                                                  Icons.lightbulb_outline,
                                                  color:
                                                      currentTheme.errorColor,
                                                ),
                                                Text(
                                                  ": ${box.get('hint')}",
                                                  style: TextStyle(
                                                      color: currentTheme
                                                          .errorColor),
                                                ),
                                              ],
                                            ),
                                            Text(
                                              LocaleKeys.appStrings_hint.locale,
                                              style: TextStyle(
                                                  color:
                                                      currentTheme.errorColor),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                child: Card(
                                  color: _note
                                      ? currentTheme.primaryColorLight
                                          .withOpacity(0.6)
                                      : currentTheme.primaryColorLight,
                                  margin: EdgeInsets.all(8.0),
                                  child: InkWell(
                                    onTap: () => setState(() => _note = !_note),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: <Widget>[
                                        Icon(
                                          Icons.note_add,
                                          color: currentTheme.errorColor,
                                        ),
                                        Text(
                                          LocaleKeys.appStrings_note.locale,
                                          style: TextStyle(
                                              color: currentTheme.errorColor),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Card(
                                  color: currentTheme.primaryColorLight,
                                  margin: EdgeInsets.all(8.0),
                                  child: InkWell(
                                    onTap: () {
                                      if (_sudokuHistory.length > 0) {
                                        _sudokuHistory.removeLast();
                                        Map former =
                                            jsonDecode(_sudokuHistory.last);

                                        _sudokuBox.put(
                                            'sudokuRows', former['sudokuRows']);
                                        _sudokuBox.put('yx', former['yx']);
                                        _sudokuBox.put('hint', former['hint']);

                                        _sudokuBox.put(
                                            'sudokuHistory', _sudokuHistory);
                                        print(
                                            "formersudokuRows: ${former['sudokuRows']}");
                                      }

                                      print(
                                          "take back card: ${_sudokuHistory.length}");
                                      print(
                                          "sudokuRows: ${_sudokuBox.get('sudokuRows')}");
                                    },
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: <Widget>[
                                        Icon(
                                          Icons.undo,
                                          color: currentTheme.errorColor,
                                        ),
                                        Text(
                                          LocaleKeys.appStrings_takeBack.locale,
                                          style: TextStyle(
                                              color: currentTheme.errorColor),
                                        ),
                                        ValueListenableBuilder<Box>(
                                          valueListenable: _sudokuBox
                                              .listenable(
                                                  keys: ['sudokuHistory']),
                                          builder: (context, box, _) {
                                            print(
                                                "${box.get('sudokuHistory').length}");
                                            return Text(
                                              //"${box.get('sudokuHistory', defaultValue: []).length}",
                                              "${box.get('sudokuHistory', defaultValue: []).length - 1}",
                                              style: TextStyle(
                                                  color:
                                                      currentTheme.errorColor),
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: <Widget>[
                        for (int i = 1; i < 10; i += 3)
                          Expanded(
                            child: Row(
                              children: <Widget>[
                                for (int j = 0; j < 3; j++)
                                  Expanded(
                                    child: Card(
                                      color: currentTheme.primaryColorLight,
                                      shape: CircleBorder(),
                                      child: InkWell(
                                        onTap: () {
                                          String yx = _sudokuBox.get('yx');
                                          if (yx != "99") {
                                            int yC = int.parse(
                                                    yx.substring(0, 1)),
                                                xC = int.parse(yx.substring(1));
                                            if (!_note)
                                              _sudoku[yC][xC] = "${i + j}";
                                            else {
                                              if ("${_sudoku[yC][xC]}".length <
                                                  8)
                                                _sudoku[yC][xC] = "000000000";

                                              _sudoku[yC][xC] =
                                                  "${_sudoku[yC][xC]}"
                                                      .replaceRange(
                                                i + j - 1,
                                                i + j,
                                                "${_sudoku[yC][xC]}".substring(
                                                            i + j - 1, i + j) ==
                                                        "${i + j}"
                                                    ? "0"
                                                    : "${i + j}",
                                              );
                                            }

                                            _sudokuBox.put(
                                                'sudokuRows', _sudoku);
                                            _saveStep();
                                            print("${i + j}");
                                          }
                                        },
                                        child: Container(
                                          margin: EdgeInsets.all(3.0),
                                          alignment: Alignment.center,
                                          child: Text(
                                            "${i + j}",
                                            style: TextStyle(
                                              color: currentTheme.errorColor,
                                              fontSize: 24.0,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          )
                      ],
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
