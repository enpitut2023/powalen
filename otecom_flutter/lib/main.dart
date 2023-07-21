import 'package:flutter/material.dart';
import 'package:weather/weather.dart';


void main(){
  // getWeather();
  runApp(MyApp());
}


class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hello Flutter',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
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
          Colors.white,
          Colors.blue,
        ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          // ここを追加
          child: Image.asset('assets/image/tenki_mark01_hare.png'),
          // body: Row(
          //   children: <Widget>[
          //     Text("item1"),
          //     Text("item2"),
          //     Text("item3"),
          //     Text("item4"),
          //   ],
        ),
      ),
    );
  }
}



