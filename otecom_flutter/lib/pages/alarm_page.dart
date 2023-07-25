import 'package:flutter/material.dart';
import 'package:otecom_flutter/alarm.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:otecom_flutter/pages/add_edit_alarm_page.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:otecom_flutter/sqflite.dart';
import 'dart:async';
import 'package:timezone/timezone.dart' as tz;


class AlarmPage extends StatefulWidget {
  @override
  State<AlarmPage> createState() => _AlarmPageState();
}

class _AlarmPageState extends State<AlarmPage> {
  List<Alarm> alarmList =[];
  DateTime time = DateTime.now();
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();


  Future<void> initDb() async{
    await DbProvider.setDb();
    alarmList = await DbProvider.getData();
    setState(() {});
  }

  Future<void> reBuild() async{
    alarmList = await DbProvider.getData();
    alarmList.sort((a, b) => a.alarmTime.compareTo(b.alarmTime));
    setState(() {});
  }

  void initializeNotification(){
    flutterLocalNotificationsPlugin.initialize(
        InitializationSettings(
          android: AndroidInitializationSettings('ic_launcher'),
          iOS: DarwinInitializationSettings(),
        )
    );
  }

  void setNotification(int id, DateTime alarmTime) {
    flutterLocalNotificationsPlugin.zonedSchedule(
      id, 'アラーム', '時間になりました', tz.TZDateTime.from(alarmTime, tz.local),
      NotificationDetails(
        android: AndroidNotificationDetails('id', 'name', importance: Importance.max, priority: Priority.high),
        iOS: DarwinNotificationDetails(),
      ),
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      androidAllowWhileIdle: true,
    );
  }

  void notification() async{
    await flutterLocalNotificationsPlugin.initialize(
        InitializationSettings(
          android: AndroidInitializationSettings('ic_launcher'),
          iOS: DarwinInitializationSettings(),
        )
    );
    flutterLocalNotificationsPlugin.show(1, 'アラーム', '時間になりました',NotificationDetails(
      android: AndroidNotificationDetails('id', 'name', importance: Importance.max, priority: Priority.high),
      iOS: DarwinNotificationDetails(),
    ));
  }

  @override
  void initState(){
    super.initState();
    initDb();
    initializeNotification();
  }

  void _requestIOSPermissions() {
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: CustomScrollView(
        slivers: [
          CupertinoSliverNavigationBar(
            backgroundColor: Colors.black,
            largeTitle: Text('アラーム', style: TextStyle(color: Colors.white)),
            trailing: GestureDetector(
              child: Icon(Icons.add, color: Colors.green,),
              onTap: () async{
                var result = await Navigator.push(context, MaterialPageRoute(builder:(context) => AddEditAlarmPage(alarmList)));
                if(result != null){
                  setNotification(result.id, result.alarmTime);
                  reBuild();
                }
              },
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
                    (context, index) {
                  Alarm alarm = alarmList[index];
                  return Column(
                    children: [
                      if(index==0) Divider(color: Colors.grey, height: 1),
                      Slidable(
                        key: Key(alarm.id.toString()),  // あなたの状況に合わせた適切なキーを設定してください
                        endActionPane: ActionPane(
                        motion: ScrollMotion(),
                        children: <Widget>[
                            SlidableAction(
                              onPressed: (context) async {
                                await DbProvider.deleteData(alarm.id);
                                reBuild();
                              },
                              label: '削除',
                              icon: Icons.delete,
                              backgroundColor: Colors.red,
                            ),

                          ],
                        ),
                          child:ListTile(
                            title: Text(DateFormat('H:mm').format(alarm.alarmTime),
                                style: TextStyle(color: Colors.white, fontSize: 50)
                            ),
                            trailing: CupertinoSwitch(
                              value: alarm.isActive,
                              onChanged: (newValue) async{
                                alarm.isActive = newValue;
                                await DbProvider.updateData(alarm);
                                reBuild();
                              },
                            ),
                            onTap: () async{
                              await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder:(context) => AddEditAlarmPage(alarmList, index: index)));
                                      reBuild();
                            },
                          ),
                      ),
                      Divider(color: Colors.grey, height: 0)
                    ],
                  );
                },
                childCount: alarmList.length
            ),
          )
        ],
      ),
    );
  }
}