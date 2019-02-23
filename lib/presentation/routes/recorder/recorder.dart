
import 'package:flutter/material.dart';
import 'package:flutter_video_gallery/domain/videos_manager.dart';
import 'package:camera/camera.dart';

class Recorder extends StatefulWidget {
  Recorder(this._videosManager);

  final VideosManager _videosManager;

  @override
  State<StatefulWidget> createState() => _RecorderState();

}

class _RecorderState extends State<Recorder> {

  VideosManager get _videosManager => widget._videosManager;

  CameraController _controller;

  var _recording = false;

  // use busy when we don't want to handle user's input
  var _busy = false;

  @override
  void initState() {
    super.initState();
    initialize();
  }

  void initialize() async {
    _busy = true;
    var cameras = await availableCameras();
    _controller = CameraController(cameras[0], ResolutionPreset.medium);
    _controller
        ..addListener(() {
          if(_recording != _controller.value.isRecordingVideo) {
            setState(() {
              _recording = _controller.value.isRecordingVideo;
            });
          }
        })
        ..initialize().then((_) {
          _busy = false;
          if (!mounted) {
            return;
          }
          setState(() {});
        });
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget content;
    if (_controller == null || !_controller.value.isInitialized) {
      content = null;
    } else {
      content = Stack(
        children: <Widget>[
          Center(
            child: AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              child: new CameraPreview(_controller),
            ),
          ),
          Positioned(
            bottom: 16.0,
            right: 0,
            left: 0,
            child: FloatingActionButton(
              child: Icon(
                _recording ? Icons.stop : Icons.brightness_1,
                color: Colors.red[500],
              ),
              backgroundColor: Colors.grey[800],
              onPressed: switchRecording,
            ),
          ),
        ],
      );
    }

    return Container(
      color: Colors.black,
      child: content,
    );
  }

  void switchRecording() async {
    if(_busy) return;
    _busy = true;

    if(!_recording) {
      var videoInfo = await _videosManager.createNewVideoInfo();
      await _controller.startVideoRecording(videoInfo.file.path);
    } else {
      await _controller.stopVideoRecording();
      await _videosManager.notifyRecorded();
    }

    await Future.delayed(Duration(seconds: 1));
    // keep busy for a second to avoid lag on tap spam

    _busy = false;
  }

}