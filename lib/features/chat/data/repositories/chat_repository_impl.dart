import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/conversation.dart';
import '../../domain/entities/message.dart';
import '../../domain/repositories/chat_repository.dart';
import '../datasources/chat_remote_data_source.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource remoteDataSource;

  ChatRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<Conversation>>> getConversations({String? cursor, int limit = 20}) async {
    try {
      final conversations = await remoteDataSource.getConversations(cursor: cursor, limit: limit);
      return Right(conversations);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Conversation>> createConversation({required String userId}) async {
    try {
      final conversation = await remoteDataSource.createConversation(userId: userId);
      return Right(conversation);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Message>>> getMessages(String conversationId, {String? cursor, int limit = 30}) async {
    try {
      final messages = await remoteDataSource.getMessages(conversationId, cursor: cursor, limit: limit);
      return Right(messages);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Message>> sendMessage(String conversationId, {required String content, String messageType = 'text'}) async {
    try {
      final message = await remoteDataSource.sendMessage(conversationId, content: content, messageType: messageType);
      return Right(message);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteMessage(String messageId) async {
    try {
      await remoteDataSource.deleteMessage(messageId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
