import 'dart:ffi';
import 'dart:async';
import 'package:flutter/services.dart';

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

  FlutterOboe(){

    final oboeLib = DynamicLibrary.open('libflutter_oboe.so');

    engineCreate = oboeLib
      .lookup<NativeFunction<LiveEffectEngine_create>>('LiveEffectEngine_create')
      .asFunction();

    engineDelete = oboeLib
        .lookup<NativeFunction<LiveEffectEngine_delete>>('LiveEffectEngine_delete')
        .asFunction();

    engineSetEffectOn = oboeLib
        .lookup<NativeFunction<LiveEffectEngine_setEffectOn>>('LiveEffectEngine_setEffectOn')
        .asFunction();

    engineSetRecordingDeviceId = oboeLib
        .lookup<NativeFunction<LiveEffectEngine_setRecordingDeviceId>>('LiveEffectEngine_setRecordingDeviceId')
        .asFunction();

    engineSetPlaybackDeviceId = oboeLib
        .lookup<NativeFunction<LiveEffectEngine_setPlaybackDeviceId>>('LiveEffectEngine_setPlaybackDeviceId')
        .asFunction();

    engineSetAPI = oboeLib
        .lookup<NativeFunction<LiveEffectEngine_setAPI>>('LiveEffectEngine_setAPI')
        .asFunction();

    engineIsAAudioRecommended = oboeLib
        .lookup<NativeFunction<LiveEffectEngine_isAAudioRecommended>>('LiveEffectEngine_isAAudioRecommended')
        .asFunction();

    engineNative1setDefaultStreamValues = oboeLib
        .lookup<NativeFunction<LiveEffectEngine_native_1setDefaultStreamValues>>('LiveEffectEngine_native_1setDefaultStreamValues')
        .asFunction();
  }
}

