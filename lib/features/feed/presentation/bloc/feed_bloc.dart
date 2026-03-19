import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/post.dart';
import '../../domain/repositories/post_repository.dart';
import 'feed_event.dart';
import 'feed_state.dart';

class FeedBloc extends Bloc<FeedEvent, FeedState> {
  final PostRepository postRepository;
  static const int _pageSize = 10;

  FeedBloc({required this.postRepository}) : super(FeedInitial()) {
    on<FeedLoadRequested>(_onLoad);
    on<FeedLoadMore>(_onLoadMore);
    on<FeedRefreshRequested>(_onRefresh);
    on<FeedTrackView>(_onTrackView);
    on<FeedToggleLike>(_onToggleLike);
    on<FeedSharePost>(_onSharePost);
    on<FeedToggleSave>(_onToggleSave);
    on<FeedSeedPosts>(_onSeedPosts);
  }

  Future<void> _onLoad(FeedLoadRequested event, Emitter<FeedState> emit) async {
    emit(FeedLoading());
    final result = await postRepository.getFeed(limit: _pageSize, currentUserId: event.currentUserId);
    result.fold(
      (failure) => emit(FeedError(failure.message)),
      (posts) => emit(FeedLoaded(
        posts: posts,
        hasReachedEnd: posts.length < _pageSize,
      )),
    );
  }

  Future<void> _onSeedPosts(FeedSeedPosts event, Emitter<FeedState> emit) async {
    emit(FeedLoaded(
      posts: event.posts,
      hasReachedEnd: true,
    ));
  }

  Future<void> _onLoadMore(FeedLoadMore event, Emitter<FeedState> emit) async {
    final current = state;
    if (current is! FeedLoaded || current.hasReachedEnd || current.isLoadingMore) return;

    emit(current.copyWith(isLoadingMore: true));

    final cursor = current.posts.last.createdAt.toIso8601String();
    final result = await postRepository.getFeed(cursor: cursor, limit: _pageSize, currentUserId: event.currentUserId);

    result.fold(
      (failure) => emit(current.copyWith(isLoadingMore: false)),
      (newPosts) => emit(current.copyWith(
        posts: [...current.posts, ...newPosts],
        hasReachedEnd: newPosts.length < _pageSize,
        isLoadingMore: false,
      )),
    );
  }

  Future<void> _onRefresh(FeedRefreshRequested event, Emitter<FeedState> emit) async {
    final result = await postRepository.getFeed(limit: _pageSize, currentUserId: event.currentUserId);
    result.fold(
      (failure) {
        // Giữ dữ liệu cũ nếu refresh thất bại
        if (state is FeedLoaded) return;
        emit(FeedError(failure.message));
      },
      (posts) => emit(FeedLoaded(
        posts: posts,
        hasReachedEnd: posts.length < _pageSize,
      )),
    );
  }

  Future<void> _onTrackView(FeedTrackView event, Emitter<FeedState> emit) async {
    // Fire-and-forget: không cần update UI ngay
    final result = await postRepository.trackView(event.postId);
    result.fold(
      (_) {}, // Ignore error — view tracking is best-effort
      (newCount) {
        final current = state;
        if (current is FeedLoaded) {
          final updatedPosts = current.posts.map((p) {
            if (p.id == event.postId) {
              return Post(
                id: p.id, userId: p.userId, content: p.content, title: p.title,
                mediaUrls: p.mediaUrls, mediaType: p.mediaType, postType: p.postType,
                hashtags: p.hashtags, location: p.location, thumbnailUrl: p.thumbnailUrl,
                duration: p.duration, relatedCourseId: p.relatedCourseId,
                relatedPianoId: p.relatedPianoId, visibility: p.visibility,
                likesCount: p.likesCount, commentsCount: p.commentsCount,
                sharesCount: p.sharesCount, viewsCount: newCount,
                isPinned: p.isPinned, isLiked: p.isLiked, isSaved: p.isSaved, author: p.author,
                createdAt: p.createdAt, updatedAt: p.updatedAt,
              );
            }
            return p;
          }).toList();
          emit(current.copyWith(posts: updatedPosts));
        }
      },
    );
  }

