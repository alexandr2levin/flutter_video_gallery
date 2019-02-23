
import 'package:flutter/material.dart';
import 'package:flutter_video_gallery/domain/videos_manager.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_range_slider/flutter_range_slider.dart';

class Video extends StatefulWidget {
  Video(this._videosManager, this._videoId);

  final VideosManager _videosManager;
  final String _videoId;

  @override
  State<StatefulWidget> createState() => VideoState();

}

class VideoState extends State<Video> {

  VideosManager get _videosManager => widget._videosManager;

  VideoPlayerController _controller;

  bool _isPlaying = false;
  Duration _duration;
  Duration _position;

  Duration _trimStart;
  Duration _trimEnd;

  // use busy when we don't want to handle user's input
  get _busy => _loadingController || _trimming;
  var _loadingController = false;
  var _trimming = false;

  @override
  void initState() {
    super.initState();
    _initializeController();
  }

  void _initializeController() async {
    _loadingController = true;
    setState(() {});

    var info = await _videosManager.videoInfo(widget._videoId);
    _controller = VideoPlayerController.file(info.file)
      ..setLooping(true)
      ..addListener(() {
        var isPlaying = _controller.value.isPlaying;
        var duration = _controller.value.duration;
        var position = _controller.value.position;

        if(position > duration) {
          position = duration;
        }

        setState(() {
          _isPlaying = isPlaying;
          _duration = duration;
          _position = position;
        });
      })
      ..initialize().then((_) {
        _loadingController = false;
        _trimStart = Duration.zero;
        _trimEnd = _controller.value.duration;
        // Ensure the first frame is shown after the video is initialized,
        // even before the play button has been pressed.
        setState(() {});
      });
  }

  void _reinitializeController() {
    _controller?.dispose();
    _controller = null;
    _initializeController();
  }

  @override
  void deactivate() {
    _controller?.setVolume(0.0);
    super.deactivate();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget content;
    if (_controller == null || !_controller.value.initialized) {
      content = null;
    } else {
      content = Stack(
        children: <Widget>[
          Center(
            child: AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              child: VideoPlayer(_controller),
            ),
          ),
          _playPauseControls(),
          Positioned(
            right: 0.0,
            left: 0.0,
            bottom: 0.0,
            child: _bottomControls(),
          ),
          _busy ? _busyLayer() : Container()
        ],
      );
    }

    return Container(
      color: Colors.black,
      child: content,
    );
  }

  Widget _busyLayer() {
    return Container(
      color: Colors.black38,
      child: Center(
        child: SizedBox(
            width: 48.0,
            height: 48.0,
            child: CircularProgressIndicator()
        )
      ),
    );
  }
  
  Widget _playPauseControls() {
    return GestureDetector(
      onTap: _switchPlayPause,
      behavior: HitTestBehavior.translucent,
      child: Center(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white70,
            shape: BoxShape.circle,
          ),
          width: 64.0,
          height: 64.0,
          child: Icon(
            _isPlaying ? Icons.pause : Icons.play_arrow,
            size: 48.0,
          ),
        ),
      ),
    );
  }

  Widget _bottomControls() {
    // use Material because Slider won't work without it
    return Material(
      color: Colors.black38,
      child: Padding(
        padding: EdgeInsets.all(8.0),
        child: Column(
          children: <Widget>[
            _bottomControlsSeek(),
            _bottomControlsTrim(),
          ],
        ),
      ),
    );
  }

  Widget _bottomControlsSeek() {
    return Row(
      children: <Widget>[
        Expanded(
          child: Slider(
            value: _position.inMilliseconds.toDouble(),
            min: 0.0,
            max: _duration.inMilliseconds.toDouble(),
            onChanged: (value) {
              _seek(Duration(milliseconds: (value).toInt()));
            },
          ),
        ),
        IconButton(
          icon: Icon(Icons.share, color: Colors.white),
          onPressed: _share,
        ),
      ],
    );
  }

  Widget _bottomControlsTrim() {
    print('trimStart "$_trimStart"');
    print('trimEnd "$_trimEnd"');
    print('position "$_position"');
    print('duration "$_duration"');
    return Row(
      children: <Widget>[
        Expanded(
          child: RangeSlider(
            lowerValue: _trimStart.inMilliseconds.toDouble(),
            upperValue: _trimEnd.inMilliseconds.toDouble(),
            min: 0.0,
            max: _duration.inMilliseconds.toDouble(),
            onChanged: (lowerValue, upperValue) {
              _trimStart = Duration(milliseconds: lowerValue.toInt());
              _trimEnd = Duration(milliseconds: upperValue.toInt());
            },
          ),
        ),
        IconButton(
          icon: Icon(Icons.content_cut, color: Colors.white),
          onPressed: _trim,
        )
      ],
    );
  }

  void _switchPlayPause() {
    if(_busy) return;
    if(_isPlaying) {
      _controller.pause();
    } else {
      _controller.play();
    }
  }

  void _seek(Duration duration) {
    if(_busy) return;
    _controller.seekTo(duration);
  }

  void _trim() async {
    setState(() {
      _trimming = true;
    });
    await _videosManager.trimVideo(widget._videoId, _trimStart, _trimEnd);
    setState(() {
      _trimming = false;
    });
    _reinitializeController();
  }

  void _share() async {
    await _videosManager.share(widget._videoId);
  }

}