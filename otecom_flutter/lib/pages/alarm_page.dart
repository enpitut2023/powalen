import 'package:flutter/material.dart';
import 'package:otecom_flutter/alarm.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:otecom_flutter/pages/add_edit_alarm_page.dart';

class AlarmPage extends StatefulWidget {
  @override
  State<AlarmPage> createState() => _AlarmPageState();
}

class _AlarmPageState extends State<AlarmPage> {
  List<Alarm> alarmList =[

  ];

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
              child: Icon(Icons.add, color: Colors.orange,),
              onTap: () async{
                await Navigator.push(context, MaterialPageRoute(builder:(context) => AddEditAlarmPage(alarmList)));
                setState(() {
                  alarmList.sort((a,b) => a.alarmTime.compareTo(b.alarmTime));
                });
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
                      ListTile(
                        title: Text(DateFormat('H:mm').format(alarm.alarmTime),
                            style: TextStyle(color: Colors.white, fontSize: 50)
                        ),
                        trailing: CupertinoSwitch(
                          value: alarm.isActive,
                          onChanged: (newValue) {
                            setState((){
                              alarm.isActive = newValue;
                            });
                          },
                        ),
                        onTap: () async{
                          await Navigator.push(context, MaterialPageRoute(builder:(context) => AddEditAlarmPage(alarmList, index: index)));
                          setState(() {
                            alarmList.sort((a,b) => a.alarmTime.compareTo(b.alarmTime));
                          });
                        },
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