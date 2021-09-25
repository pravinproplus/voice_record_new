// Import package
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'dart:io';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:permission_handler/permission_handler.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  //variable declaration
  final recorder = Record();
  bool _play = false;
  bool _record = false;
  String filePath = '/storage/emulated/0/Download/audio.m4a';
  TextEditingController cmnt = TextEditingController();
  Duration duration = const Duration();
  Duration position = const Duration();
  final audioPlayer = AssetsAudioPlayer();

  @override
  void initState() {
    start();
    super.initState();
  }

  // Check and request permission
  Future start() async {
    await Permission.microphone.request();
    await Permission.storage.request();
    await Permission.manageExternalStorage.request();
  }

  //start record method
  Future startRecord() async {
    try {
      await recorder.start(path: filePath);
    } catch (e) {
      return SnackBar(
        content: Text(e.toString()),
      );
    }
  }

  //stop record method
  Future stopRecord() async {
    await recorder.stop();
  }

  //file delete method
  void delete() {
    final dir = Directory(filePath);
    dir.deleteSync(recursive: true);
  }

  //audio play method
  Future<void> startPlaying() async {
    audioPlayer.open(
      Audio.file(filePath),
      autoStart: true,
      showNotification: true,
    );
    audioPlayer.current;
    audioPlayer.current.listen((playingAudio) {
      final songDuration = playingAudio!.audio.duration;

      setState(() {
        duration = songDuration;
      });
    });
    audioPlayer.currentPosition.listen((event) {
      setState(() {
        position = event;
      });
    });
  }

//stop playing method
  Future<void> stopPlaying() async {
    audioPlayer.stop();
  }

  @override
  Widget build(BuildContext context) {
    double h = MediaQuery.of(context).size.height;
    double w = MediaQuery.of(context).size.width;
    return Scaffold(
      floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.delete),
          onPressed: () {
            delete();
          }),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              height: h / 12,
              width: w / 1.2,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(3.0),
                  child: Row(
                    children: [
                      SizedBox(
                        height: h / 15,
                        width: w / 8,
                        child: IconButton(
                          iconSize: 30.0,
                          onPressed: () {
                            setState(() {
                              _play = !_play;
                            });
                            if (_play) {
                              startPlaying();
                            }

                            if (!_play) {
                              stopPlaying();
                            }
                          },
                          icon: _play == false
                              ? const Icon(Icons.play_arrow)
                              : const Icon(Icons.pause),
                        ),
                      ),
                      Slider.adaptive(
                          min: 00.0,
                          max: duration.inSeconds.toDouble(),
                          value: position.inSeconds.toDouble(),
                          onChanged: (double value) {
                            setState(() {
                              value = position.inSeconds.toDouble();
                            });
                          })
                    ],
                  ),
                ),
              ),
            ),
            // GestureDetector(
            //   onLongPress: () {
            //     setState(() {
            //       _record = !_record;
            //     });
            //     startRecord();
            //   },
            //   // onLongPressUp: () {
            //   //   setState(() {
            //   //     _record = !_record;
            //   //   });
            //   //   stopRecord();
            //   // },
            //   child: Container(
            //     height: h / 15,
            //     width: w / 8,
            //     decoration: BoxDecoration(
            //         color: Colors.amber,
            //         borderRadius: BorderRadius.circular(4)),
            //     child: _record == false
            //         ? const Icon(Icons.mic)
            //         : const Icon(Icons.pause),
            //   ),
            // ),
            Container(
              height: h / 15,
              width: w / 8,
              decoration: BoxDecoration(
                  color: Colors.amber,
                  borderRadius: BorderRadius.circular(40.0)),
              child: IconButton(
                onPressed: () {
                  setState(() {
                    _record = !_record;
                  });
                  _record == true ? startRecord() : stopRecord();
                },
                icon: _record == false
                    ? const Icon(Icons.mic)
                    : const Icon(Icons.pause),
              ),
            ),
            const SizedBox(
              height: 20,
            ),

            TextField(
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter your comment',
              ),
              controller: cmnt,
            ),
            SizedBox(
              width: double.maxFinite,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: ElevatedButton.icon(
                    onPressed: () {},
                    //=> addnetwork(cmnt.text),
                    icon: const Icon(Icons.upload),
                    label: const Text('upload')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
