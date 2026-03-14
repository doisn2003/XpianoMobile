import '../../../../core/network/dio_client.dart';

class SearchedUser {
  final String id;
  final String fullName;
  final String? avatarUrl;
  final String? role;
  final String? phone;
  final String? email;

  SearchedUser({
    required this.id,
    required this.fullName,
    this.avatarUrl,
    this.role,
    this.phone,
    this.email,
  });

  factory SearchedUser.fromJson(Map<String, dynamic> json) {
    return SearchedUser(
      id: json['id']?.toString() ?? '',
      fullName: json['full_name'] as String? ?? '',
      avatarUrl: json['avatar_url'] as String?,
      role: json['role'] as String?,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
    );
  }
}

abstract class UserSearchDataSource {
  Future<List<SearchedUser>> searchUsers(String query);
}

class UserSearchDataSourceImpl implements UserSearchDataSource {
  final DioClient dioClient;

  UserSearchDataSourceImpl({required this.dioClient});

  @override
  Future<List<SearchedUser>> searchUsers(String query) async {
    if (query.trim().length < 2) return [];

    final response = await dioClient.get(
      '/social/users/search',
      queryParameters: {'q': query.trim()},
    );
    final List data = response.data['data'] as List? ?? [];
    return data.map((json) => SearchedUser.fromJson(json)).toList();
  }
}
