import 'package:flutter/material.dart';
import 'apikey.dart';
import 'package:weather/weather.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;
import 'trainInfo.dart';

String APIkey = api_key;

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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 150,
                    width: 150,
                    child: Image.asset('assets/image/tenki_mark01_hare.png'),
                  ),
                  Container(
                    height: 150,
                    width: 150,
                    child: const Text("29℃", style: TextStyle(fontFamily: 'Sawarabi_Gothic', fontSize: 70),),
                  )
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 40,
                    width: 120,
                    child: const Text("12:00", style: TextStyle(fontFamily: 'Sawarabi_Gothic', fontSize: 30),),
                  ),
                  Container(
                    height: 40,
                    width: 120,
                    child: const Text("18:00", style: TextStyle(fontFamily: 'Sawarabi_Gothic', fontSize: 30),),
                  ),
                  Container(
                    height: 40,
                    width: 120,
                    child: const Text("21:00", style: TextStyle(fontFamily: 'Sawarabi_Gothic', fontSize: 30),),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 120,
                    width: 120,
                    child: Image.asset('assets/image/tenki_mark01_hare.png'),
                  ),
                  Container(
                    height: 120,
                    width: 120,
                    child: Image.asset('assets/image/weather_cloud.png'),
                  ),
                  Container(
                    height: 120,
                    width: 120,
                    child: Image.asset('assets/image/weather_rain.png'),
                  ),
                ],
              ),
              Container(
                  height: 400,
                  width: 400,
                  child: TransInfoWidget(line: "")
              )
            ]
          )
          // ここを追加
          // child: Image.asset('assets/image/tenki_mark01_hare.png'),
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

  Future<List<List<String>>> fetchTrainInfo(String dummyLines) async {
    final url = 'https://transit.yahoo.co.jp/diainfo/area/4';
    final target = Uri.parse(url);
    List<String> lines = ["つくばエクスプレス線"];
    final response = await http.get(target);

    if (response.statusCode != 200) {
      print('ERROR: ${response.statusCode}');
      return [];
    }

    final document = parse(response.body);
    final result = document.querySelectorAll(
        '.elmTblLstLine > table > tbody > tr > td').map((v) => v.text).toList();
    List<List<String>> trainInfoList = [];
    List<String> trainInfo = [];
    for (int i = 0; i < result.length; i++) {
      trainInfo.add(result[i]);
      if (i % 3 == 2) {
        if (lines.contains(trainInfo[0])) {
          trainInfoList.add(trainInfo);
        }
        trainInfo = [];
      }
    }
    print(trainInfoList);
    return trainInfoList;
  }
}

void getWeather() async {
  String key = APIkey;
  double lat = 55.0111; //latitude(緯度)
  double lon = 15.0569; //longitude(経度)
  WeatherFactory wf = new WeatherFactory(key);

  List<Weather> w = await wf.fiveDayForecastByCityName("tsukuba");

  print(w[0]);
  print(w[0].weatherMain);
 }
