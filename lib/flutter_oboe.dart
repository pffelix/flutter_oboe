import 'dart:ffi';
import 'dart:async';
import 'package:flutter/services.dart';
import 'dart:isolate';

typedef LiveEffectEngine_create = Bool Function();
typedef LiveEffectEngineCreate = bool Function();

typedef LiveEffectEngine_delete = Void Function();
typedef LiveEffectEngineDelete = void Function();

typedef LiveEffectEngine_setEffectOn = Bool Function(Bool);
typedef LiveEffectEngineSetEffectOn = bool Function(bool);

typedef LiveEffectEngine_setRecordingDeviceId = Void Function(Int32);
typedef LiveEffectEngineSetRecordingDeviceId = void Function(int);

typedef LiveEffectEngine_setPlaybackDeviceId = Void Function(Int32);
typedef LiveEffectEngineSetPlaybackDeviceId = void Function(int);

typedef LiveEffectEngine_setAPI = Bool Function(Int32);
typedef LiveEffectEngineSetAPI = bool Function(int);

typedef LiveEffectEngine_isAAudioRecommended = Bool Function();
typedef LiveEffectEngineIsAAudioRecommended = bool Function();

typedef LiveEffectEngine_native_1setDefaultStreamValues = Void Function(Int32,
    Int32);
typedef LiveEffectEngineNative1setDefaultStreamValues = void Function(int,
    int);

typedef LiveEffectEngine_setGain = Void Function(Double);
typedef LiveEffectEngineSetGain = void Function(double);

class FlutterOboe {
  static const MethodChannel _channel = const MethodChannel(('flutter_oboe'));

  static Future<String> get platformVersion async {
    return await _channel.invokeMethod('getPlatformVersion');
  }

  late LiveEffectEngineCreate engineCreate;
  late LiveEffectEngineDelete engineDelete;
  late LiveEffectEngineSetEffectOn engineSetEffectOn;
  late LiveEffectEngineSetRecordingDeviceId engineSetRecordingDeviceId;
  late LiveEffectEngineSetPlaybackDeviceId engineSetPlaybackDeviceId;
  late LiveEffectEngineSetAPI engineSetAPI;
  late LiveEffectEngineIsAAudioRecommended engineIsAAudioRecommended;
  late LiveEffectEngineNative1setDefaultStreamValues engineNative1setDefaultStreamValues;
  late LiveEffectEngineSetGain engineSetGain;

  late DynamicLibrary _oboeLib;
  late ReceivePort interactiveCppRequests;

  FlutterOboe(){

    _oboeLib = DynamicLibrary.open('libflutter_oboe.so');

    engineCreate = _oboeLib
      .lookup<NativeFunction<LiveEffectEngine_create>>('LiveEffectEngine_create')
      .asFunction();

    engineDelete = _oboeLib
        .lookup<NativeFunction<LiveEffectEngine_delete>>('LiveEffectEngine_delete')
        .asFunction();

    engineSetEffectOn = _oboeLib
        .lookup<NativeFunction<LiveEffectEngine_setEffectOn>>('LiveEffectEngine_setEffectOn')
        .asFunction();

    engineSetRecordingDeviceId = _oboeLib
        .lookup<NativeFunction<LiveEffectEngine_setRecordingDeviceId>>('LiveEffectEngine_setRecordingDeviceId')
        .asFunction();

    engineSetPlaybackDeviceId = _oboeLib
        .lookup<NativeFunction<LiveEffectEngine_setPlaybackDeviceId>>('LiveEffectEngine_setPlaybackDeviceId')
        .asFunction();

    engineSetAPI = _oboeLib
        .lookup<NativeFunction<LiveEffectEngine_setAPI>>('LiveEffectEngine_setAPI')
        .asFunction();

    engineIsAAudioRecommended = _oboeLib
        .lookup<NativeFunction<LiveEffectEngine_isAAudioRecommended>>('LiveEffectEngine_isAAudioRecommended')
        .asFunction();

    engineNative1setDefaultStreamValues = _oboeLib
        .lookup<NativeFunction<LiveEffectEngine_native_1setDefaultStreamValues>>('LiveEffectEngine_native_1setDefaultStreamValues')
        .asFunction();
    engineSetGain = _oboeLib
      .lookup<NativeFunction<LiveEffectEngine_setGain>>('LiveEffectEngine_setGain')
      .asFunction();
  }

  // messenging over Receive Port, see https://github.com/audiooffler/JucyFluttering
  void initNativeMessenging() async {
    // initialize the native dart API
    final initializeApi = _oboeLib.lookupFunction<IntPtr Function(Pointer<Void>),
        int Function(Pointer<Void>)>("InitializeDartApi");
    if (initializeApi(NativeApi.initializeApiDLData) != 0) {
      throw "Failed to initialize Dart API";
    }

    interactiveCppRequests = ReceivePort();
/*      ..listen((data) {
        Float32List samples = Float32List.view(data.buffer);
        // for (int i = 0; i < samples.length; i++) {
            //print(samples[i].toString()); // print the processed samples
        //}
        receiveSamples(samples);

      });*/

    final int nativePort = interactiveCppRequests.sendPort.nativePort;

    final void Function(int port) setDartApiMessagePort = _oboeLib
        .lookup<NativeFunction<Void Function(Int64 port)>>(
        "SetDartApiMessagePort")
        .asFunction();
    setDartApiMessagePort(nativePort);
  }
}

