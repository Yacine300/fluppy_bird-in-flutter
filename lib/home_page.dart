// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'dart:async';
import 'package:flappy_bard/barriers.dart';
import 'package:flappy_bard/bird.dart';
import 'package:flappy_bard/coverscreen.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:just_audio/just_audio.dart';
import 'DbHelper/Db_helper.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  //

  // bird variables
  static double birdY = 0;
  double initialPos = birdY;
  late double height;
  late double time;
  // double shipPosition = 0.5;
  late double gravity; // how strong the gravity is
  late double velocity; // how strong the jump is

  late AnimationController _controller;

  // game variables settings
  bool gameHasStarted = false;
  late double? score;
  int? record = 0;
  late List<List<double>> barrierHeight;

  // music variable
  late AudioPlayer audioPlayer;
  //late AudioPlayer jumpPlayer;

  // barrier variables
  static List<double> barrierX = [3, 3 + 1, 4 + 1];
  static double barrierWidth = 0.45; // out of 2

  getIntValue() async {
    record = await DBHelper.getRecord();
  }

  @override
  void initState() {
    super.initState();

    getIntValue();

    _controller = AnimationController(
      duration: Duration(seconds: 60), // Adjust the rotation speed as needed
      vsync: this,
    )..repeat();

    initialPos = birdY;
    height = 0;
    time = 0.11;

    gravity = -1;
    velocity = 0.7;

    audioPlayer = AudioPlayer();
    //jumpPlayer = AudioPlayer();
    playBackgroundAudioFromAssets();
    luchOnce();

    barrierHeight = [
      // out of 2, where 2 is the entire height of the screen
      // [topHeight, bottomHeight]
      [.5, 1.27],
      [1.17, .6],
      [.97, .8],
    ];
  }

  Future<void> playBackgroundAudioFromAssets() async {
    await audioPlayer
        .setAudioSource(AudioSource.asset('assets/files/Gamemusic.mp3'))
        .then((_) =>
            audioPlayer.setVolume(0.05).then((value) => audioPlayer.play()));
  }

  /*Future<void> jumpSoundEffect() async {
    await jumpPlayer
        .setAudioSource(AudioSource.asset('assets/files/jump.mp3'))
        .then((_) => jumpPlayer.play());
  }*/

  void startGame() {
    gameHasStarted = true;

    Timer.periodic(Duration(milliseconds: 10), (timer) {
      // a real physical jump is the same as an upside down parabola
      // so this is a simple quadratic equation

      height = gravity * time * time + velocity * time;
      birdY = initialPos - height;

      /* setState(() {
        shipPosition -= 0.0005;
      });*/

      // check if bird is dead
      if (birdIsDead()) {
        timer.cancel();
        _showDialog();
      }

      // keep the map moving (move barriers)

      // keep barriers moving

      barrierX[0] -= 0.01;
      barrierX[1] -= 0.01;
      barrierX[2] -= 0.01;

      // if barrier exits the left part of the screen, keep it looping
      if (barrierX[0] < -1.5) {
        barrierX[0] += 3;
      }

      if (barrierX[1] < -1.5) {
        barrierX[1] += 3;
      }

      if (barrierX[2] < -1.5) {
        barrierX[2] += 3;
      }

      // add 1 to score
      if ((((barrierX[0] > -0.1) && (barrierX[0] < 0.1)) ||
              ((barrierX[1] > -0.1) && (barrierX[1] < 0.1))) &&
          !birdIsDead()) {
        setState(() {
          score = score! + 0.054421;
        });
      }
      // keep the time going!
      setState(() {
        time += 0.02;
      });
    });
  }

  void resetGame() {
    Navigator.pop(context); // dismisses the alert dialog
    // databaseHelper.insertIntValue(record!);
    setState(() {
      //  shipPosition = 0.5;

      birdY = 0;
      score = 0;
      height = 0;
      gameHasStarted = false;
      time = .2;
      initialPos = birdY;
      barrierX = [3, 3 + 1, 4 + 1];
    });
  }

  void luchOnce() {
    setState(() {
      //  shipPosition = 0.5;
      birdY = 0;
      score = 0;
      height = 0;
      gameHasStarted = false;
      time = .2;
      initialPos = birdY;
      barrierX = [3, 3 + 1, 4 + 1];
    });
  }

  void _showDialog() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Colors.brown,
            title: Center(
              child: Text(
                "GAME  OVER",
                style: TextStyle(color: Colors.white),
              ),
            ),
            actions: [
              GestureDetector(
                onTap: resetGame,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: Container(
                    padding: EdgeInsets.all(7),
                    color: Colors.white,
                    child: Text(
                      'PLAY AGAIN',
                      style: TextStyle(color: Colors.brown),
                    ),
                  ),
                ),
              )
            ],
          );
        });
  }

  void jump() {
    // jumpSoundEffect;

    time = 0.11;
    initialPos = birdY;
  }

  bool birdIsDead() {
    // check if the bird is hitting the top or the bottom of the screen
    if (birdY < -1 || birdY > 1) {
      record = score!.toInt();

      DBHelper.insertNewRecord(record!);
      return true;
    }

    // hits barriers
    // checks if bird is within x coordinates and y coordinates of barriers
    for (int i = 0; i < barrierX.length; i++) {
      if (barrierX[i] <= 0.1 &&
          barrierX[i] + barrierWidth >= -0.1 &&
          (birdY <= -1.1 + barrierHeight[i][0] ||
              birdY + 0.1 >= 1.1 - barrierHeight[i][1])) {
        record = score!.toInt();

        DBHelper.insertNewRecord(record!);
        return true;
      }
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        //  await databaseHelper.insertIntValue(record!);
        DBHelper.insertNewRecord(record!);
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Column(
          children: [
            Expanded(
              flex: 4,
              child: GestureDetector(
                onTap: gameHasStarted ? jump : startGame,
                child: Container(
                  decoration: BoxDecoration(
                      color: Colors.black,
                      image: DecorationImage(
                          image: AssetImage('assets/images/sky4.gif'),
                          fit: BoxFit.cover)),
                  child: Center(
                    child: Stack(
                      children: [
                        Transform.rotate(
                          angle: _controller.value,
                          child: Container(
                            height: 300,
                            alignment: Alignment(-0.8, -1.8),
                            child: Image.asset(
                              'assets/images/moon.png',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        /* Transform.rotate(
                          angle: shipPosition * 20 * (3.14159265359 / 180),
                          child: Container(
                            height: 100,
                            alignment: Alignment(shipPosition * 2, shipPosition),
                            child: Image.asset(
                              'assets/images/fall.png',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),*/

                        // bird
                        MyBird(
                          birdY: birdY,
                          birdWidth: 0.1,
                          birdHeight: 0.1,
                        ),

                        // tap to play
                        MyCoverScreen(gameHasStarted: gameHasStarted),

                        // Builder(
                        //   builder: (BuildContext context) {
                        //     for (int i = 0; i < barrierX.length; i++) {
                        //       for (int ) {
                        //         return MyBarrier(
                        //         barrierX: barrierX[i],
                        //         barrierWidth: barrierWidth,
                        //         barrierHeight: barrierHeight[i][0],
                        //         isThisBottomBarrier: false,
                        //       );
                        //       }
                        //     }
                        //     return Container();
                        //   },
                        // ),

                        // Top barrier 0
                        MyBarrier(
                          barrierX: barrierX[0],
                          barrierWidth: barrierWidth,
                          barrierHeight: barrierHeight[0][0],
                          isThisBottomBarrier: false,
                          flip: false,
                        ),

                        // Bottom barrier 0
                        MyBarrier(
                          barrierX: barrierX[0],
                          barrierWidth: barrierWidth,
                          barrierHeight: barrierHeight[0][1],
                          isThisBottomBarrier: true,
                          flip: true,
                        ),

                        // Top barrier 1
                        MyBarrier(
                          barrierX: barrierX[1],
                          barrierWidth: barrierWidth,
                          barrierHeight: barrierHeight[1][0],
                          isThisBottomBarrier: false,
                          flip: false,
                        ),

                        // Bottom barrier 1
                        MyBarrier(
                          barrierX: barrierX[1],
                          barrierWidth: barrierWidth,
                          barrierHeight: barrierHeight[1][1],
                          isThisBottomBarrier: true,
                          flip: true,
                        ),
                        MyBarrier(
                          barrierX: barrierX[2],
                          barrierWidth: barrierWidth,
                          barrierHeight: barrierHeight[2][0],
                          isThisBottomBarrier: false,
                          flip: false,
                        ),

                        // Bottom barrier 1
                        MyBarrier(
                          barrierX: barrierX[2],
                          barrierWidth: barrierWidth,
                          barrierHeight: barrierHeight[2][1],
                          isThisBottomBarrier: true,
                          flip: true,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SecondPart(
              score: score!.toInt(),
              record: record!,
            )
          ],
        ),
      ),
    );
  }
}

class SecondPart extends StatelessWidget {
  final int score;
  final int record;
  const SecondPart({
    required this.score,
    required this.record,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
        flex: 1,
        child: Stack(
          children: [
            Column(
              children: [FirstLigne(), OneLigne(), OneLigne()],
            ),
            GameInfo(score: score, record: record),
          ],
        ));
  }
}

class FirstLigne extends StatelessWidget {
  const FirstLigne({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          height: 20,
          width: MediaQuery.of(context).size.width / 3,
          color: Colors.black,
          child: Image.asset(
            'assets/images/ground.png',
            fit: BoxFit.fitWidth,
          ),
        ),
        Container(
          height: 20,
          width: MediaQuery.of(context).size.width / 3,
          color: Colors.blue,
          child: Image.asset(
            'assets/images/ground.png',
            fit: BoxFit.fitWidth,
          ),
        ),
        Container(
          height: 20,
          width: MediaQuery.of(context).size.width / 3,
          color: Colors.blue,
          child: Image.asset(
            'assets/images/ground.png',
            fit: BoxFit.fitWidth,
          ),
        ),
      ],
    );
  }
}

class OneLigne extends StatelessWidget {
  const OneLigne({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.width / 6,
          width: MediaQuery.of(context).size.width / 5,
          child: Image.asset(
            'assets/images/ground2.png',
            fit: BoxFit.cover,
          ),
        ),
        SizedBox(
          height: MediaQuery.of(context).size.width / 6,
          width: MediaQuery.of(context).size.width / 5,
          child: Image.asset(
            'assets/images/ground2.png',
            fit: BoxFit.cover,
          ),
        ),
        SizedBox(
          height: MediaQuery.of(context).size.width / 6,
          width: MediaQuery.of(context).size.width / 5,
          child: Image.asset(
            'assets/images/ground2.png',
            fit: BoxFit.cover,
          ),
        ),
        SizedBox(
          height: MediaQuery.of(context).size.width / 6,
          width: MediaQuery.of(context).size.width / 5,
          child: Image.asset(
            'assets/images/ground2.png',
            fit: BoxFit.cover,
          ),
        ),
        SizedBox(
          height: MediaQuery.of(context).size.width / 6,
          width: MediaQuery.of(context).size.width / 5,
          child: Image.asset(
            'assets/images/ground2.png',
            fit: BoxFit.cover,
          ),
        ),
      ],
    );
  }
}

class GameInfo extends StatelessWidget {
  final int score;
  final int record;
  const GameInfo({
    required this.score,
    required this.record,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Score',
                style: TextStyle(
                    fontFamily: 'Game', color: Colors.white, fontSize: 18),
              ),
              SizedBox(
                height: 20,
              ),
              Text(
                score.toString(),
                style: TextStyle(
                    fontFamily: 'Game', color: Colors.white, fontSize: 22),
              )
            ],
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Record',
                style: TextStyle(
                    fontFamily: 'Game', color: Colors.white, fontSize: 18),
              ),
              SizedBox(
                height: 20,
              ),
              Text(
                record.toString(),
                style: TextStyle(
                    fontFamily: 'Game', color: Colors.white, fontSize: 22),
              )
            ],
          )
        ],
      ),
    );
  }
}
