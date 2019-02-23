import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_video_gallery/domain/videos_manager.dart';
import 'package:flutter_video_gallery/presentation//routes/videos/video_item.dart';


class Videos extends StatefulWidget {
  Videos(this._videosManager, {Key key}) : super(key: key);

  final VideosManager _videosManager;

  @override
  _VideosState createState() => _VideosState();
}

class _VideosState extends State<Videos> {

  VideosManager get _videosManager => widget._videosManager;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Videos'),
      ),
      body: StreamBuilder(
        stream: _videosManager.observeVideos(),
        builder: (context, AsyncSnapshot<List<VideoInfo>> asyncSnapshot) {
          print('has data: "${asyncSnapshot.data}"');
          if(asyncSnapshot.hasError) {
            print('error: ' + asyncSnapshot.error.toString());
            return errorBody();
          } else if(asyncSnapshot.hasData) {
            return contentBody(asyncSnapshot.data);
          } else {
            return waitBody();
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: toRecorder,
        child: Icon(Icons.videocam),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget errorBody() {
    return Center(
      child: Text("Error while loading videos"),
    );
  }

  Widget waitBody() {
    return Center(
      child: Text("One moment..."),
    );
  }

  Widget contentBody(List<VideoInfo> videosInfo) {
    if(videosInfo.isEmpty) {
      return Center(
        child: Text("No videos recorded yet"),
      );
    }
    return Scrollbar(
        child: OrientationBuilder(
          builder: (context, orientation) {
            var gridHorCount = orientation == Orientation.portrait ? 2 : 3;
            return GridView.builder(
              itemCount: videosInfo.length,
              padding: EdgeInsets.all(4.0),
              gridDelegate: new SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: gridHorCount,
              ),
              itemBuilder: (context, i) {
                var videoInfo = videosInfo[i];
                return VideoItem(
                  videoInfo,
                  onTap: () {
                    openVideo(videoInfo);
                  },
                  onLongPress: () {
                    removeVideo(context, videoInfo);
                  },
                );
              },
            );
          },
        )
    );
  }

  void openVideo(VideoInfo videoInfo) {
    Navigator.of(context).pushNamed('/videos/${videoInfo.id}');
  }
  
  void removeVideo(BuildContext context, VideoInfo videoInfo) {
    _videosManager.removeVideo(videoInfo.id);
    Scaffold.of(context).showSnackBar(
        SnackBar(
          content: Text("Removed"),
          duration: Duration(seconds: 1),
        ),
    );
  }

  void toRecorder() {
    Navigator.of(context).pushNamed('/recorder');
  }

}