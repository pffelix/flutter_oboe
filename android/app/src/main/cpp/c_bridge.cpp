/**
 * Copyright 2022 Felix Pfreundtner
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#include "LiveEffectEngine.h"
#include "logging_macros.h"

#ifdef __cplusplus
#define EXTERNC extern "C"
#else
#define EXTERNC
#endif

/**
* native c wrapper for connecting OBOE Live effect sample with dart:ffi
* https://github.com/google/oboe/tree/master/samples/LiveEffect
*/

static const int kOboeApiAAudio = 0;
static const int kOboeApiOpenSLES = 1;

static LiveEffectEngine *engine = nullptr;

EXTERNC bool LiveEffectEngine_create() {
    if (engine == nullptr) {
        engine = new LiveEffectEngine();
    }

    return (engine != nullptr) ? true : false;
}

EXTERNC void LiveEffectEngine_delete() {
    if (engine) {
        engine->setEffectOn(false);
        delete engine;
        engine = nullptr;
    }
}

EXTERNC bool LiveEffectEngine_setEffectOn(bool isEffectOn) {
    if (engine == nullptr) {
        LOGE(
            "Engine is null, you must call createEngine before calling this "
            "method");
        return false;
    }

    return engine->setEffectOn(isEffectOn) ? true : false;
}

EXTERNC void LiveEffectEngine_setRecordingDeviceId(int32_t deviceId) {
    if (engine == nullptr) {
        LOGE(
            "Engine is null, you must call createEngine before calling this "
            "method");
        return;
    }

    engine->setRecordingDeviceId(deviceId);
}

EXTERNC void LiveEffectEngine_setPlaybackDeviceId(int32_t deviceId) {
    if (engine == nullptr) {
        LOGE(
            "Engine is null, you must call createEngine before calling this "
            "method");
        return;
    }

    engine->setPlaybackDeviceId(deviceId);
}

EXTERNC bool LiveEffectEngine_setAPI(int32_t apiType) {
    if (engine == nullptr) {
        LOGE(
            "Engine is null, you must call createEngine "
            "before calling this method");
        return false;
    }

    oboe::AudioApi audioApi;
    switch (apiType) {
        case kOboeApiAAudio:
            audioApi = oboe::AudioApi::AAudio;
            break;
        case kOboeApiOpenSLES:
            audioApi = oboe::AudioApi::OpenSLES;
            break;
        default:
            LOGE("Unknown API selection to setAPI() %d", apiType);
            return false;
    }

    return engine->setAudioApi(audioApi) ? true : false;
}

EXTERNC bool LiveEffectEngine_isAAudioRecommended() {
    if (engine == nullptr) {
        LOGE(
            "Engine is null, you must call createEngine "
            "before calling this method");
        return false;
    }
    return engine->isAAudioRecommended() ? true : false;
}

EXTERNC void LiveEffectEngine_native_1setDefaultStreamValues(int32_t sampleRate,
                                                             int32_t framesPerBurst) {
    oboe::DefaultStreamValues::SampleRate = sampleRate;
    oboe::DefaultStreamValues::FramesPerBurst = framesPerBurst;
}

EXTERNC void LiveEffectEngine_setGain(double gain) {
    engine->setGain((float) gain);
}

