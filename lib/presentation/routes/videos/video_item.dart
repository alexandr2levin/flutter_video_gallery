
import 'package:flutter/material.dart';
import 'package:flutter_video_gallery/domain/videos_manager.dart';

class VideoItem extends StatelessWidget {
  VideoItem(this._videoInfo, {this.onTap, this.onLongPress});

  final VideoInfo _videoInfo;
  final GestureTapCallback onTap;
  final GestureLongPressCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0)
      ),
      clipBehavior: Clip.antiAlias,
      color: Colors.blueGrey[200],
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        splashColor: Colors.white30,
        highlightColor: Colors.white30,
        child: Stack(
          children: <Widget>[
            Positioned(
              bottom: 0.0,
              right: 0.0,
              left: 0.0,
              child: bottomLabel(context),
            ),
          ],
        ),
      )
    );
  }
  
  Widget bottomLabel(BuildContext context) {
    var time = '${_videoInfo.recordedAt.hour}:${_videoInfo.recordedAt.minute}';
    var date = '${_videoInfo.recordedAt.day}''.${_videoInfo.recordedAt.month}''.${_videoInfo.recordedAt.year}';
    return Container(
      padding: EdgeInsets.all(8.0),
      color: Colors.black26,
      child: Opacity(
        opacity: 0.5,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            Text(
              time,
              style: Theme.of(context).accentTextTheme.body1,
            ),
            Text(
              date,
              style: Theme.of(context).accentTextTheme.body2,
            ),
          ],
        ),
      )
    );
  }

}