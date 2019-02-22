import 'package:flutter/material.dart';
import 'package:flutter_video_gallery/routes/videos/videos.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Video Gallery',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Videos(),
    );
  }
}