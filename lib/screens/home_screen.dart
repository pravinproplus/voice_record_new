import 'dart:io';

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:voice_task/network/network_helper.dart';

class VoiceFeedBack extends StatefulWidget {
  const VoiceFeedBack({Key? key}) : super(key: key);

  @override
  _VoiceFeedBackState createState() => _VoiceFeedBackState();
}

class _VoiceFeedBackState extends State<VoiceFeedBack> {
  //voice command
  final recorder = Record();
  bool _play = false;
  bool _record = false;
  File? file;
  String? filePath;
  Duration duration = const Duration();
  Duration position = const Duration();
  final audioPlayer = AssetsAudioPlayer();

  @override
  void initState() {
    start();
    super.initState();
    getStoragePath();
  }

  @override
  void dispose() {
    audioPlayer.dispose();

    super.dispose();
  }

  void getStoragePath() async {
    Directory tempDir = await getTemporaryDirectory();
    String tempPath = tempDir.path;
    filePath = '$tempPath/audio.m4a';
  }

  //voice command
  // Check and request permission
  Future start() async {
    await Permission.microphone.request();
    await Permission.storage.request();
    await Permission.manageExternalStorage.request();
  }

  Future addnetwork(String cmt) async {
    try {
      file = File(filePath!);
      Map data = {
        'file': file,
        'comment': cmt,
      };
      NetworkHelper networkHelper = NetworkHelper(url: ''); //your url
      await networkHelper.network(data);
      delete();
    } catch (e) {
      rethrow;
    }
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
    final dir = Directory(filePath!);
    dir.deleteSync(recursive: true);
  }

  //audio play method
  Future<void> startPlaying() async {
    if (filePath == null) {
      Fluttertoast.showToast(msg: "No file Here");
    } else {
      audioPlayer.open(
        Audio.file(filePath!),
        autoStart: true,
        showNotification: true,
      );

      audioPlayer.current.listen((playingAudio) {
        final songDuration = playingAudio!.audio.duration;
        setState(() {
          duration = songDuration;
        });
      });
      audioPlayer.currentPosition.listen((event) {
        setState(() {
          position = event.abs();
        });
      });
      audioPlayer.playlistAudioFinished.listen((event) {
        setState(() {
          _play = !_play;
        });
      });
    }
  }

//stop playing method
  Future<void> stopPlaying() async {
    audioPlayer.stop();
  }

  //voice command

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SizedBox(
          height: MediaQuery.of(context).size.height / 2,
          width: MediaQuery.of(context).size.width,
          child: Column(
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.02,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.02,
                      ),
                      Material(
                        elevation: 3,
                        borderRadius: BorderRadius.circular(15),
                        child: Container(
                          height: MediaQuery.of(context).size.height * 0.06,
                          width: MediaQuery.of(context).size.width * 0.75,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              border:
                                  Border.all(color: Colors.amber, width: 0.4),
                              borderRadius: BorderRadius.circular(15)),
                          child: Row(
                            children: [
                              Container(
                                height:
                                    MediaQuery.of(context).size.height * 0.06,
                                width: MediaQuery.of(context).size.width * 0.13,
                                decoration: const BoxDecoration(
                                    color: Colors.amber,
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(15),
                                      bottomLeft: Radius.circular(15),
                                      topRight: Radius.circular(5),
                                      bottomRight: Radius.circular(5),
                                    )),
                                child: IconButton(
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
                                        ? Icon(
                                            Icons.play_arrow,
                                            color: Colors.white,
                                            size: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.04,
                                          )
                                        : Icon(
                                            Icons.pause,
                                            color: Colors.white,
                                            size: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.04,
                                          )),
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
                    ],
                  ),
                  Row(
                    children: [
                      Material(
                        elevation: 5,
                        borderRadius: BorderRadius.circular(50),
                        child: Container(
                          height: MediaQuery.of(context).size.height * 0.07,
                          width: MediaQuery.of(context).size.width * 0.14,
                          decoration: BoxDecoration(
                            color: Colors.amber,
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: IconButton(
                              onPressed: () {
                                setState(() {
                                  _record = !_record;
                                });
                                _record == true ? startRecord() : stopRecord();
                              },
                              icon: _record == false
                                  ? const Icon(
                                      Icons.keyboard_voice,
                                      color: Colors.white,
                                    )
                                  : const Icon(
                                      Icons.pause,
                                      color: Colors.white,
                                    )),
                        ),
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.03,
                      ),
                    ],
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
