import 'package:sudokuContest/core/view/base/base_stateless.dart';
import 'package:flutter/material.dart';

class TextInputCard extends BaseStatelessWidget {
  final Widget textInput;

  TextInputCard(this.textInput);

  @override
  Widget build(BuildContext context) {
    return Card(
        color: Colors.transparent,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
        ),
        child: textInput);
  }
}
