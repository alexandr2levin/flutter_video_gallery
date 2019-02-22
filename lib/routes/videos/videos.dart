import 'package:flutter/material.dart';
import 'package:flutter_video_gallery/domain/videos_manager.dart';

class Videos extends StatefulWidget {
  Videos(this._videosManager, {Key key}) : super(key: key);

  VideosManager _videosManager;

  @override
  _VideosState createState() => _VideosState();
}

class _VideosState extends State<Videos> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Videos'),
      ),
      body: Center(
        child: Text('Todo'),
      ),
    );
  }

}