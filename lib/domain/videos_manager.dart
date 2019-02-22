
import 'dart:io';
import 'package:path/path.dart';
import 'package:uuid/uuid.dart';
import 'package:rxdart/rxdart.dart';
import 'package:path_provider/path_provider.dart';

class VideosManager {

  var _videosSubject = BehaviorSubject<List<VideoInfo>>();

  List<VideoInfo> _videos;
  var uuid = Uuid();

  // video file's name pattern is "id_datetime.mp4"
  Future<void> _initializeIfNot() async {
    if(_videos != null) return;
    _loadVideosInfoFromStorage();
    /*
    reason: File system watching is not supported on Android platform
    videosDir.watch(events: FileSystemEvent.create).listen((fileSystemEvent) {
      print('created "${fileSystemEvent.path}"');
      var videoInfo = VideoInfo.fromFile(File(fileSystemEvent.path));
      _videos.add(videoInfo);
      _videosSubject.add(_videos);
    });
    */
  }

  Future<void> _loadVideosInfoFromStorage() async {
    var appDir = await getApplicationDocumentsDirectory();
    var videosDir = Directory('${appDir.path}/videos/');
    if(!videosDir.existsSync()) videosDir.createSync();
    var videoFiles = videosDir.listSync(followLinks: false)
        .map((fileSystemEntry) {
      return File(fileSystemEntry.path);
    });
    _videos = videoFiles.map((file) => VideoInfo.fromFile(file)).toList();
    print('videos count "${_videos.length}"');

    _videosSubject.add(_videos);
  }

  Future<VideoInfo> createNewVideoInfo() async {
    var appDir = await getApplicationDocumentsDirectory();

    var id = uuid.v1();
    var nowUtc = DateTime.now().toUtc();
    var file = File('${appDir.path}/videos/${id}_${nowUtc.toIso8601String()}.mp4');
    return VideoInfo(
      uuid.v1(),
      file,
      nowUtc,
    );
  }

  Future<void> removeVideo(String id) async {
    await _initializeIfNot();
    var info = await videoInfo(id);
    info.file.deleteSync();
    await _loadVideosInfoFromStorage();
  }

  Future<VideoInfo> videoInfo(String id) async {
    await _initializeIfNot();
    return _videos.firstWhere((info) => info.id == id);
  }

  Future<void> notifyRecorded() async {
    await _loadVideosInfoFromStorage();
  }

  Stream<List<VideoInfo>> observeVideos() async* {
    await _initializeIfNot();
    yield* _videosSubject;
  }

  void dispose() {
    _videosSubject.close();
  }

}

class VideoInfo {
  VideoInfo(this.id, this.file, this.recordedAt);

  final String id;
  final File file;
  final DateTime recordedAt;

  factory VideoInfo.fromFile(File file) {
    var regExp = RegExp('(.*)_(.*)\\.');

    var fileName = basename(file.path);
    var match = regExp.firstMatch(fileName);
    var id = match.group(1);
    var recordedAtString = match.group(2);
    return VideoInfo(id, file, DateTime.parse(recordedAtString));
  }

  @override
  String toString() {
    return 'VideoInfo{id: $id, file: $file, recordedAt: $recordedAt}';
  }


}