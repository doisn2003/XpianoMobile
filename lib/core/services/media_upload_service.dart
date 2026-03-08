import 'dart:io';
import 'dart:async';
import 'package:dio/dio.dart';
import '../../features/feed/domain/repositories/post_repository.dart';

/// Service để upload media (ảnh/video) lên Supabase Storage
/// qua PreSigned URL — không đi qua Express backend.
///
/// Flow 3 bước:
/// 1. Xin signedUrl từ Express (POST /api/upload/sign)
/// 2. Upload file trực tiếp lên Supabase Storage (PUT signedUrl)
/// 3. Trả publicUrl để gắn vào bài viết
class MediaUploadService {
  final PostRepository _postRepository;

  MediaUploadService({required PostRepository postRepository})
      : _postRepository = postRepository;

  /// Upload một file và trả về publicUrl.
  /// [onProgress] callback với giá trị 0.0 → 1.0
  Future<String> uploadFile({
    required File file,
    required String uploadType, // 'post_image' hoặc 'post_video'
    void Function(double progress)? onProgress,
  }) async {
    final fileName = file.path.split(Platform.pathSeparator).last;
    final fileSize = await file.length();
    final contentType = _getContentType(fileName);

    // Bước 1: Xin PreSigned URL
    final result = await _postRepository.getSignedUploadUrl(
      uploadType: uploadType,
      fileName: fileName,
      fileSize: fileSize,
      contentType: contentType,
    );

    return result.fold(
      (failure) => throw Exception('Không thể tạo upload URL: ${failure.message}'),
      (urlData) async {
        final signedUrl = urlData['signedUrl']!;
        final publicUrl = urlData['publicUrl']!;

        // Bước 2: Upload trực tiếp lên Supabase Storage
        final dio = Dio();
        final fileBytes = await file.readAsBytes();

        await dio.put(
          signedUrl,
          data: Stream.fromIterable(fileBytes.map((e) => [e])),
          options: Options(
            headers: {
              'Content-Type': contentType,
              'Content-Length': fileSize,
            },
          ),
          onSendProgress: (sent, total) {
            if (onProgress != null && total > 0) {
              onProgress(sent / total);
            }
          },
        );

        // Bước 3: Trả publicUrl
        return publicUrl;
      },
    );
  }

  /// Upload nhiều file cùng lúc (cho bài viết nhiều ảnh)
  Future<List<String>> uploadMultipleFiles({
    required List<File> files,
    required String uploadType,
    void Function(int index, double progress)? onProgress,
  }) async {
    final urls = <String>[];
    for (int i = 0; i < files.length; i++) {
      final url = await uploadFile(
        file: files[i],
        uploadType: uploadType,
        onProgress: (p) => onProgress?.call(i, p),
      );
      urls.add(url);
    }
    return urls;
  }

  String _getContentType(String fileName) {
    final ext = fileName.split('.').last.toLowerCase();
    switch (ext) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      case 'mp4':
        return 'video/mp4';
      case 'mov':
        return 'video/quicktime';
      default:
        return 'application/octet-stream';
    }
  }
}