  Future<void> _onToggleLike(FeedToggleLike event, Emitter<FeedState> emit) async {
    final current = state;
    if (current is! FeedLoaded) return;

    // Optimistic update — toggle ngay trên UI
    final updatedPosts = current.posts.map((p) {
      if (p.id == event.postId) {
        return Post(
          id: p.id, userId: p.userId, content: p.content, title: p.title,
          mediaUrls: p.mediaUrls, mediaType: p.mediaType, postType: p.postType,
          hashtags: p.hashtags, location: p.location, thumbnailUrl: p.thumbnailUrl,
          duration: p.duration, relatedCourseId: p.relatedCourseId,
          relatedPianoId: p.relatedPianoId, visibility: p.visibility,
          likesCount: p.likesCount + (event.isCurrentlyLiked ? -1 : 1),
          commentsCount: p.commentsCount, sharesCount: p.sharesCount,
          viewsCount: p.viewsCount, isPinned: p.isPinned,
          isLiked: !event.isCurrentlyLiked, isSaved: p.isSaved, author: p.author,
          createdAt: p.createdAt, updatedAt: p.updatedAt,
        );
      }
      return p;
    }).toList();
    emit(current.copyWith(posts: updatedPosts));

    // Gọi API
    final result = await postRepository.toggleLike(event.postId, event.isCurrentlyLiked);
    result.fold(
      (failure) {
        // Revert nếu lỗi
        emit(current);
      },
      (_) {}, // Success — UI đã đúng
    );
  }

  Future<void> _onSharePost(FeedSharePost event, Emitter<FeedState> emit) async {
    final result = await postRepository.sharePost(event.postId);
    result.fold(
      (_) {},
      (newCount) {
        final current = state;
        if (current is FeedLoaded) {
          final updatedPosts = current.posts.map((p) {
            if (p.id == event.postId) {
              return Post(
                id: p.id, userId: p.userId, content: p.content, title: p.title,
                mediaUrls: p.mediaUrls, mediaType: p.mediaType, postType: p.postType,
                hashtags: p.hashtags, location: p.location, thumbnailUrl: p.thumbnailUrl,
                duration: p.duration, relatedCourseId: p.relatedCourseId,
                relatedPianoId: p.relatedPianoId, visibility: p.visibility,
                likesCount: p.likesCount, commentsCount: p.commentsCount,
                sharesCount: newCount, viewsCount: p.viewsCount,
                isPinned: p.isPinned, isLiked: p.isLiked, isSaved: p.isSaved, author: p.author,
                createdAt: p.createdAt, updatedAt: p.updatedAt,
              );
            }
            return p;
          }).toList();
          emit(current.copyWith(posts: updatedPosts));
        }
      },
    );
  }

  Future<void> _onToggleSave(FeedToggleSave event, Emitter<FeedState> emit) async {
    final current = state;
    if (current is! FeedLoaded) return;

    // Optimistic update
    final updatedPosts = current.posts.map((p) {
      if (p.id == event.postId) {
        return Post(
          id: p.id, userId: p.userId, content: p.content, title: p.title,
          mediaUrls: p.mediaUrls, mediaType: p.mediaType, postType: p.postType,
          hashtags: p.hashtags, location: p.location, thumbnailUrl: p.thumbnailUrl,
          duration: p.duration, relatedCourseId: p.relatedCourseId,
          relatedPianoId: p.relatedPianoId, visibility: p.visibility,
          likesCount: p.likesCount, commentsCount: p.commentsCount,
          sharesCount: p.sharesCount, viewsCount: p.viewsCount,
          isPinned: p.isPinned, isLiked: p.isLiked,
          isSaved: !event.isCurrentlySaved, author: p.author,
          createdAt: p.createdAt, updatedAt: p.updatedAt,
        );
      }
      return p;
    }).toList();
    emit(current.copyWith(posts: updatedPosts));

    final result = await postRepository.toggleSave(event.postId, event.isCurrentlySaved);
    result.fold(
      (failure) => emit(current), // Revert
      (_) {},
    );
  }
}
