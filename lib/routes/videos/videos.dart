import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_video_gallery/domain/videos_manager.dart';
import 'package:flutter_video_gallery/routes/videos/video_item.dart';


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

  Widget contentBody(List<VideoInfo> videos) {
    if(videos.isEmpty) {
      return Center(
        child: Text("No videos recorded yet"),
      );
    }
    return Scrollbar(
        child: OrientationBuilder(
          builder: (context, orientation) {
            var gridHorCount = orientation == Orientation.portrait ? 2 : 3;
            return GridView.builder(
              itemCount: videos.length,
              padding: EdgeInsets.all(4.0),
              gridDelegate: new SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: gridHorCount,
              ),
              itemBuilder: (context, i) {
                var video = videos[i];
                return VideoItem(
                  video,
                  onTap: () {
                    print('tap on video "$video"');
                  },
                  onLongPress: () {
                    _videosManager.removeVideo(video.id);
                    Scaffold.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Video removed")
                      ),
                    );
                  },
                );
              },
            );
          },
        )
    );
  }

  void toRecorder() {
    Navigator.of(context).pushNamed('/recorder');
  }

}