import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/post_repository.dart';
import 'user_profile_event.dart';
import 'user_profile_state.dart';

class UserProfileBloc extends Bloc<UserProfileEvent, UserProfileState> {
  final PostRepository postRepository;
  static const int _pageSize = 10;
  String? _userId;

  UserProfileBloc({required this.postRepository}) : super(UserProfileInitial()) {
    on<UserProfileLoadRequested>(_onLoad);
    on<UserProfileLoadMorePosts>(_onLoadMorePosts);
    on<UserProfileToggleFollow>(_onToggleFollow);
  }

  Future<void> _onLoad(UserProfileLoadRequested event, Emitter<UserProfileState> emit) async {
    emit(UserProfileLoading());
    _userId = event.userId;

    final profileResult = await postRepository.getUserPublicProfile(event.userId);
    final postsResult = await postRepository.getUserPosts(event.userId, limit: _pageSize);

    // Nếu profile lỗi → emit error
    if (profileResult.isLeft()) {
      final failure = profileResult.fold((f) => f, (_) => null)!;
      emit(UserProfileError(failure.message));
      return;
    }

    final profile = profileResult.fold((_) => <String, dynamic>{}, (p) => p);
    final posts = postsResult.fold((_) => <dynamic>[], (p) => p);

    emit(UserProfileLoaded(
      profile: profile,
      posts: List.from(posts),
      hasReachedEnd: posts.length < _pageSize,
    ));
  }

  Future<void> _onLoadMorePosts(UserProfileLoadMorePosts event, Emitter<UserProfileState> emit) async {
    final current = state;
    if (current is! UserProfileLoaded || current.hasReachedEnd || current.isLoadingMorePosts || _userId == null) return;

    emit(current.copyWith(isLoadingMorePosts: true));

    final cursor = current.posts.last.createdAt.toIso8601String();
    final result = await postRepository.getUserPosts(_userId!, cursor: cursor, limit: _pageSize);

    result.fold(
      (_) => emit(current.copyWith(isLoadingMorePosts: false)),
      (newPosts) => emit(current.copyWith(
        posts: [...current.posts, ...newPosts],
        hasReachedEnd: newPosts.length < _pageSize,
        isLoadingMorePosts: false,
      )),
    );
  }

  Future<void> _onToggleFollow(UserProfileToggleFollow event, Emitter<UserProfileState> emit) async {
    final current = state;
    if (current is! UserProfileLoaded || _userId == null) return;

    final isFollowing = current.profile['is_following'] == true;
    final stats = current.profile['stats'] as Map<String, dynamic>? ?? {};
    final followersCount = stats['followers_count'] ?? 0;

    // Optimistic update
    final newProfile = Map<String, dynamic>.from(current.profile);
    newProfile['is_following'] = !isFollowing;

    final newStats = Map<String, dynamic>.from(stats);
    newStats['followers_count'] = isFollowing ? (followersCount - 1) : (followersCount + 1);
    newProfile['stats'] = newStats;

    emit(current.copyWith(profile: newProfile));

    final result = await postRepository.toggleFollowUser(_userId!, isFollowing);

    result.fold(
      (failure) {
        // Revert on failure
        emit(current);
      },
      (_) {},
    );
  }
}
