import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_oboe/flutter_oboe.dart';
import 'dart:async';

void main(){
  runApp(MyApp());
}

class MyApp extends StatefulWidget{
  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp>{
  // parameters
  int recordingDeviceId = 0;
  int playbackDeviceId = 0;
  int api = 0; // OBOE_API_AAUDIO = 0, OBOE_API_OPENSL_ES = 1
  int sampleRate = 44100;
  int framesPerBurst = 0; // default
  double gain = 1.0; // amplification

  final stream = FlutterOboe();
  late bool engineCreated;
  late bool aaudioRecommended;

  @override
  void initState(){
    super.initState();

    // ask for microphone permission
    getMicrophonePermission();

    // create Oboe audio stream
    engineCreated = stream.engineCreate();
    engineCreated ? print("Oboe Audio stream created") :
      print("Oboe Audio stream failed");

    // check whether AAudio API is recommended for the device
    aaudioRecommended = stream.engineIsAAudioRecommended();
    aaudioRecommended ? print("AAudio recommended") :
      print("AAudio not recommended");
  }

  @override
  Widget build(BuildContext context){
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Flutter Oboe example app'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text('Audio API:'),
              DropdownButton<int>(
                value: api,
                icon: const Icon(Icons.arrow_downward),
                elevation: 16,
                style: const TextStyle(color: Colors.deepPurple),
                underline: Container(
                  height: 2,
                  color: Colors.deepPurpleAccent,
                ),
                onChanged: (int? newValue) {
                  setState(() {
                    api = newValue!;
                  });
                },
                items: <int>[0, 1]
                    .map<DropdownMenuItem<int>>((int value) {
                  return DropdownMenuItem<int>(
                    value: value,
                    child: Text(apiToString(value)),
                  );
                }).toList(),
              ),
              Text('Sample Rate:'),
              DropdownButton<int>(
                value: sampleRate,
                icon: const Icon(Icons.arrow_downward),
                elevation: 16,
                style: const TextStyle(color: Colors.deepPurple),
                underline: Container(
                  height: 2,
                  color: Colors.deepPurpleAccent,
                ),
                onChanged: (int? newValue) {
                  setState(() {
                    sampleRate = newValue!;
                  });
                },
                items: <int>[16000, 22050, 32000, 44100, 48000, 96000]
                    .map<DropdownMenuItem<int>>((int value) {
                      return DropdownMenuItem<int>(
                        value: value,
                        child: Text(value.toString()),
                      );
                    }).toList(),
                ),
              Text('Gain:'),
              Slider(
                value: gain,
                max: 10,
                divisions: 100,
                label: gain.toStringAsFixed(1),
                onChanged: (double value) {
                  setState(() {
                    gain = value;
                    stream.engineSetGain(gain);
                  });
                },
              ),
              ElevatedButton(
                child: Text('START'),
                onPressed: start,
              ),
              ElevatedButton(
                child: Text('STOP'),
                onPressed: stop,
              ),
              SizedBox(height: 40),
              Text('Warning: If you run this sample you may create a feedback '
                  'loop which will not be pleasent to listen to.', textAlign: TextAlign.center,),
            ],
          ),
        ),
      )
    );
  }

  void start(){
    // set recording device id
    stream.engineSetRecordingDeviceId(recordingDeviceId);
    // set playback device id
    stream.engineSetPlaybackDeviceId(recordingDeviceId);
    // set audio library
    stream.engineSetAPI(api);
    // set sample rate
    stream.engineNative1setDefaultStreamValues(sampleRate, framesPerBurst);
    // start Oboe audio passthrough
    stream.engineSetEffectOn(true);
  }

  void stop(){
    // stop Oboe audio passthrough
    stream.engineSetEffectOn(false);
    // delte Oboe audio stream
    stream.engineDelete();
  }

  String apiToString(int api){
    String apiString = 'AAudio';
    switch (api) {
      case 0:
      apiString = 'AAudio';
      break;
    case 1:
      apiString = 'OpenSL ES';
      break;
    }
    return apiString;
  }

  Future<void> getMicrophonePermission() async {
    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      print('Microphone permission not granted');
    }
  }
}