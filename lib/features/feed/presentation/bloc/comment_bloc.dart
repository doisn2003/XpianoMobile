import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/post_repository.dart';
import 'comment_event.dart';
import 'comment_state.dart';

class CommentBloc extends Bloc<CommentEvent, CommentState> {
  final PostRepository postRepository;
  static const int _pageSize = 20;
  String? _postId;

  CommentBloc({required this.postRepository}) : super(CommentInitial()) {
    on<CommentLoadRequested>(_onLoad);
    on<CommentLoadMore>(_onLoadMore);
    on<CommentSubmitted>(_onSubmit);
    on<CommentDeleted>(_onDelete);
  }

  Future<void> _onLoad(CommentLoadRequested event, Emitter<CommentState> emit) async {
    emit(CommentLoading());
    _postId = event.postId;

    final result = await postRepository.getComments(event.postId, limit: _pageSize);
    result.fold(
      (failure) => emit(CommentError(failure.message)),
      (comments) => emit(CommentLoaded(
        comments: comments,
        hasReachedEnd: comments.length < _pageSize,
      )),
    );
  }

  Future<void> _onLoadMore(CommentLoadMore event, Emitter<CommentState> emit) async {
    final current = state;
    if (current is! CommentLoaded || current.hasReachedEnd || current.isLoadingMore || _postId == null) return;

    emit(current.copyWith(isLoadingMore: true));

    final cursor = current.comments.last.createdAt.toIso8601String();
    final result = await postRepository.getComments(_postId!, cursor: cursor, limit: _pageSize);

    result.fold(
      (_) => emit(current.copyWith(isLoadingMore: false)),
      (newComments) => emit(current.copyWith(
        comments: [...current.comments, ...newComments],
        hasReachedEnd: newComments.length < _pageSize,
        isLoadingMore: false,
      )),
    );
  }

  Future<void> _onSubmit(CommentSubmitted event, Emitter<CommentState> emit) async {
    if (_postId == null) return;
    final current = state;
    if (current is CommentLoaded) {
      emit(current.copyWith(isSubmitting: true));
    }

    final result = await postRepository.addComment(_postId!, event.content, parentId: event.parentId);

    result.fold(
      (failure) {
        if (current is CommentLoaded) {
          emit(current.copyWith(isSubmitting: false));
        }
      },
      (comment) {
        if (current is CommentLoaded) {
          emit(current.copyWith(
            comments: [...current.comments, comment],
            isSubmitting: false,
          ));
        } else {
          emit(CommentLoaded(comments: [comment]));
        }
      },
    );
  }

  Future<void> _onDelete(CommentDeleted event, Emitter<CommentState> emit) async {
    final current = state;
    if (current is! CommentLoaded) return;

    final result = await postRepository.deleteComment(event.commentId);
    result.fold(
      (_) {}, // Ignore error silently
      (_) {
        final updatedComments = current.comments.where((c) => c.id != event.commentId).toList();
        emit(current.copyWith(comments: updatedComments));
      },
    );
  }
}
