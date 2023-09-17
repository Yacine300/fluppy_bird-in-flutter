import 'package:flappy_bard/home_page.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class Init extends StatefulWidget {
  const Init({super.key});

  @override
  State<Init> createState() => _InitState();
}

class _InitState extends State<Init> {
  late VideoPlayerController videoController;
  late Future<void> initializeVideoPlayerFuture;
  String videoPath = 'assets/files/intro.mp4';

  @override
  void initState() {
    super.initState();
    videoController = VideoPlayerController.asset(videoPath);
    initializeVideoPlayerFuture = videoController.initialize();
    videoController.setLooping(false);
    videoController.play();
    videoController.addListener(() {
      if (videoController.value.position >= const Duration(seconds: 18)) {
        videoController.dispose();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      }
    });
  }

  @override
  void dispose() {
    videoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Center(
          child: SizedBox(
            height: MediaQuery.of(context).size.width,
            width: MediaQuery.of(context).size.width,
            child: FutureBuilder(
              future: initializeVideoPlayerFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return AspectRatio(
                    aspectRatio: videoController.value.aspectRatio,
                    child: VideoPlayer(videoController),
                  );
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}
