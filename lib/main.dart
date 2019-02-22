import 'package:flutter/material.dart';
import 'package:flutter_video_gallery/domain/videos_manager.dart';
import 'package:flutter_video_gallery/routes/recorder/recorder.dart';
import 'package:flutter_video_gallery/routes/video/video.dart';
import 'package:flutter_video_gallery/routes/videos/videos.dart';

void main() {
  var videosManager = VideosManager();
  runApp(MyApp(videosManager));
}

class MyApp extends StatelessWidget {
  MyApp(this._videosManager);

  final VideosManager _videosManager;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Video Gallery',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/videos',
      onGenerateRoute: (routeSettings) {
        // temporarily workaround for passing arguments
        // should be replaced with https://github.com/flutter/flutter/pull/27058
        // when it will be merged to stable
        var name = routeSettings.name;

        // I miss Kotlin's "when" expression ;(
        if(name == '/videos') {
          // "/videos"
          return MaterialPageRoute(
            builder: (context) => Videos(_videosManager),
            settings: routeSettings,
          );
        } else if(name.startsWith('/videos/')) {
          // "/videos/{id}"
          var videoId = name.substring(name.lastIndexOf('/'));
          print('routing to "/videos/$videoId"');
          return MaterialPageRoute(
            builder: (context) => Video(_videosManager, videoId),
            settings: routeSettings,
          );
        } else if(name == '/recorder') {
          // "/recorder"
          return MaterialPageRoute(
            builder: (context) => Recorder(_videosManager),
            settings: routeSettings,
          );
        } else {
          throw 'no case for route "$name"';
        }

      },
    );
  }
}