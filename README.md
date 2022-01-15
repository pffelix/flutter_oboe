# flutter_oboe
![image_setup](images/app.png?raw=true)
Example application implementing a wrapper for the C++ Google Oboe (LiveEffect Sample) library via dart:ffi in Flutter. 
Target is to reach a minimum microphone to speaker audio latency passthrough on Android.
The microphone recording with simultaneous speaker playback can started by pressing the start button.

To build the application you have to copy the Oboe library into the root folder.
The Oboe Library can be downloaded from following link https://github.com/google/oboe.
The library is then dynamically linked via CMake in android/app/CMakeLists.txt.

Thanks goes to Richard Heap for his tutorial to dart:ffi https://www.youtube.com/watch?v=X8JD8hHkBMc&t=1380s