import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/conversation.dart';
import '../entities/message.dart';

abstract class ChatRepository {
  Future<Either<Failure, List<Conversation>>> getConversations({String? cursor, int limit = 20});

  Future<Either<Failure, Conversation>> createConversation({required String userId});

  Future<Either<Failure, List<Message>>> getMessages(String conversationId, {String? cursor, int limit = 30});

  Future<Either<Failure, Message>> sendMessage(String conversationId, {required String content, String messageType = 'text'});

  Future<Either<Failure, void>> deleteMessage(String messageId);
}
