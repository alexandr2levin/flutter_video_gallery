import 'package:flutter/material.dart';
import 'package:flutter_video_gallery/domain/videos_manager.dart';
import 'package:flutter_video_gallery/presentation/app.dart';

void main() {
  var videosManager = VideosManager();
  runApp(App(videosManager));
}