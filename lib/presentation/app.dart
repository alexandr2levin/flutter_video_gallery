import 'package:flutter/material.dart';
import 'package:flutter_video_gallery/domain/videos_manager.dart';
import 'package:flutter_video_gallery/presentation/routes/recorder/recorder.dart';
import 'package:flutter_video_gallery/presentation//routes/video/video.dart';
import 'package:flutter_video_gallery/presentation//routes/videos/videos.dart';

class App extends StatelessWidget {
  App(this._videosManager);

  final VideosManager _videosManager;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Video Gallery',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      onGenerateRoute: (routeSettings) {
        // temporarily workaround for passing arguments
        // should be replaced with https://github.com/flutter/flutter/pull/27058
        // when it will be merged to stable
        var name = routeSettings.name;

        if(name == '/') {
          // represent root as '/videos' for easier arguments parsing
          // note: we can't set MaterialApp.initialRoute to '/videos'
          //       as it don't work with onGenerateRoute
          name = '/videos';
        }

        // I miss Kotlin's "when" expression ;(
        if(name == '/videos') {
          // "/videos"
          return MaterialPageRoute(
            builder: (context) => Videos(_videosManager),
            settings: routeSettings,
          );
        } else if(name.startsWith('/videos/')) {
          // "/videos/{id}"
          var videoId = name.substring(name.lastIndexOf('/') + 1);
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