import 'package:flutter/material.dart';
import 'package:otecom_flutter/alarm.dart';
// import 'apikey.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;
import 'trainInfo.dart';
import 'wether.dart';
import 'dart:convert';
import 'package:otecom_flutter/pages/alarm_page.dart';
import 'package:timezone/data/latest.dart';
import 'package:timezone/timezone.dart';
import 'package:timezone/data/latest.dart' as tz;


const int alramSecond = 5;

// import 'apikey.dart';

// String APIkey = api_key;


void main() async {
  // getWeather();
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
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        height: 350,
                        width: 400,
                          child: WetherWidget(line: "")
                      ),
                      Container(
                          height: 300,
                          width: 400,
                          child: TransInfoWidget(line: "")
                      ),
                      Container(
                          height: 100,
                          width: 400,
                        child: AlarmWidget(title: "")
                      )
                    ],
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
    ));
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
    final result = document
        .querySelectorAll('.elmTblLstLine > table > tbody > tr > td')
        .map((v) => v.text)
        .toList();
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

// void getWeather() async {
//   String key = APIkey;
//   double lat = 55.0111; //latitude(緯度)
//   double lon = 15.0569; //longitude(経度)
//   WeatherFactory wf = new WeatherFactory(key);
//
//   List<Weather> w = await wf.fiveDayForecastByCityName("tsukuba");
//
//   print(w[0]);
//   print(w[0].weatherMain);
//  }

class WeatherInfo {
  final Map<String, dynamic> currentWeather;
  final List<dynamic> temp;
  final List<dynamic> weather;
  final List<double> precipitation;
  final List<double> maxTemp;
  final List<double> minTemp;
  static Map<String, String> icon = {
    'sunny': 'assets/image/weather_sun.png',
    'cloudy': 'assets/image/weather_cloud.png',
    'lightRain': 'assets/image/weather_rain.png',
    'heavyRain': 'assets/image/weather_strongrain.png',
    'snow': 'assets/image/weather_snow.png',
    'thunderStorm': 'assets/image/weather_thunderStorm.png',
    'unknownWeather': 'error',
  };

  WeatherInfo(
      {required this.currentWeather,
      required this.temp,
      required this.weather,
      required this.precipitation,
      required this.maxTemp,
      required this.minTemp});

  factory WeatherInfo.fromJson(dynamic json) {
    List<double> tempDouble = [];
    List<double> precipitationDouble = [];
    List<double> maxTempDouble = [];
    List<double> minTempDouble = [];

    json['hourly']['temperature_2m'].forEach((item) => {
      tempDouble.add(item)
    });
    json['hourly']['precipitation'].forEach((item) => {
      precipitationDouble.add(item)
    });
    json['daily']['temperature_2m_max'].forEach((item) => {
      maxTempDouble.add(item)
    });
    json['daily']['temperature_2m_min'].forEach((item) => {
      minTempDouble.add(item)
    });
    return WeatherInfo(
      currentWeather: json['current_weather'],
      // temp: json['hourly']['temperature_2m'],
      temp: tempDouble,
      weather: json['hourly']['weathercode'],
      precipitation: precipitationDouble,
      maxTemp: minTempDouble,
      minTemp: minTempDouble,
    );
  }

  static String weatherCodeParser(int code) {
    String weatherName;
    switch (code) {
      case 0: // 晴天
      case 1: // おおむね晴れ
      case 2: // 晴れ時々曇り
        weatherName = 'sunny';
        break;
      case 3: // 曇り
      case 45: // 本来は霧
      case 48: // 本来は白霜
      case 51: // 軽い霧
      case 53: // 中程度の霧
      case 55: // 濃い霧
        weatherName = 'cloudy';
        break;
      case 61: // 小雨
      case 80: // 小程度のにわか雨
      case 56: // 軽い氷結霧雨
      case 57: // 濃い氷結霧雨
        weatherName = 'lightRain';
        break;
      case 63: // 中程度の雨
      case 65: // 激しい雨
      case 66: // 凍てつく雨
      case 67: // 軽くて激しい雨
      case 81: // 中程度のにわか雨
      case 82: // 激しいにわか雨
        weatherName = 'heavyRain';
        break;
      case 71: // 小雪
      case 73: // 中雪
      case 75: // 大雪
      case 77: // 雪の粒
        weatherName = 'snow';
        break;
      case 95: // 雷雨
        weatherName = 'thunderStorm';
        break;
      default:
        weatherName = 'unknownWeather';
        break;
    }
    return weatherName;
  }

