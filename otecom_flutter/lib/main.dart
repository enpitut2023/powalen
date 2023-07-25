import 'package:flutter/material.dart';
import 'package:otecom_flutter/alarm.dart';

import 'trainInfo.dart';
import 'weather.dart';

import 'package:timezone/data/latest.dart';
import 'package:timezone/timezone.dart';




void main() async {
  var weather = await realWeather();
  print(weather.weatherIconFromTime(6));
  initializeTimeZones();
  setLocalLocation(getLocation('Asia/Tokyo'));
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Hello Flutter',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: ViewWeatherImage());
  }
}

class ViewWeatherImage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xffb1faff),
              Color(0xff2c5b9b),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                    height: 400, width: 450, child: WeatherWidget()),
                Container(
                    height: 200, width: 400, child: TransInfoWidget(line: "")),
                Container(
                    height: 100, width: 400, child: AlarmWidget(title: ""))
              ],
            ),
          ),
        ));
  }
}