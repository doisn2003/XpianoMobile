import 'package:equatable/equatable.dart';
import '../../../data/models/post_model.dart';

abstract class HomeFeedState extends Equatable {
  const HomeFeedState();

  @override
  List<Object?> get props => [];
}

class HomeFeedInitial extends HomeFeedState {}

class HomeFeedLoading extends HomeFeedState {}

class HomeFeedLoaded extends HomeFeedState {
  final List<PostModel> posts;

  const HomeFeedLoaded(this.posts);

  @override
  List<Object> get props => [posts];
}

class HomeFeedError extends HomeFeedState {
  final String message;

  const HomeFeedError(this.message);

  @override
  List<Object> get props => [message];
}

class CreatePostLoading extends HomeFeedState {
  final List<PostModel> previousPosts;
  const CreatePostLoading(this.previousPosts);

  @override
  List<Object> get props => [previousPosts];
}
