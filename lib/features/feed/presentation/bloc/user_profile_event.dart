import 'package:equatable/equatable.dart';

abstract class UserProfileEvent extends Equatable {
  const UserProfileEvent();
  @override
  List<Object?> get props => [];
}

/// Load hồ sơ công khai của user
class UserProfileLoadRequested extends UserProfileEvent {
  final String userId;
  const UserProfileLoadRequested(this.userId);
  @override
  List<Object?> get props => [userId];
}

/// Load thêm bài viết (pagination)
class UserProfileLoadMorePosts extends UserProfileEvent {}
