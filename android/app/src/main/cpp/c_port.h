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

#ifndef C_PORT_H
#define C_PORT_H

#include "DartApiDL/include/dart_api_dl.h"

#ifdef __cplusplus
#define EXTERNC extern "C"
#else
#define EXTERNC
#endif


// === native dart api communication for sending messages to Flutter

EXTERNC int64_t InitializeDartApi(void *data)
{
    return Dart_InitializeApiDL(data);
}

static int64_t DartApiMessagePort = -1;

EXTERNC void SetDartApiMessagePort(int64_t port)
{
    DartApiMessagePort = port;
}

// this will send float array to dart receiver port as a message
void sendMsgToFlutter(uint8_t * msg, intptr_t length)
{
    if (DartApiMessagePort == -1)
      return;
    Dart_CObject obj;
    obj.type = Dart_CObject_kTypedData;
    obj.value.as_typed_data.type = Dart_TypedData_kFloat32;
    obj.value.as_typed_data.values = msg;
    obj.value.as_typed_data.length = length;
    Dart_PostCObject_DL(DartApiMessagePort, &obj);
}

#endif //C_PORT_H
