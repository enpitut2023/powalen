import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;

void main() => runApp(MyApp());


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
    fetchTrainInfo("dummy");
    return Scaffold(
      appBar: AppBar(

      ),
      body: Center(
        // ここを追加
        child: Image.asset('assets/image/tenki_mark01_hare.png'),

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




