import 'package:equatable/equatable.dart';
import '../../domain/entities/post.dart';

abstract class FeedState extends Equatable {
  const FeedState();

  @override
  List<Object?> get props => [];
}

class FeedInitial extends FeedState {}

class FeedLoading extends FeedState {}

class FeedLoaded extends FeedState {
  final List<Post> posts;
  final bool hasReachedEnd;
  final bool isLoadingMore;

  const FeedLoaded({
    required this.posts,
    this.hasReachedEnd = false,
    this.isLoadingMore = false,
  });

  FeedLoaded copyWith({
    List<Post>? posts,
    bool? hasReachedEnd,
    bool? isLoadingMore,
  }) {
    return FeedLoaded(
      posts: posts ?? this.posts,
      hasReachedEnd: hasReachedEnd ?? this.hasReachedEnd,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  @override
  List<Object?> get props => [posts, hasReachedEnd, isLoadingMore];
}

class FeedError extends FeedState {
  final String message;
  const FeedError(this.message);

  @override
  List<Object?> get props => [message];
}
