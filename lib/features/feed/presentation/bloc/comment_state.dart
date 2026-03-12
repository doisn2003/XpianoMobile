import 'package:equatable/equatable.dart';
import '../../domain/entities/comment.dart';

abstract class CommentState extends Equatable {
  const CommentState();
  @override
  List<Object?> get props => [];
}

class CommentInitial extends CommentState {}

class CommentLoading extends CommentState {}

class CommentLoaded extends CommentState {
  final List<Comment> comments;
  final bool hasReachedEnd;
  final bool isLoadingMore;
  final bool isSubmitting;

  const CommentLoaded({
    required this.comments,
    this.hasReachedEnd = false,
    this.isLoadingMore = false,
    this.isSubmitting = false,
  });

  CommentLoaded copyWith({
    List<Comment>? comments,
    bool? hasReachedEnd,
    bool? isLoadingMore,
    bool? isSubmitting,
  }) {
    return CommentLoaded(
      comments: comments ?? this.comments,
      hasReachedEnd: hasReachedEnd ?? this.hasReachedEnd,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }

  @override
  List<Object?> get props => [comments, hasReachedEnd, isLoadingMore, isSubmitting];
}

class CommentError extends CommentState {
  final String message;
  const CommentError(this.message);
  @override
  List<Object?> get props => [message];
}
