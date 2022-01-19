import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_oboe/flutter_oboe.dart';
import 'package:oscilloscope/oscilloscope.dart';

void main(){
  runApp(MyApp());
}

class MyApp extends StatefulWidget{
  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp>{
  // oboe parameters
  int recordingDeviceId = 0;
  int playbackDeviceId = 0;
  int api = 0; // OBOE_API_AAUDIO = 0, OBOE_API_OPENSL_ES = 1
  int sampleRate = 44100;
  double gain = 1.0; // amplification
  int framesPerBurst = 0; // default = 0

  // oscilloscope parameters
  int osciUpdateRate = 10; // in Hz

  late FlutterOboe stream;
  late bool engineCreated;
  late bool aaudioRecommended;
  List<double> osciSamples = [];
  int sampleCount = 0;
  double sampleMax = 0.0;

  @override
  void initState(){
    super.initState();

    // ask for microphone permission
    getMicrophonePermission();

    // initialize dart:ffi interface to OBOE library
    stream = FlutterOboe();

    // initialize native messenging between Oboe and Flutter
    stream.initNativeMessenging();

    // register the callback port to receive the output sample buffers from Oboe
    receiveSamples();

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
              SizedBox(height: 10),
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
              Expanded(
                  flex:1,
                  child: Oscilloscope(
                    showYAxis: true,
                    yAxisColor: Colors.orange,
                    margin: EdgeInsets.all(0.0),
                    strokeWidth: 1.0,
                    backgroundColor: Colors.black,
                    traceColor: Colors.green,
                    yAxisMax: 1.0,
                    yAxisMin: -1.0,
                    dataSet: osciSamples,
                  )
              ),
              ElevatedButton(
                child: Text('START'),
                onPressed: start,
              ),
              ElevatedButton(
                child: Text('STOP'),
                onPressed: stop,
              ),
              Text('Warning: If you run this sample you may create a feedback '
                  'loop which will not be pleasent to listen to.',
                  textAlign: TextAlign.center,),
              SizedBox(height: 5),
            ],
          ),
        ),
      )
    );
  }

  void start(){
    // create Oboe audio stream
    if(!engineCreated) {stream.engineCreate();}
    // set recording device id
    stream.engineSetRecordingDeviceId(recordingDeviceId);
    // set playback device id
    stream.engineSetPlaybackDeviceId(recordingDeviceId);
    // set audio library
    stream.engineSetAPI(api);
    // set sample rate
    stream.engineNative1setDefaultStreamValues(sampleRate, framesPerBurst);
    // start Oboe audio passthrough (input buffer - processing - output buffer)
    stream.engineSetEffectOn(true);
  }

  void stop(){
    // stop Oboe audio passthrough
    stream.engineSetEffectOn(false);
    // delete Oboe audio stream
    stream.engineDelete();
    // flag engine status
    engineCreated = false;
  }

  void receiveSamples(){
    // receive the output sample buffer from Oboe from callback port
    stream.interactiveCppRequests
      .listen((data) {
        Float32List sampleBuffer = Float32List.view(data.buffer);
        // monitor the samples
        monitorSamples(sampleBuffer);
      });
  }

  void monitorSamples(Float32List sampleBuffer){

    // get maximum sample in update interval
    for (int n = 0; n < sampleBuffer.length; n++) {
      if (sampleBuffer[n].toDouble().abs() > sampleMax.abs()) {
        sampleMax = sampleBuffer[n].toDouble();
      }
    }
    sampleCount = sampleCount + sampleBuffer.length;

    // update oscilloscope with maximum sample
    // (oscilloscope drawing too slow for real-time update)
    if(sampleCount > sampleRate / osciUpdateRate){
      setState(() {
        osciSamples.add(sampleMax);
      });

      // reset
      sampleCount = 0;
      sampleMax = 0;
    }
  }

  Future<void> getMicrophonePermission() async {
    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      print('Microphone permission not granted');
    }
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
}

