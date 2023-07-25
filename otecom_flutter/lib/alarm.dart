import 'package:flutter/material.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:otecom_flutter/pages/alarm_page.dart';
import 'sqflite.dart';


class Alarm {
  int id;
  DateTime alarmTime;
  bool isActive;

  Alarm({this.id = 0, required this.alarmTime, this.isActive = true});
}

class AlarmWidget extends StatefulWidget {
  const AlarmWidget({super.key, required this.title});
  final String title;
  @override
  State createState() => _AlarmWidgetState();
}

class _AlarmWidgetState extends State {
  @pragma('vm:entry-point')
  static Future callSoundStart() async {
    //音楽再生
    FlutterRingtonePlayer.playRingtone(looping: true);
  }

  @pragma('vm:entry-point')
  static stopSound() async {
    FlutterRingtonePlayer.stop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
          child:
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      stopSound();
                    },
                    child: const Text("停止"),
                  ),
                ],
              ),
              ElevatedButton(
                child: Text('Set'),
                style: ButtonStyle(
                ),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder:(context) => AlarmPage()));
                  // reBuild();
                },
              ),
              ElevatedButton(
                onPressed: () async {
                  callSoundStart();
                },
                child: const Text("アラーム"),
              ),
            ],
          )
      ),
    );

  }
}
