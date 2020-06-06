import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:sudokuContest/inApp/services/database_user.dart';
import 'package:wakelock/wakelock.dart';

import '../../core/init/locale_keys.g.dart';
import '../../core/init/string_extensions.dart';
import '../../core/view/base/base_state.dart';

class SudokuGameReplay extends StatefulWidget {
  final List sudokuSteps;
  final String uid;
  SudokuGameReplay({this.sudokuSteps,this.uid});

  @override
  _SudokuGameReplayState createState() => _SudokuGameReplayState();
}

class _SudokuGameReplayState extends BaseState<SudokuGameReplay> {
  Box _sudokuReplayBox=Hive.box('sudokuReplay');

// main sudoku
  List _sudoku = [];
  String _sudokuActive;

// create 9*9 sudoku
  List _generateSudoku() {
    return List.generate(
      9,
      (y) => List.generate(
        9,
        (x) =>((_sudokuActive.substring(y * 9, (y + 1) * 9).split('')[x])=="0")? "": "e" + _sudokuActive.substring(y * 9, (y + 1) * 9).split('')[x],
      ),
    );
  }

  // create a sudoku for game
  void _sudokuCreate() {
    // Choose first sudoku from sudoku history
    _sudokuActive = _sudokuReplayBox.get('sudokuSteps')[0];
    print("sudokuActive: $_sudokuActive");
    _sudokuReplayBox.put('sudokuActive', _sudokuActive);
    //_sudokuReplayBox.put('sudokuHistory', widget.sudokuSteps);
    _sudokuReplayBox.put('sudokuHistoryStep', 0);

    // create 9*9 sudoku
    _sudoku = _generateSudoku();
    _sudokuReplayBox.put('sudoku', _sudoku);
    print("_sudoku: $_sudoku");

  }

  _getUserName(userUid) async {
    var user = await DatabaseUserService().getProfile(userUid);
    _sudokuReplayBox.put('userName', user.name);
  }

  @override
  void initState() {
    super.initState();
    getUserUid();
    _getUserName(_sudokuReplayBox.get('userUid'));
    // The following line will enable the Android and iOS wakelock.
    Wakelock.enable();
      _sudokuCreate();
  }

  @override
  void dispose() {
    Wakelock.disable();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _getAppBar(),
      body: Column(
        children: <Widget>[
          SizedBox(height: dynamicHeight(0.005)),
          _getGameHeader(),
          _getGameArea(),
          SizedBox(height: dynamicHeight(0.005)),
          sudokuButtonArea(),
        ],
      ),
    );
  }

  AppBar _getAppBar() {
    return AppBar(
      title: Padding(
        padding: EdgeInsets.only(left: dynamicWidth(0.15)),
        child: Text(LocaleKeys.appStrings_sudokuReplay.locale),
      ),
    );
  }

  Widget _getGameHeader() {
    return Text(
      _sudokuReplayBox.get('userName').toUpperCase(),
      style: TextStyle(
        color: currentTheme.errorColor,
        fontSize: 24.0,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _getGameArea() {
    return AspectRatio(
      aspectRatio: 1,
      child: ValueListenableBuilder<Box>(
          valueListenable: _sudokuReplayBox.listenable(keys: ['sudoku']),
          builder: (context, box, widget) {
            List sudoku = box.get('sudoku');

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
                                            color:("${sudoku[y][x]}"
                                                        .startsWith('e'))?
                                            currentTheme.secondaryHeaderColor
                                                    .withOpacity(0.5):
                                                    currentTheme.secondaryHeaderColor
                                                    .withOpacity(0.9),
                                            alignment: Alignment.center,
                                            child:
                                                "${sudoku[y][x]}"
                                                        .startsWith('e')
                                                    ? Text(
                                                        "${sudoku[y][x]}"
                                                            .substring(1),
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 22.0),
                                                      )
                                                    : Text(" "),
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
    );
  }

  Widget sudokuButtonArea() {
    return ValueListenableBuilder<Box>(
          valueListenable: _sudokuReplayBox.listenable(keys: ['sudokuSteps','sudokuHistoryStep']),
          builder: (context, box, widget) {
        List _sudokuSteps = box.get('sudokuSteps');
        int _sudokuHistoryStep = box.get('sudokuHistoryStep');
        int _newSudokuHistoryStep;
        return Expanded(
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
                                  if (_sudokuHistoryStep != 0) {
                                    _newSudokuHistoryStep=_sudokuHistoryStep-1;
                                    _sudokuActive=_sudokuSteps[_newSudokuHistoryStep];
                                    _sudoku = _generateSudoku();
                                    _sudokuReplayBox.put('sudoku', _sudoku);
                                    _sudokuReplayBox.put('sudokuActive', _sudokuActive);
                                    _sudokuReplayBox.put('sudokuHistoryStep', _newSudokuHistoryStep);
                                  }
                                },
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Icon(
                                      Icons.undo,
                                      color: currentTheme.errorColor,
                                    ),
                                    Text(
                                      LocaleKeys.appStrings_takeBack.locale,
                                      style:
                                          TextStyle(color: currentTheme.errorColor),
                                    ),
                                    Text(
                                      "$_sudokuHistoryStep",
                                      style:
                                          TextStyle(color: currentTheme.errorColor),
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
                                if (_sudokuHistoryStep != (_sudokuSteps.length-1)) {
                                    _newSudokuHistoryStep=_sudokuHistoryStep+1;
                                    _sudokuActive=_sudokuSteps[_newSudokuHistoryStep];
                                    _sudoku = _generateSudoku();
                                    _sudokuReplayBox.put('sudoku', _sudoku);
                                    _sudokuReplayBox.put('sudokuActive', _sudokuActive);
                                    _sudokuReplayBox.put('sudokuHistoryStep', _newSudokuHistoryStep);
                                  }
                                },
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Icon(
                                      Icons.redo,
                                      color: currentTheme.errorColor,
                                    ),
                                    Text(
                                      LocaleKeys.appStrings_pushForward.locale,
                                      style:
                                          TextStyle(color: currentTheme.errorColor),
                                    ),
                                    Text(
                                      "${_sudokuSteps.length-_sudokuHistoryStep-1}",
                                      style:
                                          TextStyle(color: currentTheme.errorColor),
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
              ],
          ),
        );
      }
    );
  }
}