  String weatherFromTime(int time) {
    int weatherCode = this.weather[time];
    return WeatherInfo.weatherCodeParser(weatherCode);
  }

  String weatherIconFromTime(int time) {
    int weatherCode = this.weather[time];
    String weatherName = WeatherInfo.weatherCodeParser(weatherCode);
    return WeatherInfo.icon.containsKey(weatherName)
        ? WeatherInfo.icon[weatherName]!
        : 'unknownWeather';
  }
}

Future<WeatherInfo> realWeather() async {
  const url =
      'https://api.open-meteo.com/v1/forecast?latitude=36.2&longitude=140.1&hourly=temperature_2m,precipitation,weathercode&daily=temperature_2m_max,temperature_2m_min&current_weather=true&timezone=Asia%2FTokyo&forecast_days=1';
  final target = Uri.parse(url);
  final response = await http.get(target);

  if (response.statusCode != 200) {
    print('ERROR: ${response.statusCode}');
  }

  Map<String, dynamic> map = jsonDecode(response.body);
  print(map);
  return WeatherInfo.fromJson(map);
  // print(DateTime.now());
}

// {
//   "latitude":36.2,
//   "longitude":140.125,
//   "generationtime_ms":0.2510547637939453,
//   "utc_offset_seconds":32400,
//   "timezone":"Asia/Tokyo",
//   "timezone_abbreviation":"JST",
//   "elevation":40.0,
//   "current_weather":
//   {
//     "temperature":30.1,
//     "windspeed":6.9,
//     "winddirection":189.0,
//     "weathercode":0,
//     "is_day":1,
//     "time":"2023-07-24T11:00"
//   },
//   "hourly_units":
//   {
//     "time":"iso8601",
//     "temperature_2m":"°C",
//     "weathercode":"wmo code"
//   },
//     "hourly":
//   {
//     "time":
//     [
//       "2023-07-24T00:00",
//       "2023-07-24T01:00",
//       "2023-07-24T02:00","2023-07-24T03:00","2023-07-24T04:00","2023-07-24T05:00","2023-07-24T06:00","2023-07-24T07:00","2023-07-24T08:00","2023-07-24T09:00","2023-07-24T10:00","2023-07-24T11:00","2023-07-24T12:00","2023-07-24T13:00","2023-07-24T14:00","2023-07-24T15:00","2023-07-24T16:00","2023-07-24T17:00","2023-07-24T18:00","2023-07-24T19:00","2023-07-24T20:00","2023-07-24T21:00","2023-07-24T22:00","2023-07-24T23:00"
//     ],
//     "temperature_2m":
//     [
//       22.1,21.8,21.7,21.2,21.4,21.1,22.2,23.5,24.8,26.5,28.3,30.1,31.8,33.0,33.5,33.5,32.5,31.0,29.3,27.4,25.9,24.5,23.7,23.2
//     ],
//     "weathercode":
//     [
//       0,1,2,1,2,2,2,2,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0
//     ]
//   },
//   "daily_units":
//   {
//     "time":"iso8601",
//     "temperature_2m_max":"°C",
//     "temperature_2m_min":"°C"
//   },
//   "daily":
//   {
//     "time":
//     [
//       "2023-07-24"
//     ],
//   "temperature_2m_max":
//   [
//     33.5
//   ],
//   "temperature_2m_min":
//   [
//     21.1
//   ]
//   }
// }
