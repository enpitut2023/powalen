import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;

class WetherWidget extends StatefulWidget {
  WetherWidget({required this.line}) : super();

  final String line;

  @override
  _TransInfoState createState() => _TransInfoState(line: line);
}

class _TransInfoState extends State<WetherWidget> {
  _TransInfoState({required this.line}) : super();

  final String line;
  List<String> lines = [];

  @override
  Widget build(BuildContext context) {
    // 以下はinitStateが完了している場合
    return FutureBuilder(
      future: fetchTrainInfo(line),
      builder: (context, snapshot) {
        List<List<String>>? trainInfo = snapshot.data;
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError) {
            return Text("Error: ${snapshot.error}");
          }
          if (!snapshot.hasData) {
            return Text("データが見つかりません");
          }
          // データ表示
          if(trainInfo!.isEmpty){
            return Text("データが見つかりません");
          }
          return Scaffold(
              backgroundColor: Colors.transparent,
              body: Column(
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
              ])
          );
        } else {
          // 処理中の表示
          return const CircularProgressIndicator();
        }
      },
    );
  }
}



Future<List<List<String>>> fetchTrainInfo(String dummyLines) async {
  final url = 'https://transit.yahoo.co.jp/diainfo/area/4';
  final target = Uri.parse(url);
  List<String> lines = ["つくばエクスプレス線", "常磐線(各停)"];
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

