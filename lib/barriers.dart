// ignore_for_file: prefer_typing_uninitialized_variables, prefer_const_constructors_in_immutables, use_key_in_widget_constructors

import 'package:flutter/material.dart';

class MyBarrier extends StatelessWidget {
  final barrierWidth; // out of 2, where 2 is the width of the screen
  final barrierHeight; // proportion of the screenheight
  final barrierX;
  final bool isThisBottomBarrier;
  bool flip;

  MyBarrier(
      {this.barrierHeight,
      this.barrierWidth,
      required this.flip,
      required this.isThisBottomBarrier,
      this.barrierX});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 0),
      curve: Curves.linear,
      alignment: Alignment((2 * barrierX + barrierWidth) / (2 - barrierWidth),
          isThisBottomBarrier ? 1 : -1),
      child: RotatedBox(
        quarterTurns: !flip ? 2 : 0,
        child: Container(
          width: MediaQuery.of(context).size.width * barrierWidth / 2,
          height:
              MediaQuery.of(context).size.height * 3 / 4 * barrierHeight / 2,
          decoration: const BoxDecoration(
            image: DecorationImage(
                image: AssetImage(
                  'assets/images/flame.gif',
                ),
                fit: BoxFit.cover),
          ),
        ),
      ),
    );
  }
}
