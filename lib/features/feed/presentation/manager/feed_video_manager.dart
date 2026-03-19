import 'package:cached_video_player_plus/cached_video_player_plus.dart';
import 'package:video_player/video_player.dart';

class FeedVideoManager {
  FeedVideoManager();

  final Map<String, CachedVideoPlayerPlus> _players = {};

  Future<VideoPlayerController> getOrCreateController(String postId, String url) async {
    if (_players.containsKey(postId)) {
      if (!_players[postId]!.isInitialized) {
         await _players[postId]!.initialize();
      }
      return _players[postId]!.controller;
    }
    
    final player = CachedVideoPlayerPlus.networkUrl(Uri.parse(url));
    _players[postId] = player;
    
    // Background initialization
    await player.initialize();
    player.controller.setLooping(true);
    
    return player.controller;
  }

  void preloadVideos(List<Map<String, String>> videosInfo) {
    for (var info in videosInfo) {
      final id = info['id'];
      final url = info['url'];
      if (id != null && url != null && !_players.containsKey(id)) {
        getOrCreateController(id, url).catchError((_) {
          return _players[id]?.isInitialized == true ? _players[id]!.controller : throw Exception();
        });
      }
    }
  }

  void disposeOutOfRange(List<String> keepVideoIds) {
    final idsToRemove = _players.keys.where((id) => !keepVideoIds.contains(id)).toList();
    for (var id in idsToRemove) {
      final player = _players.remove(id);
      player?.dispose();
    }
  }

  void disposeAll() {
    for (var player in _players.values) {
      player.dispose();
    }
    _players.clear();
  }

  VideoPlayerController? getController(String postId) {
    if (_players.containsKey(postId) && _players[postId]!.isInitialized) {
      return _players[postId]!.controller;
    }
    return null;
  }
}
