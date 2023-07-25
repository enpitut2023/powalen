import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:otecom_flutter/alarm.dart';
import 'package:intl/intl.dart';
import 'package:otecom_flutter/sqflite.dart';

class AddEditAlarmPage extends StatefulWidget {
  final List<Alarm> alarmList;
  final int? index;
  AddEditAlarmPage(this.alarmList, {this.index});

  @override
  State<AddEditAlarmPage> createState() => _AddEditAlarmPageState();
}

class _AddEditAlarmPageState extends State<AddEditAlarmPage> {
  TextEditingController controller = TextEditingController();
  DateTime selectedDate = DateTime.now();

  void initEditAlarm() {
    if(widget.index != null){
      selectedDate = widget.alarmList[widget.index!].alarmTime;
      controller.text = DateFormat('H:mm').format(selectedDate);
    }
  }

  @override
  void initState(){
    super.initState();
    initEditAlarm();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leadingWidth: 100,
        leading: GestureDetector(
          child: Container(
            alignment: Alignment.center,
            child: Text('キャンセル',style: TextStyle(color: Colors.white)),
          ),
          onTap: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          GestureDetector(
            child: Container(
                padding: EdgeInsets.only(right: 20),
                alignment: Alignment.center,
                child: Text('保存', style: TextStyle(color: Colors.white))
            ),
            onTap: () async{
              DateTime now =DateTime.now();
              DateTime? alarmTime;
              if(now.compareTo(selectedDate) == -1) {
                alarmTime = DateTime(selectedDate.year, selectedDate.month, selectedDate.day, selectedDate.hour, selectedDate.minute);
              } else {
                alarmTime = DateTime(now.year, now.month, now.day + 1, selectedDate.hour, selectedDate.minute);
              }
              Alarm alarm = Alarm(alarmTime: alarmTime);
              if(widget.index != null){
                alarm.id = widget.alarmList[widget.index!].id;
                await DbProvider.updateData(alarm);
              } else {
                int id = await DbProvider.insertData(alarm);
                alarm.id = id;
              }
              Navigator.pop(context);
            },
          ),
        ],
        backgroundColor: Colors.blue,
        title: Text('アラームを追加',style: TextStyle(color: Colors.white)),
      ),
      body: Container(
        height: double.infinity,
        color: Colors.blue,
        child: Column(
          children: [
            SizedBox(height: 50),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('時間', style: TextStyle(color: Colors.white)),
                  Container(
                    width: 70,
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.green),
                        borderRadius: BorderRadius.circular(10)
                    ),
                    child: TextField(
                      controller: controller,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(border: InputBorder.none),
                      readOnly: true,
                      onTap: () {
                        showModalBottomSheet(context: context, builder: (context) {
                          return CupertinoDatePicker(
                            initialDateTime: selectedDate,
                            mode: CupertinoDatePickerMode.time,
                            onDateTimeChanged: (newDate) {
                              String time = DateFormat('H:mm').format(newDate);
                              selectedDate = newDate;
                              controller.text = time;
                              setState(() {});
                            },
                          );
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
