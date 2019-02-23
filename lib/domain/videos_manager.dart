
import 'dart:io';
import 'package:path/path.dart';
import 'package:uuid/uuid.dart';
import 'package:rxdart/rxdart.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';

class VideosManager {

  final _uuid = Uuid();
  final _ffmpeg = FlutterFFmpeg();

  final _videosInfoSubject = BehaviorSubject<List<VideoInfo>>();
  List<VideoInfo> _videosInfo;

  // video file's name pattern is "id_datetime.mp4"
  Future<void> _initializeIfNot() async {
    if(_videosInfo != null) return;
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
    var videosDir = await _videosDir();
    if(!videosDir.existsSync()) videosDir.createSync();
    var videoFiles = videosDir.listSync(followLinks: false)
        .map((fileSystemEntry) {
      return File(fileSystemEntry.path);
    });
    _videosInfo = videoFiles.map((file) => VideoInfo.fromFile(file)).toList();
    print('videos count "${_videosInfo.length}"');

    _videosInfoSubject.add(_videosInfo);
  }

  Future<Directory> _videosDir() async {
    var appDir = await getApplicationDocumentsDirectory();
    return Directory('${appDir.path}/videos/');
  }

  Future<void> trimVideo(String videoId, Duration from, Duration to) async {
    var tempDir = await getTemporaryDirectory();
    var info = await videoInfo(videoId);

    var input = info.file.path;
    var output = "${tempDir.path}/tmp_${basename(input)}";
    var fromStr = from.toString();
    var lengthStr = (to - from).toString();

    var command = 'ffmpeg -ss $fromStr -i $input -c copy -t $lengthStr $output';
    print('executing command "$command"');
    await _ffmpeg.execute(command);

    await info.file.delete();
    await File(output).copy(input);
  }

  Future<VideoInfo> createNewVideoInfo() async {
    var videosDir = await _videosDir();

    var id = _uuid.v1();
    var nowUtc = DateTime.now().toUtc();
    var file = File('${videosDir.path}/${id}_${nowUtc.toIso8601String()}.mp4');
    return VideoInfo(
      _uuid.v1(),
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
    return _videosInfo.firstWhere((info) => info.id == id);
  }

  Future<void> notifyRecorded() async {
    await _loadVideosInfoFromStorage();
  }

  Stream<List<VideoInfo>> observeVideos() async* {
    await _initializeIfNot();
    yield* _videosInfoSubject;
  }

  void dispose() {
    _videosInfoSubject.close();
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