import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;
import 'dart:convert';

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

        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError) {
            return Text("Error: ${snapshot.error}");
          }
          if (!snapshot.hasData) {
            return Text("データが見つかりません");
          }
          WeatherInfo weather = snapshot.data!;

          return Scaffold(
              backgroundColor: Colors.transparent,
              body: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white70,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          alignment: Alignment.center,
                          height: 70,
                          width: 200,           
                          child: Text(weather.umbrellaRequiredMessage(), style: TextStyle(fontFamily: 'Sawarabi_Gothic', fontSize: 20))
                        ),
                        Container(
                          height: 100,
                          width: 150,
                          child: Image.asset(weather.umbrellaIcon()),
                        )
                      ],
                    )
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        alignment: Alignment.topRight,
                        height: 70,
                        width: 40,
                        child: Text("現在の天気", style: TextStyle(fontFamily: 'Sawarabi_Gothic', fontSize: 12)),
                      ),
                      Container(
                        alignment: Alignment.centerLeft,
                        height: 130,
                        width: 100,
                        child: Image.asset(weather.currentWeatherIcon()),
                      ),
                      Container(
                        alignment: Alignment.topRight,
                        width: 50,
                        height: 70,
                        child: Text("最高気温", style: TextStyle(fontFamily: 'Sawarabi_Gothic', fontSize: 12)),
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
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(
                        height: 100,
                        width: 90,
                        child: Image.asset(weather.weatherIconFromTime(12)),
                      ),
                      Container(
                        height: 100,
                        width: 90,
                        child: Image.asset(weather.weatherIconFromTime(18)),
                      ),
                      Container(
                        height: 100,
                        width: 90,
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





class WeatherInfo {
  final Map<String, dynamic> currentWeather;
  final List<dynamic> temp;
  final List<dynamic> weather;
  final List<double> precipitationProb;
  final double maxTemp;
  final double minTemp;
  static Map<String, String> icon = {
    'sunny': 'assets/image/weather_sun.png',
    'cloudy': 'assets/image/weather_cloud.png',
    'lightRain': 'assets/image/weather_rain.png',
    'heavyRain': 'assets/image/weather_strongrain.png',
    'snow': 'assets/image/weather_snow.png',
    'thunderStorm': 'assets/image/weather_thunderStorm.png',
    'unknownWeather': 'unknownWeather',
    'needUmbrella': 'assets/image/requiredUmbrella.png',
    'noUmbrella': 'assets/image/umbrellaBlackSlash.png',

  };

  WeatherInfo(
      {required this.currentWeather,
      required this.temp,
      required this.weather,
      required this.precipitationProb,
      required this.maxTemp,
      required this.minTemp});

  factory WeatherInfo.fromJson(dynamic json) {
    List<double> tempDouble = [];
    List<double> precipitationDouble = [];
    List<double> maxTempDouble = [];
    List<double> minTempDouble = [];

    json['hourly']['temperature_2m'].forEach((item) => {tempDouble.add(item)});
    json['hourly']['precipitation']
        .forEach((item) => {precipitationDouble.add(item)});
    json['daily']['temperature_2m_max']
        .forEach((item) => {maxTempDouble.add(item)});
    json['daily']['temperature_2m_min']
        .forEach((item) => {minTempDouble.add(item)});
    return WeatherInfo(
      currentWeather: json['current_weather'],
      // temp: json['hourly']['temperature_2m'],
      temp: tempDouble,
      weather: json['hourly']['weathercode'],
      precipitationProb: precipitationDouble,
      maxTemp: maxTempDouble[0],
      minTemp: minTempDouble[0],
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

  String umbrellaRequiredMessage() {
    int status = umbrellaCondition();
    if (status == 1) {
      return '傘が必要です';
    } else {
      return '傘は必要ありません';
    }
  }

  // 傘が必要なら1, 不要なら0を返す
  int umbrellaCondition() {
    double maxRainyPercent = 0;
    for (int i = 6; i <= 18; i++) {
      if (this.precipitationProb[i] > maxRainyPercent) {
        maxRainyPercent = this.precipitationProb[i];
      }
    }
    if (maxRainyPercent > 0.5) {
      return 1;
    } else {
      return 0;
    }
  }

  String umbrellaIcon() {
    int status = umbrellaCondition();
    if (status == 1) {
      return icon['needUmbrella']!;
    } else {
      return icon['noUmbrella']!;
    }
  }

  String currentWeatherIcon() {
    String weather = WeatherInfo.weatherCodeParser(this.currentWeather['weathercode']);
    return WeatherInfo.icon.containsKey(weather)
        ? WeatherInfo.icon[weather]!
        : 'unknownWeather';
  }
}



Future<WeatherInfo> realWeather() async {
  const url =
      'https://api.open-meteo.com/v1/forecast?latitude=36.2&longitude=140.1&hourly=temperature_2m,precipitation,weathercode&daily=temperature_2m_max,temperature_2m_min&current_weather=true&timezone=Asia%2FTokyo&forecast_days=1';
      // 'https://api.open-meteo.com/v1/forecast?latitude=36.2&longitude=140.1&hourly=temperature_2m,precipitation,weathercode&daily=temperature_2m_max,temperature_2m_min&current_weather=true&timezone=Asia%2FTokyo&start_date=2023-06-02&end_date=2023-06-02';
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
