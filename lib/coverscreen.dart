import 'package:flutter/material.dart';

class MyCoverScreen extends StatelessWidget {
  final bool gameHasStarted;

  MyCoverScreen({required this.gameHasStarted});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 90),
      alignment: Alignment.bottomCenter,
      child: Text(
        gameHasStarted ? '' : 'TAP TO PLAY',
        style: const TextStyle(color: Colors.white, fontSize: 18),
      ),
    );
  }
}
