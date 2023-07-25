import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;
import 'package:otecom_flutter/main.dart';

class WeatherWidget extends StatefulWidget {

  @override
  _WeatherWidgetState createState() => _WeatherWidgetState();
}

class _WeatherWidgetState extends State<WeatherWidget> {

  @override
  Widget build(BuildContext context) {
    // 以下はinitStateが完了している場合
    return FutureBuilder(
      future: realWeather(),
      builder: (context, snapshot) {
        WeatherInfo? weather = snapshot.data;
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError) {
            return Text("Error: ${snapshot.error}");
          }
          if (!snapshot.hasData) {
            return Text("データが見つかりません");
          }

          weather!;

          return Scaffold(
              backgroundColor: Colors.transparent,
              body: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                          alignment: Alignment.center,
                          height: 70,
                          width: 200,
                          decoration: BoxDecoration(
                            color: Colors.white70,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text("傘は必要ない！", style: TextStyle(fontFamily: 'Sawarabi_Gothic', fontSize: 20))
                      ),
                      Container(
                        height: 100,
                        width: 150,
                        child: Image.asset(weather.weatherIconFromTime(11)),
                      )
                    ]
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        height: 130,
                        width: 150,
                        child: Image.asset(weather.weatherIconFromTime(11)),
                      ),
                      Container(
                        alignment: Alignment.center,
                        height: 130,
                        width: 150,
                        child: Text(weather.maxTemp.toString() + "℃", style: TextStyle(fontFamily: 'Sawarabi_Gothic', fontSize: 50),),
                      )
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        alignment: Alignment.center,
                        height: 40,
                        width: 120,
                        child: const Text("12:00", style: TextStyle(fontFamily: 'Sawarabi_Gothic', fontSize: 30),),
                      ),
                      Container(
                        alignment: Alignment.center,
                        height: 40,
                        width: 120,
                        child: const Text("18:00", style: TextStyle(fontFamily: 'Sawarabi_Gothic', fontSize: 30),),
                      ),
                      Container(
                        alignment: Alignment.center,
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
                        child: Image.asset(weather.weatherIconFromTime(12)),
                      ),
                      Container(
                        height: 120,
                        width: 120,
                        child: Image.asset(weather.weatherIconFromTime(18)),
                      ),
                      Container(
                        height: 120,
                        width: 120,
                        child: Image.asset(weather.weatherIconFromTime(21)),
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

