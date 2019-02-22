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

  @override
  Widget build(BuildContext context) {
    var videos = List.generate(9, (i) {
      return VideoInfo(
        "$i",
        File("foo"),
        DateTime.now()
      );
    });

    return Scaffold(
      appBar: AppBar(
        title: Text('Videos'),
      ),
      body: Scrollbar(
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
                );
              },
            );
          },
        )
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: toRecorder,
        child: Icon(Icons.videocam),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  void toRecorder() {

  }

}