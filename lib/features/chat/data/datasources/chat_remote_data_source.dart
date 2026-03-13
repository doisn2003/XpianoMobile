import '../../../../core/network/dio_client.dart';
import '../models/conversation_model.dart';
import '../models/message_model.dart';

abstract class ChatRemoteDataSource {
  Future<List<ConversationModel>> getConversations({String? cursor, int limit = 20});
  Future<ConversationModel> createConversation({required String userId});
  Future<List<MessageModel>> getMessages(String conversationId, {String? cursor, int limit = 30});
  Future<MessageModel> sendMessage(String conversationId, {required String content, String messageType = 'text'});
  Future<void> deleteMessage(String messageId);
}

class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  final DioClient dioClient;

  ChatRemoteDataSourceImpl({required this.dioClient});

  @override
  Future<List<ConversationModel>> getConversations({String? cursor, int limit = 20}) async {
    final params = <String, dynamic>{'limit': limit};
    if (cursor != null) params['cursor'] = cursor;

    final response = await dioClient.get('/messages/conversations', queryParameters: params);
    final List data = response.data['data'] as List? ?? [];
    return data.map((json) => ConversationModel.fromJson(json)).toList();
  }

  @override
  Future<ConversationModel> createConversation({required String userId}) async {
    final response = await dioClient.post('/messages/conversations', data: {'user_id': userId});
    return ConversationModel.fromJson(response.data['data']);
  }

  @override
  Future<List<MessageModel>> getMessages(String conversationId, {String? cursor, int limit = 30}) async {
    final params = <String, dynamic>{'limit': limit};
    if (cursor != null) params['cursor'] = cursor;

    final response = await dioClient.get('/messages/conversations/$conversationId/messages', queryParameters: params);
    final List data = response.data['data'] as List? ?? [];
    return data.map((json) => MessageModel.fromJson(json)).toList();
  }

  @override
  Future<MessageModel> sendMessage(String conversationId, {required String content, String messageType = 'text'}) async {
    final response = await dioClient.post(
      '/messages/conversations/$conversationId/messages',
      data: {'content': content, 'message_type': messageType},
    );
    return MessageModel.fromJson(response.data['data']);
  }

  @override
  Future<void> deleteMessage(String messageId) async {
    await dioClient.delete('/messages/$messageId');
  }
}
