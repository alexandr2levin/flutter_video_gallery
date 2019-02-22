
import 'package:flutter/material.dart';
import 'package:flutter_video_gallery/domain/videos_manager.dart';
import 'package:camera/camera.dart';

class Recorder extends StatefulWidget {
  Recorder(this._videosManager);

  VideosManager _videosManager;

  @override
  State<StatefulWidget> createState() => _RecorderState();

}

class _RecorderState extends State<Recorder> {

  VideosManager get _videosManager => widget._videosManager;

  CameraController _controller;

  var _recording = false;

  @override
  void initState() {
    super.initState();
    initialize();
  }

  void initialize() async {
    // wait for transition to complete to avoid lags
    await Future.delayed(Duration(milliseconds: 500));

    var cameras = await availableCameras();
    _controller = CameraController(cameras[0], ResolutionPreset.high);
    _controller.initialize().then((_) {
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
    _recording = !_recording;

    if(_recording) {
      var videoInfo = await _videosManager.createNewVideoInfo();
      await _controller.startVideoRecording(videoInfo.file.path);
    } else {
      await _controller.stopVideoRecording();
      await _videosManager.notifyRecorded();
    }

    setState(() {});
  }

}