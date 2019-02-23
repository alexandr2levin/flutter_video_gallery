# Flutter Video Gallery

App that can record, store and play recorded videos.

## Dependencies

Dart
 * [rxdart](https://pub.dartlang.org/packages/rxdart) – for BehaviourSubject implementation
 * [path](https://pub.dartlang.org/packages/path) – to handle video's paths
 * [uuid](https://pub.dartlang.org/packages/uuid) – to generate uids for videos
 
Flutter specific
 * [path_provider](https://pub.dartlang.org/packages/path_provider) – to access to app's data dir
 * [camera](https://pub.dartlang.org/packages/camera) – to show the camera preview and record the video
 * [video_player](https://pub.dartlang.org/packages/video_player) – to play the video
 
## Architecture

App is splitted into two layers.

 * domain – there is where business logic lives
 * presentation – there is where ui logic lives

