# flutter_oboe
![image_app](images/app.png?raw=true)<br>
<br>
Example Flutter application implementing a wrapper for the C++ Google Oboe (LiveEffect Sample) library via dart:ffi. 
Target is to reach a minimum microphone to speaker audio latency passthrough with Flutter for Android.
The microphone recording with simultaneous speaker playback can be started by pressing the start button.

In the GUI settings the Sampling Rate and the Audio API (AAudio or OpenSL ES) can be selected dependent on the use case. 
The programming interface also allows to select the recording and playback device_id and the framesPerBurst.

To build the application you have to copy the Oboe library into the root folder.
The Oboe Library can be downloaded from following link https://github.com/google/oboe.
The library is then dynamically linked via CMake in android/app/CMakeLists.txt.

Thanks goes to Richard Heap for his tutorial on dart:ffi https://www.youtube.com/watch?v=X8JD8hHkBMc&t=1380s