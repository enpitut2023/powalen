import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;

class TransInfoWidget extends StatefulWidget {
  TransInfoWidget({required this.line}) : super();

  final String line;

  @override
  _TransInfoState createState() => _TransInfoState(line: line);
}

class _TransInfoState extends State<TransInfoWidget> {
  _TransInfoState({required this.line}) : super();

  final String line;
  List<String> lines = [];

  String LineMapLogo(String linename){
    String? imageFile = "";
    Map<String, String> LineMapLogo = {
      'つくばエクスプレス線' : 'assets/image/tx_logo.png',
      '常磐線(各停)' : 'assets/image/jyouban_logo.png'
    };
    
    if(LineMapLogo.containsKey(linename)){
      imageFile = LineMapLogo[linename];
      return imageFile!;
    }
    return "assets/image/empty_logo.png";
  }

  String TransInfoMapImage(String trainStatus){
    String? imageFile = "";
    Map<String, String> TransInfoMapImage = {
      '平常運転' : 'assets/image/heijyou_unten.png',
      '[!]列車遅延' : 'assets/image/okureari.png',
      '[!]運転状況' : 'assets/image/okureari.png',
    };

    if(TransInfoMapImage.containsKey(trainStatus)){
      imageFile = TransInfoMapImage[trainStatus];
      return imageFile!;
    }
    return "assets/image/empty_logo.png";
  }

  String TransInfoMapTrainImage(String trainStatus){
    String? imageFile = "";
    Map<String, String> TransInfoMapTraingImage = {
      '平常運転' : 'assets/image/heijouTrain.png',
      '[!]列車遅延' : 'assets/image/chienTrain.png'
    };

    if(TransInfoMapTraingImage.containsKey(trainStatus)){
      imageFile = TransInfoMapTraingImage[trainStatus];
      return imageFile!;
    }
    return "assets/image/empty_logo.png";
  }

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
          String TrainImage = "平常運転";
          for(int i = 0; i < trainInfo.length; i++){
            if(trainInfo[i][1] != "平常運転"){
              TrainImage = "[!]列車遅延";
            }
          }
          return Scaffold(
              backgroundColor: Colors.transparent,
              body: Column(
                  children: [
                    Row(mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            height: 200,
                            width: 200,
                            child: Image.asset(TransInfoMapTrainImage(TrainImage)),
                          ),
                          Column(
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      height: 70,
                                      width: 80,
                                      child: Image.asset(LineMapLogo("つくばエクスプレス線")),
                                      // child: TransInfoWidget(line: ""),
                                    ),
                                    Container(
                                      height: 70,
                                      width: 100,
                                      child: Image.asset(TransInfoMapImage(trainInfo[0][1])),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Container(
                                      height: 70,
                                      width: 80,
                                      child: Image.asset(LineMapLogo("常磐線(各停)")),
                                    ),
                                    Container(
                                      height: 70,
                                      width: 100,
                                      child: Image.asset(TransInfoMapImage(trainInfo[1][1])),
                                    ),
                                  ],
                                )
                              ])
                        ])
                  ])
          );;
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

