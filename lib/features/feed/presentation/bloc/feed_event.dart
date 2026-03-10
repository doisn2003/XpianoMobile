import 'package:equatable/equatable.dart';

abstract class FeedEvent extends Equatable {
  const FeedEvent();

  @override
  List<Object?> get props => [];
}

/// Load feed lần đầu
class FeedLoadRequested extends FeedEvent {}

/// Load thêm trang tiếp theo (pagination)
class FeedLoadMore extends FeedEvent {}

/// Pull-to-refresh
class FeedRefreshRequested extends FeedEvent {}

/// Ghi nhận lượt xem bài viết (gọi sau 3s dừng trên 1 bài)
class FeedTrackView extends FeedEvent {
  final String postId;
  const FeedTrackView(this.postId);

  @override
  List<Object?> get props => [postId];
}

/// Like / Unlike bài viết
class FeedToggleLike extends FeedEvent {
  final String postId;
  final bool isCurrentlyLiked;
  const FeedToggleLike(this.postId, this.isCurrentlyLiked);

  @override
  List<Object?> get props => [postId, isCurrentlyLiked];
}

/// Chia sẻ bài viết
class FeedSharePost extends FeedEvent {
  final String postId;
  const FeedSharePost(this.postId);

  @override
  List<Object?> get props => [postId];
}
