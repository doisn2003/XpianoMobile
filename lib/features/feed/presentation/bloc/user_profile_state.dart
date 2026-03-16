import 'package:equatable/equatable.dart';
import '../../domain/entities/post.dart';

abstract class UserProfileState extends Equatable {
  const UserProfileState();
  @override
  List<Object?> get props => [];
}

class UserProfileInitial extends UserProfileState {}

class UserProfileLoading extends UserProfileState {}

class UserProfileLoaded extends UserProfileState {
  final Map<String, dynamic> profile;
  final List<Post> posts;
  final bool hasReachedEnd;
  final bool isLoadingMorePosts;

  const UserProfileLoaded({
    required this.profile,
    required this.posts,
    this.hasReachedEnd = false,
    this.isLoadingMorePosts = false,
  });

  UserProfileLoaded copyWith({
    Map<String, dynamic>? profile,
    List<Post>? posts,
    bool? hasReachedEnd,
    bool? isLoadingMorePosts,
  }) {
    return UserProfileLoaded(
      profile: profile ?? this.profile,
      posts: posts ?? this.posts,
      hasReachedEnd: hasReachedEnd ?? this.hasReachedEnd,
      isLoadingMorePosts: isLoadingMorePosts ?? this.isLoadingMorePosts,
    );
  }

  @override
  List<Object?> get props => [profile, posts, hasReachedEnd, isLoadingMorePosts];
}

class UserProfileError extends UserProfileState {
  final String message;
  const UserProfileError(this.message);
  @override
  List<Object?> get props => [message];
}
