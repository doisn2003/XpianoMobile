import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/datasources/home_remote_data_source.dart';
import 'home_feed_event.dart';
import 'home_feed_state.dart';
import '../../../data/models/post_model.dart';

class HomeFeedBloc extends Bloc<HomeFeedEvent, HomeFeedState> {
  final HomeRemoteDataSource dataSource;

  HomeFeedBloc({required this.dataSource}) : super(HomeFeedInitial()) {
    on<LoadFeedEvent>(_onLoadFeed);
    on<LikePostEvent>(_onLikePost);
    on<CreatePostEvent>(_onCreatePost);
  }

  Future<void> _onLoadFeed(LoadFeedEvent event, Emitter<HomeFeedState> emit) async {
    emit(HomeFeedLoading());
    try {
      final posts = await dataSource.getFeed();
      emit(HomeFeedLoaded(posts));
    } catch (e) {
      emit(HomeFeedError('Lỗi tải bảng tin: $e'));
    }
  }

  Future<void> _onLikePost(LikePostEvent event, Emitter<HomeFeedState> emit) async {
    if (state is HomeFeedLoaded) {
      final currentState = state as HomeFeedLoaded;
      final currentPosts = List<PostModel>.from(currentState.posts);

      final index = currentPosts.indexWhere((p) => p.id == event.postId);
      if (index != -1) {
        // Optimistic update
        final post = currentPosts[index];
        final newIsLiked = true; // For simple demo, usually depends on current status
        final newLikesCount = post.likesCount + 1;
        
        currentPosts[index] = PostModel(
          id: post.id,
          userId: post.userId,
          content: post.content,
          mediaUrls: post.mediaUrls,
          mediaType: post.mediaType,
          createdAt: post.createdAt,
          likesCount: newLikesCount,
          commentsCount: post.commentsCount,
          authorName: post.authorName,
          authorAvatar: post.authorAvatar,
        );
        emit(HomeFeedLoaded(currentPosts));

        try {
          await dataSource.likePost(event.postId);
        } catch (e) {
          // Revert if error
          currentPosts[index] = post;
          emit(HomeFeedLoaded(currentPosts));
        }
      }
    }
  }

  Future<void> _onCreatePost(CreatePostEvent event, Emitter<HomeFeedState> emit) async {
    List<PostModel> previousPosts = [];
    if (state is HomeFeedLoaded) {
      previousPosts = (state as HomeFeedLoaded).posts;
    }
    
    emit(CreatePostLoading(previousPosts));
    try {
      final newPost = await dataSource.createPost(
        content: event.content,
        mediaFile: event.mediaFile,
      );
      
      // Update feed
      final updatedPosts = [newPost, ...previousPosts];
      emit(HomeFeedLoaded(updatedPosts));
    } catch (e) {
      emit(HomeFeedError('Lỗi tạo bài viết: $e'));
      // Resume old state after error
      emit(HomeFeedLoaded(previousPosts));
    }
  }
}
