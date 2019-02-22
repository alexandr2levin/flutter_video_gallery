
import 'package:flutter/material.dart';
import 'package:flutter_video_gallery/domain/videos_manager.dart';

class VideoItem extends StatelessWidget {
  VideoItem(this._videoInfo);

  final VideoInfo _videoInfo;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(8.0),
      child: Stack(
        children: <Widget>[
          Container(color: Colors.green),
          Positioned(
            bottom: 0.0,
            right: 0.0,
            left: 0.0,
            child: bottomLabel(),
          ),
        ],
      ),
    );
  }
  
  Widget bottomLabel() {
    var time = '${_videoInfo.recordedAt.hour}:${_videoInfo.recordedAt.minute}';
    var date = '${_videoInfo.recordedAt.day}''.${_videoInfo.recordedAt.month}''.${_videoInfo.recordedAt.year}';
    return Container(
      color: Colors.black54,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          Text(time),
          Text(date),
        ],
      ),
    );
  }

}